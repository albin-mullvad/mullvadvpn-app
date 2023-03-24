package net.mullvad.mullvadvpn.test.e2e.constant

import net.mullvad.mullvadvpn.test.e2e.BuildConfig

const val CONN_CHECK_URL = "https://am.i.${BuildConfig.BASE_ENDPOINT}/json"
