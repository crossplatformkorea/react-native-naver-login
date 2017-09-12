
package com.dooboolab.naverlogin;

import android.app.Activity;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.UiThreadUtil;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.nhn.android.naverlogin.OAuthLogin;
import com.nhn.android.naverlogin.OAuthLoginHandler;

import org.json.JSONException;
import org.json.JSONObject;

import cz.msebera.android.httpclient.Header;

public class RNNaverLoginModule extends ReactContextBaseJavaModule {
  final String TAG = "ReactNaverModule";

  private final ReactApplicationContext reactContext;
  private OAuthLogin mOAuthLoginModule;

  public RNNaverLoginModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNNaverLogin";
  }

  @ReactMethod
  public void getProfile(String accessToken, final Callback cb) {
    AsyncHttpClient asyncHttpClient = new AsyncHttpClient();
    asyncHttpClient.addHeader("Authorization", "Bearer " + accessToken);
    asyncHttpClient.get(reactContext, "https://openapi.naver.com/v1/nid/me", new JsonHttpResponseHandler() {
      @Override
      public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
        super.onSuccess(statusCode, headers, response);
        cb.invoke(null, response.toString());
      }
    });
  }

  @ReactMethod
  public void logout() {
    mOAuthLoginModule.logout(reactContext);
  }

  @ReactMethod
  public void login(String initials, final Callback cb) {
    final Activity activity = getCurrentActivity();
    try {
      JSONObject jsonObject = new JSONObject(initials);
      mOAuthLoginModule = OAuthLogin.getInstance();
      mOAuthLoginModule.init(
          reactContext,
          jsonObject.getString("key"),
          jsonObject.getString("secret"),
          jsonObject.getString("name")
      );
      UiThreadUtil.runOnUiThread(new Runnable() {
        @Override
        public void run() {
          mOAuthLoginModule.startOauthLoginActivity(
              activity,
              new OAuthLoginHandler() {
                @Override
                public void run(boolean success) {
                  if (success) {
                    final String accessToken = mOAuthLoginModule.getAccessToken(reactContext);
                    String refreshToken = mOAuthLoginModule.getRefreshToken(reactContext);
                    long expiresAt = mOAuthLoginModule.getExpiresAt(reactContext);
                    String tokenType = mOAuthLoginModule.getTokenType(reactContext);

                    try {
                      JSONObject response = new JSONObject();
                      response.put("accessToken", accessToken);
                      response.put("refreshToken", refreshToken);
                      response.put("expiresAt", expiresAt);
                      response.put("tokenType", tokenType);
                      cb.invoke(null, response.toString());
                    } catch (JSONException je) {
                      Log.e(TAG, "JSONEXception: " + je.getMessage());
                      cb.invoke(je.getMessage(), null);
                    }

                  } else {
                    String errCode = mOAuthLoginModule.getLastErrorCode(reactContext).getCode();
                    String errDesc = mOAuthLoginModule.getLastErrorDesc(reactContext);
                    Log.e(TAG, "errCode: " + errCode + ", errDesc: " + errDesc);
                  }
                }
              }
          );
        }
      });
    } catch (JSONException je) {
      Log.d(TAG, "JSONException: " + je);
    }
  }
}