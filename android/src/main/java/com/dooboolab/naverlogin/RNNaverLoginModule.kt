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
    private var naverIdLoginSDK: NaverIdLoginSDK? = null
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
    fun logout() {
        if (naverIdLoginSDK != null) {
            naverIdLoginSDK!!.logout()
        }
    }

    // only android
    @ReactMethod
    fun logoutWithCallback(cb: Callback) {
        try {
            naverIdLoginSDK!!.logout()
            cb.invoke(null, true)
        } catch (e: Exception) {
            cb.invoke(e.message, null)
        }
    }

    @ReactMethod
    fun login(initials: ReadableMap, cb: Callback) {
        loginAllow = true
        naverIdLoginSDK = NaverIdLoginSDK
        try {
            naverIdLoginSDK!!.initialize(
                reactContext,
                initials.getString("kConsumerKey"),
                initials.getString("kConsumerSecret"),
                initials.getString("kServiceAppName")
            )
            UiThreadUtil.runOnUiThread {
                val oAuthLoginCallback: OAuthLoginCallback = object : OAuthLoginCallback {
                    override fun onSuccess() {
                        val accessToken = naverIdLoginSDK!!.getAccessToken()
                        val refreshToken = naverIdLoginSDK!!.getRefreshToken()
                        val expiresAt = naverIdLoginSDK!!.getExpiresAt()
                        val tokenType = naverIdLoginSDK!!.getTokenType()
                        try {
                            val response = Arguments.createMap()
                            response.putString("accessToken", accessToken)
                            response.putString("refreshToken", refreshToken)
                            response.putString("expiresAt", java.lang.Long.toString(expiresAt))
                            response.putString("tokenType", tokenType) // cb.invoke(null, response.toString());
                            if (loginAllow) {
                                cb.invoke(null, response)
                                loginAllow = false
                            }
                        } catch (je: Exception) {
                            Log.e(tag, "Exception: " + je.message)
                            if (loginAllow) {
                                cb.invoke(je.message, null)
                                loginAllow = false
                            }
                        }
                    }

                    override fun onFailure(i: Int, s: String) {
                        val errCode = naverIdLoginSDK!!.getLastErrorCode().code
                        val errDesc = naverIdLoginSDK!!.getLastErrorDescription()
                        val error = Arguments.createMap()
                        error.putString("errCode", errCode)
                        error.putString("errDesc", errDesc)
                        Log.e(tag, error.toString())
                        if (loginAllow) {
                            cb.invoke(error, null)
                            loginAllow = false
                        }
                    }

                    override fun onError(i: Int, s: String) {
                        this.onFailure(i, s)
                    }
                }
                naverIdLoginSDK!!.logout()
                naverIdLoginSDK!!.authenticate(reactContext, oAuthLoginCallback)
            }
        } catch (je: Exception) {
            Log.d(tag, "Exception: $je")
        }
    }
}