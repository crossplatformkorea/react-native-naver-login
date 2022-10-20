package com.dooboolab.naverlogin

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.UiThreadUtil
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.NidOAuthBehavior.CUSTOMTABS
import com.navercorp.nid.oauth.NidOAuthErrorCode
import com.navercorp.nid.oauth.NidOAuthLogin
import com.navercorp.nid.oauth.OAuthLoginCallback

class RNNaverLoginModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(
    reactContext
) {
    override fun getName() = "RNNaverLogin"

    @ReactMethod
    fun logout(promise: Promise) = UiThreadUtil.runOnUiThread {
        try {
            callLogout()
            promise.resolve(42)
        } catch (e: Exception) {
            promise.reject(e)
        }
    }

    private fun callLogout() = NaverIdLoginSDK::logout

    @ReactMethod
    fun login(
        consumerKey: String,
        consumerSecret: String,
        appName: String,
        disableNaverAppAuth: Boolean,
        promise: Promise
    ) = UiThreadUtil.runOnUiThread {
        if (currentActivity == null) {
            promise.onFailure("현재 실행중인 Activity 를 찾을 수 없습니다")
            return@runOnUiThread
        }
        try {
            NaverIdLoginSDK.initialize(
                currentActivity!!,
                consumerKey,
                consumerSecret,
                appName,
            )
            callLogout()

            // DEFAULTS 는 naver app -> custom tab -> webview
            // CUSTOMTABS 는 custom tab -> webview 의 우선순위로 실행되는 것으로 보인다.
            // WebView는 SDK 5.2.0 부터 deprecated 되므로 migration시 주의를 요한다. (현재 5.1.0 사용)
            if(disableNaverAppAuth) NaverIdLoginSDK.behavior = CUSTOMTABS
            NaverIdLoginSDK.authenticate(currentActivity!!, object : OAuthLoginCallback {
                override fun onSuccess() = promise.onSuccess()
                override fun onFailure(httpStatus: Int, message: String) = promise.onFailure(message)
                override fun onError(errorCode: Int, message: String) = promise.onFailure(message)
            })
        } catch (je: Exception) {
            promise.onFailure(je.localizedMessage)
        }
    }

    @ReactMethod
    fun deleteToken(promise: Promise) = UiThreadUtil.runOnUiThread {
        NidOAuthLogin().callDeleteTokenApi(currentActivity!!, object : OAuthLoginCallback {
            override fun onSuccess() = promise.resolve(42)
            override fun onFailure(httpStatus: Int, message: String) = promise.reject(message, message)
            override fun onError(errorCode: Int, message: String) = promise.reject(message, message)
        })
    }

    private fun Promise.onSuccess() = resolve(createLoginSuccessResponse())
    private fun Promise.onFailure(message: String?) = resolve(createLoginFailureResponse(message))

    companion object {
        private fun createLoginSuccessResponse() = Arguments.createMap().apply {
            putBoolean("isSuccess", true)
            putMap("successResponse", Arguments.createMap().apply {
                putString("accessToken", NaverIdLoginSDK.getAccessToken())
                putString("refreshToken", NaverIdLoginSDK.getRefreshToken())
                putString("expiresAtUnixSecondString", NaverIdLoginSDK.getExpiresAt().toString())
                putString("tokenType", NaverIdLoginSDK.getTokenType())
            })
        }

        private fun createLoginFailureResponse(additionalMessage: String?) = Arguments.createMap().apply {
            putBoolean("isSuccess", false)
            putMap("failureResponse", Arguments.createMap().apply {
                val lastErrorCode = NaverIdLoginSDK.getLastErrorCode().code
                val isCancel = lastErrorCode == NidOAuthErrorCode.CLIENT_USER_CANCEL.code

                putString("message", additionalMessage ?: "알 수 없는 에러입니다")
                putString("lastErrorCodeFromNaverSDK", lastErrorCode)
                putString("lastErrorDescriptionFromNaverSDK", NaverIdLoginSDK.getLastErrorDescription())
                putBoolean("isCancel", isCancel)
            })
        }
    }
}