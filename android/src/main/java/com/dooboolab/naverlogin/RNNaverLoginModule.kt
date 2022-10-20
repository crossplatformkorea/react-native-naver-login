package com.dooboolab.naverlogin

import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Intent
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import androidx.appcompat.app.AppCompatActivity
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.UiThreadUtil
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.NidOAuthErrorCode
import com.navercorp.nid.oauth.NidOAuthLogin
import com.navercorp.nid.oauth.OAuthLoginCallback

class RNNaverLoginModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(
    reactContext
) {
    override fun getName() = "RNNaverLogin"

    init {
        reactContext.addLifecycleEventListener(object : LifecycleEventListener {
            override fun onHostResume() {}

            override fun onHostPause() {}

            override fun onHostDestroy() {
                dummyActivityResultLauncher?.unregister()
                dummyActivityResultLauncher = null
                loginPromise = null
            }
        })
    }

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
        consumerKey: String, consumerSecret: String, appName: String, promise: Promise
    ) = UiThreadUtil.runOnUiThread {
        loginPromise = promise
        if (currentActivity == null) {
            onLoginFailure("현재 실행중인 Activity 를 찾을 수 없습니다")
            return@runOnUiThread
        }
        if (dummyActivityResultLauncher == null) {
            onLoginFailure("ActivityResultLauncher 가 등록되지 않았습니다. MainActivity 가 AppCompatActivity 인지 확인해주세요")
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
            NaverIdLoginSDK.authenticate(currentActivity!!, dummyActivityResultLauncher!!, object : OAuthLoginCallback {
                override fun onSuccess() {
                    onLoginSuccess()
                }

                override fun onFailure(httpStatus: Int, message: String) {
                    onLoginFailure(message)
                }

                override fun onError(errorCode: Int, message: String) {
                    onLoginFailure(message)
                }
            })
        } catch (je: Exception) {
            onLoginFailure(je.localizedMessage)
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

    companion object {
        private var dummyActivityResultLauncher: ActivityResultLauncher<Intent>? = null
        private var loginPromise: Promise? = null

        /** Call at `onCreate` of main `Activity` */
        @JvmStatic
        fun initialize(activity: AppCompatActivity) {
            dummyActivityResultLauncher?.unregister()
            dummyActivityResultLauncher = activity.registerForActivityResult(
                StartActivityForResult()
            ) { result ->
                when (result.resultCode) {
                    RESULT_OK -> onLoginSuccess()
                    RESULT_CANCELED -> onLoginFailure(null)
                    else -> onLoginFailure(null)
                }
            }
        }

        private fun onLoginSuccess() = loginPromise?.run {
            resolve(createLoginSuccessResponse())
            loginPromise = null
        }

        private fun onLoginFailure(message: String?) = loginPromise?.run {
            resolve(createLoginFailureResponse(message))
            loginPromise = null
        }

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