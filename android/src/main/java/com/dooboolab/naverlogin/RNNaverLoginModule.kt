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

class RNNaverLoginModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(
    reactContext
) {
    private val tag: String get() = this::class.java.simpleName

    private var loginAllow = false
    override fun getName() = "RNNaverLogin"

    // 자바스크립트에서 처리 하므로 네이티브 코드가 불필요 해서 주석처리 합니다
    //  @ReactMethod
    //  public void getProfile(String accessToken, final Callback cb) {
    //    AsyncHttpClient asyncHttpClient = new AsyncHttpClient();
    //    asyncHttpClient.addHeader("Authorization", "Bearer " + accessToken);
    //    asyncHttpClient.get(reactContext, "https://openapi.naver.com/v1/nid/me", new JsonHttpResponseHandler() {
    //      @Override
    //      public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
    //        super.onSuccess(statusCode, headers, response);
    //        cb.invoke(null, response.toString());
    //      }
    //    });
    //  }
    @ReactMethod
    fun logout() = NaverIdLoginSDK.logout()

    // only android
    @ReactMethod
    fun logoutWithCallback(cb: Callback) {
        NaverIdLoginSDK.logout()
        cb.invoke(null, true)
    }

    @ReactMethod
    fun login(initials: ReadableMap, cb: Callback) {
        if(!reactContext.hasCurrentActivity()) return;

        loginAllow = true
        try {
            NaverIdLoginSDK.initialize(
                reactContext,
                initials.getString("kConsumerKey")!!,
                initials.getString("kConsumerSecret")!!,
                initials.getString("kServiceAppName")!!,
            )
            UiThreadUtil.runOnUiThread {
                logout()
                NaverIdLoginSDK.authenticate(reactContext, object : OAuthLoginCallback {
                    override fun onSuccess() {
                        if (!loginAllow) return
                        try {
                            cb.invoke(null, createLoginSuccessResponse())
                        } catch (je: Exception) {
                            Log.e(tag, "Exception: " + je.message)
                            cb.invoke(je.message, null)
                        } finally {
                            loginAllow = false
                        }
                    }

                    override fun onFailure(httpStatus: Int, message: String) {
                        if (!loginAllow) return
                        cb.invoke(createLoginFailureResponse().also { Log.e(tag, it.toString()) }, null)
                        loginAllow = false
                    }

                    override fun onError(i: Int, s: String) {
                        this.onFailure(i, s)
                    }
                })
            }
        } catch (je: Exception) {
            Log.e(tag, "Exception: $je")
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


