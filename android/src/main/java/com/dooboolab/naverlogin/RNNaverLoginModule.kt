package com.dooboolab.naverlogin

import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.util.Log
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import androidx.appcompat.app.AppCompatActivity
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.OAuthLoginCallback

class RNNaverLoginModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(
    reactContext
) {
    override fun getName() = "RNNaverLogin"

    @ReactMethod
    fun logout() = NaverIdLoginSDK.logout()

    // only android
    @ReactMethod
    fun logoutWithCallback(cb: Callback) {
        NaverIdLoginSDK.logout()
        cb.invoke(null, true)
    }

    @ReactMethod
    fun login(initials: ReadableMap, callback: Callback) {
        if (dummyActivityResultLauncher == null) {
            Log.e(TAG, "NaverSDK login Failed, Make sure your Activity is AppCompatActivity")
            return
        }

        try {
            NaverIdLoginSDK.initialize(
                reactContext,
                initials.getString("kConsumerKey")!!,
                initials.getString("kConsumerSecret")!!,
                initials.getString("kServiceAppName")!!,
            )
            UiThreadUtil.runOnUiThread {
                logout()

                loginCallback = callback
                NaverIdLoginSDK.authenticate(reactContext, dummyActivityResultLauncher!!, object : OAuthLoginCallback {
                    override fun onSuccess() {
                        callback.invoke(null, createLoginSuccessResponse())
                    }

                    override fun onFailure(httpStatus: Int, message: String) {
                        callback.invoke(createLoginFailureResponse().also { Log.e(TAG, it.toString()) }, null)
                    }

                    override fun onError(errorCode: Int, message: String) {
                        callback.invoke(createLoginFailureResponse().also { Log.e(TAG, it.toString()) }, null)
                    }
                })
            }
        } catch (je: Exception) {
            Log.e(TAG, "Exception: $je")
        }
    }

    companion object {
        private val TAG = RNNaverLoginModule::class.java.simpleName

        private var dummyActivityResultLauncher: ActivityResultLauncher<Intent>? = null
        private var loginCallback: Callback? = null
        fun initialize(activity: AppCompatActivity) {
            dummyActivityResultLauncher?.unregister()
            dummyActivityResultLauncher = activity.registerForActivityResult(
                StartActivityForResult()
            ) { result ->
                when (result.resultCode) {
                    RESULT_OK -> loginCallback?.invoke(null, createLoginSuccessResponse())
                    RESULT_CANCELED -> loginCallback?.invoke(createLoginFailureResponse().also {
                        Log.e(
                            TAG,
                            it.toString()
                        )
                    }, null)
                }
            }
        }

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