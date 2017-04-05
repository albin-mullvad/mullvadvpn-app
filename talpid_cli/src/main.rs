// `error_chain!` can recurse deeply
#![recursion_limit = "1024"]

extern crate talpid_core;
#[macro_use]
extern crate clap;
#[macro_use]
extern crate error_chain;
extern crate log;
extern crate env_logger;

use std::io::{self, Read, Write};
use std::sync::mpsc::{self, Receiver};
use std::thread;

use talpid_core::process::openvpn::{OpenVpnCommand, OpenVpnEvent, OpenVpnMonitor};

mod cli;

use cli::Args;


error_chain! {
    errors {
        InitLoggingFailed {
            description("Failed to bootstrap logging system")
        }
    }
    links {
        Monitor(talpid_core::process::openvpn::Error, talpid_core::process::openvpn::ErrorKind);
    }
}


quick_main!(run);

fn run() -> Result<()> {
    init_logger()?;
    let args = cli::parse_args_or_exit();
    let command = create_openvpn_command(&args);
    let monitor = OpenVpnMonitor::new(command, args.plugin_path);
    main_loop(monitor)
}

pub fn init_logger() -> Result<()> {
    env_logger::init().chain_err(|| ErrorKind::InitLoggingFailed)
}

fn create_openvpn_command(args: &Args) -> OpenVpnCommand {
    let mut command = OpenVpnCommand::new(&args.binary);
    command.config(&args.config)
        .remotes(&args.remotes[..])
        .unwrap()
        .pipe_output(args.verbosity > 0);

    command
}

fn main_loop(mut monitor: OpenVpnMonitor) -> Result<()> {
    loop {
        let rx = start_monitor(&mut monitor).chain_err(|| "Unable to start OpenVPN")?;
        while let Ok(msg) = rx.recv() {
            match msg {
                OpenVpnEvent::Shutdown(clean) => {
                    println!("Monitored process exited. clean: {}", clean);
                    break;
                }
                OpenVpnEvent::PluginEvent(Ok((event, env))) => {
                    println!("OpenVPN event:\nEvent: {:?}\nENV: {:?}", event, env);
                }
                OpenVpnEvent::PluginEvent(Err(e)) => println!("Read error from plugin: {:?}", e),
            }
        }
        std::thread::sleep(std::time::Duration::from_millis(500));
    }
}

fn start_monitor(monitor: &mut OpenVpnMonitor) -> Result<Receiver<OpenVpnEvent>> {
    let (tx, rx) = mpsc::channel();
    let callback = move |clean| tx.send(clean).unwrap();
    Ok(monitor.start(callback)
        .map(|(stdout, stderr)| {
            stdout.map(|stream| pass_io(stream, io::stdout()));
            stderr.map(|stream| pass_io(stream, io::stderr()));
            rx
        })?)
}

fn pass_io<I, O>(mut input: I, mut output: O)
    where I: Read + Send + 'static,
          O: Write + Send + 'static
{
    thread::spawn(move || { io::copy(&mut input, &mut output).unwrap(); });
}
