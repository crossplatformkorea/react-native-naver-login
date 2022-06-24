package com.dooboolab.naverlogin

import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Callback
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.OAuthLoginCallback

class RNNaverLoginModule(
    private val reactContext: ReactApplicationContext
) : ReactContextBaseJavaModule(reactContext) {
    private var isLoginAllowed = false

    override fun getName() = "RNNaverLogin"

    @ReactMethod
    fun logout() {
        NaverIdLoginSDK.logout()
    }

    @ReactMethod
    fun logoutWithCallback(callback: Callback) {
        runCatching {
            NaverIdLoginSDK.logout()
            callback(null, true)
        }.onFailure {
            callback(it.message, null)
        }
    }

    @ReactMethod
    fun login(initials: ReadableMap, callback: Callback) {
        isLoginAllowed = true

        runCatching {
            NaverIdLoginSDK.initialize(
                reactContext,
                initials.getString("kConsumerKey") ?: "",
                initials.getString("kConsumerSecret") ?: "",
                initials.getString("kServiceAppName") ?: ""
            )
            UiThreadUtil.runOnUiThread {
                NaverIdLoginSDK.logout()
                NaverIdLoginSDK.authenticate(reactContext, getAuthCallback(callback))
            }
        }.onFailure {
            Log.e("Naver Login Error", "Error occured: $it", it)
        }
    }

    private fun getAuthCallback(callback: Callback) = object : OAuthLoginCallback {
        override fun onError(errorCode: Int, message: String) {
            this.onFailure(errorCode, message)
        }

        override fun onFailure(httpStatus: Int, message: String) {
            val errorMessage =
                "errCode: ${NaverIdLoginSDK.getLastErrorCode().code}, errDesc: ${NaverIdLoginSDK.getLastErrorDescription()}"
            Log.e(TAG, errorMessage)
            if (isLoginAllowed) {
                callback(errorMessage, null)
                isLoginAllowed = false
            }
        }

        override fun onSuccess() {
            runCatching {
                val response = Arguments.createMap().apply {
                    putString("accessToken", NaverIdLoginSDK.getAccessToken())
                    putString("refreshToken", NaverIdLoginSDK.getRefreshToken())
                    putString("expiresAt", NaverIdLoginSDK.getExpiresAt().toString())
                    putString("tokenType", NaverIdLoginSDK.getTokenType())
                }

                if (isLoginAllowed) {
                    callback(null, response)
                    isLoginAllowed = false
                }
            }.onFailure {
                Log.e("Naver Login Error", "Error occured $it", it)
                if (isLoginAllowed) {
                    callback(it.message, null)
                    isLoginAllowed = false
                }
            }
        }
    }

    companion object {
        private const val TAG = "ReactNaverModule"
    }
}
