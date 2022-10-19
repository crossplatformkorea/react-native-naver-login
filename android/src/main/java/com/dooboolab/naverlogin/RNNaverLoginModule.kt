package com.dooboolab.naverlogin

import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.OAuthLoginCallback

class RNNaverLoginModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(
    reactContext
) {
    override fun getName() = "RNNaverLogin"

    @ReactMethod
    fun logout() = try {
        NaverIdLoginSDK.logout()
    } catch (_: Exception) {
    }

    @ReactMethod
    fun login(initials: ReadableMap, callback: Callback) {
        currentActivity?.let { context ->
            try {
                NaverIdLoginSDK.initialize(
                    context,
                    initials.getString("kConsumerKey")!!,
                    initials.getString("kConsumerSecret")!!,
                    initials.getString("kServiceAppName")!!,
                )
                UiThreadUtil.runOnUiThread {
                    logout()

                    NaverIdLoginSDK.authenticate(context, object : OAuthLoginCallback {
                        override fun onSuccess() = callback.onSuccess()
                        override fun onFailure(httpStatus: Int, message: String) = callback.onFailure()
                        override fun onError(errorCode: Int, message: String) = callback.onFailure()
                    })
                }
            } catch (je: Exception) {
                Log.e(TAG, "Exception: $je")
            }
        }
    }

    private fun Callback.onSuccess() = invoke(null, createLoginSuccessResponse())
    private fun Callback.onFailure() = invoke(null, createLoginFailureResponse())

    companion object {
        private val TAG = RNNaverLoginModule::class.java.simpleName

        private fun createLoginSuccessResponse() = Arguments.createMap().apply {
            putString("accessToken", NaverIdLoginSDK.getAccessToken())
            putString("refreshToken", NaverIdLoginSDK.getRefreshToken())
            putString("expiresAt", NaverIdLoginSDK.getExpiresAt().toString())
            putString("tokenType", NaverIdLoginSDK.getTokenType())
        }

        private fun createLoginFailureResponse() = Arguments.createMap().apply {
            putString("errCode", NaverIdLoginSDK.getLastErrorCode().code)
            putString("errDesc", NaverIdLoginSDK.getLastErrorDescription())
        }
    }
}