//
//  IPOverrideViewController.swift
//  MullvadVPN
//
//  Created by Jon Petersson on 2024-01-15.
//  Copyright © 2024 Mullvad VPN AB. All rights reserved.
//

import UIKit

class IPOverrideViewController: UIViewController {
    let alertPresenter: AlertPresenter

    private lazy var containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        return view
    }()

    private lazy var clearButton: AppButton = {
        let button = AppButton(style: .danger)
        button.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        button.setTitle(NSLocalizedString(
            "IP_OVERRIDE_CLEAR_BUTTON",
            tableName: "IPOverride",
            value: "Clear all overrides",
            comment: ""
        ), for: .normal)
        return button
    }()

    init(alertPresenter: AlertPresenter) {
        self.alertPresenter = alertPresenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .secondaryColor

        addHeader()
        addPreamble()
        addImportButtons()
        addStatusLabel()

        view.addConstrainedSubviews([containerView, clearButton]) {
            containerView.pinEdgesToSuperviewMargins(.all().excluding(.bottom))
            clearButton.pinEdgesToSuperviewMargins(.all().excluding(.top))
        }
    }

    private func addHeader() {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.text = NSLocalizedString(
            "IP_OVERRIDE_HEADER",
            tableName: "IPOverride",
            value: "Server IP override",
            comment: ""
        )

        let infoButton = UIButton(type: .custom)
        infoButton.tintColor = .white
        infoButton.setImage(UIImage(resource: .iconInfo), for: .normal)
        infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
        infoButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        infoButton.widthAnchor.constraint(equalTo: infoButton.heightAnchor, multiplier: 1).isActive = true

        let headerView = UIStackView(arrangedSubviews: [label, infoButton, UIView()])
        headerView.spacing = 8

        containerView.addArrangedSubview(headerView)
        containerView.setCustomSpacing(14, after: headerView)
    }

    private func addPreamble() {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white.withAlphaComponent(0.6)
        label.numberOfLines = 0
        label.text = NSLocalizedString(
            "IP_OVERRIDE_PREAMBLE",
            tableName: "IPOverride",
            value: "Import files or text with new IP addresses for the servers in the Select location view.",
            comment: ""
        )

        containerView.addArrangedSubview(label)
    }

    private func addImportButtons() {
        let importTextButton = AppButton(style: .default)
        importTextButton.addTarget(self, action: #selector(didTapImportTextButton), for: .touchUpInside)
        importTextButton.setTitle(NSLocalizedString(
            "IP_OVERRIDE_IMPORT_TEXT_BUTTON",
            tableName: "IPOverride",
            value: "Import via text",
            comment: ""
        ), for: .normal)

        let importFileButton = AppButton(style: .default)
        importFileButton.addTarget(self, action: #selector(didTapImportFileButton), for: .touchUpInside)
        importFileButton.setTitle(NSLocalizedString(
            "IP_OVERRIDE_IMPORT_FILE_BUTTON",
            tableName: "IPOverride",
            value: "Import file",
            comment: ""
        ), for: .normal)

        let stackView = UIStackView(arrangedSubviews: [importTextButton, importFileButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 12

        containerView.addArrangedSubview(stackView)
    }

    private func addStatusLabel() {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.text = NSLocalizedString(
            "IP_OVERRIDE_STATUS",
            tableName: "IPOverride",
            value: "Overrides active",
            comment: ""
        ).uppercased()

        containerView.addArrangedSubview(label)
    }

    @objc private func didTapInfoButton() {
        let message = NSLocalizedString(
            "IP_OVERRIDE_DIALOG_MESSAGE",
            tableName: "IPOverride",
            value: """
            On some networks, where various types of censorship are being used, our server IP addresses are \
            sometimes blocked.

            To circumvent this you can import a file or a text, provided by our support team, \
            with new IP addresses that override the default addresses of the servers in the Select location view.

            If you are having issues connecting to VPN servers, please contact support.
            """,
            comment: ""
        )

        let presentation = AlertPresentation(
            id: "ip-override-info-alert",
            icon: .info,
            title: NSLocalizedString(
                "IP_OVERRIDE_INFO_DIALOG_TITLE",
                tableName: "IPOverride",
                value: "Server IP override",
                comment: ""
            ),
            message: message,
            buttons: [AlertAction(
                title: NSLocalizedString(
                    "IP_OVERRIDE_INFO_DIALOG_OK_BUTTON",
                    tableName: "IPOverride",
                    value: "Got it!",
                    comment: ""
                ),
                style: .default
            )]
        )

        alertPresenter.showAlert(presentation: presentation, animated: true)
    }

    @objc private func didTapClearButton() {
        let presentation = AlertPresentation(
            id: "ip-override-clear-alert",
            icon: .alert,
            title: NSLocalizedString(
                "IP_OVERRIDE_CLEAR_DIALOG_TITLE",
                tableName: "IPOverride",
                value: "Clear all overrides?",
                comment: ""
            ),
            message: NSLocalizedString(
                "IP_OVERRIDE_CLEAR_DIALOG_MESSAGE",
                tableName: "IPOverride",
                value: """
                Clearing the imported overrides changes the server IPs, in the Select location view, \
                back to default.
                """,
                comment: ""
            ),
            buttons: [
                AlertAction(
                    title: NSLocalizedString(
                        "IP_OVERRIDE_CLEAR_DIALOG_CANCEL_BUTTON",
                        tableName: "IPOverride",
                        value: "Cancel",
                        comment: ""
                    ),
                    style: .default
                ),
                AlertAction(
                    title: NSLocalizedString(
                        "IP_OVERRIDE_CLEAR_DIALOG_CLEAR_BUTTON",
                        tableName: "IPOverride",
                        value: "Clear",
                        comment: ""
                    ),
                    style: .destructive
                ),
            ]
        )

        alertPresenter.showAlert(presentation: presentation, animated: true)
    }

    @objc private func didTapImportTextButton() {}
    @objc private func didTapImportFileButton() {}
}
