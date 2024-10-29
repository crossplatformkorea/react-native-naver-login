package com.dooboolab.naverlogin

import android.util.Log
import com.facebook.react.bridge.ObjectAlreadyConsumedException
import com.facebook.react.bridge.Promise

/**
 * Extension functions used to simplify promise handling since we don't
 * want to crash in the case of it being resolved/rejected more than once
 */

const val TAG = "RNNaverLogin"

fun Promise.safeResolve(value: Any?) {
    try {
        this.resolve(value)
    } catch (oce: ObjectAlreadyConsumedException) {
        Log.d(TAG, "Already consumed ${oce.message}")
    }
}

fun Promise.safeReject(message: String) = this.safeReject(null, message, null)

fun Promise.safeReject(e: Exception) = this.safeReject(null, e.message, e)

fun Promise.safeReject(
    code: String?,
    message: String?,
) = this.safeReject(code, message, null)

fun Promise.safeReject(
    code: String?,
    throwable: Throwable?,
) = this.safeReject(code, null, throwable)

fun Promise.safeReject(
    code: String?,
    message: String?,
    throwable: Throwable?,
) {
    try {
        this.reject(code ?: "UNKNOWN_ERROR", message, throwable)
    } catch (oce: ObjectAlreadyConsumedException) {
        Log.d(TAG, "Already consumed ${oce.message}")
    }
}
