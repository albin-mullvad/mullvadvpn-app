package net.mullvad.mullvadvpn.test.e2e.extension

import android.os.Build
import android.os.Bundle
import android.util.Log
import net.mullvad.mullvadvpn.test.e2e.constant.INVALID_TEST_ACCOUNT_TOKEN_ARGUMENT_KEY
import net.mullvad.mullvadvpn.test.e2e.constant.LOG_TAG
import net.mullvad.mullvadvpn.test.e2e.constant.VALID_TEST_ACCOUNT_TOKEN_ARGUMENT_KEY

fun Bundle.getOptionalArgument(argument: String): String? {
    return getString(argument).also {
        if (it == null) {
            Log.d(LOG_TAG, "Got optional argument $argument=$it")
        }
    }
}

fun Bundle.getRequiredArgument(argument: String): String {
    return getString(argument).also { Log.d(LOG_TAG, "Got required argument $argument=$it") }
        ?: throw IllegalArgumentException("Missing required argument: $argument")
}

fun Bundle.getValidAccountTokenArgument(): String {
    Log.d(LOG_TAG, "getValidAccountTokenArgument")
    Log.d(LOG_TAG, "fingerprint: ${Build.FINGERPRINT}")
    Log.d(LOG_TAG, "fingerprint sanitized1: ${Build.FINGERPRINT.filter { it.isLetterOrDigit()}}")
    //    Log.d(LOG_TAG, "fingerprint sanitized2: ${re.replace(Build.FINGERPRINT.filter {
    // it.isLetterOrDigit() }, "")}")

    return getOptionalArgument("ACCOUNT_${generateDeviceFingerprint()}")
        ?: getRequiredArgument(VALID_TEST_ACCOUNT_TOKEN_ARGUMENT_KEY)
}

fun Bundle.getInvalidAccountTokenArgument(): String {
    return getRequiredArgument(INVALID_TEST_ACCOUNT_TOKEN_ARGUMENT_KEY)
}

private fun generateDeviceFingerprint(): String {
    return "${Build.BRAND}_${Build.PRODUCT}_${Build.DEVICE}_${Build.VERSION.RELEASE}"
}
