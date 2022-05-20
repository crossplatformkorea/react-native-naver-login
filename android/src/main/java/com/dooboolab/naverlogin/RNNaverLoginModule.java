
package com.dooboolab.naverlogin;

import android.app.Activity;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.navercorp.nid.NaverIdLoginSDK;
import com.navercorp.nid.oauth.OAuthLoginCallback;

public class RNNaverLoginModule extends ReactContextBaseJavaModule {
  final String TAG = "ReactNaverModule";
  private boolean loginAllow = false;

  private final ReactApplicationContext reactContext;
  private NaverIdLoginSDK naverIdLoginSDK;

  public RNNaverLoginModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNNaverLogin";
  }

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
  public void logout() {
    if (naverIdLoginSDK != null) {
      naverIdLoginSDK.logout();
    }
  }

  // only android
  @ReactMethod
  public void logoutWithCallback(final Callback cb) {
    try {
      naverIdLoginSDK.logout();
      cb.invoke(null, true);
    } catch (Exception e) {
      cb.invoke(e.getMessage(), null);
    }
  }

  @ReactMethod
  public void login(ReadableMap initials, final Callback cb) {
    loginAllow = true;
    naverIdLoginSDK = NaverIdLoginSDK.INSTANCE;

    try {
      naverIdLoginSDK.initialize(
              reactContext,
              initials.getString("kConsumerKey"),
              initials.getString("kConsumerSecret"),
              initials.getString("kServiceAppName")
      );

      UiThreadUtil.runOnUiThread(new Runnable() {
        @Override
        public void run() {
          OAuthLoginCallback oAuthLoginCallback = new OAuthLoginCallback() {
            @Override
            public void onSuccess() {
              final String accessToken = naverIdLoginSDK.getAccessToken();
              final String refreshToken = naverIdLoginSDK.getRefreshToken();
              final long expiresAt = naverIdLoginSDK.getExpiresAt();
              final String tokenType = naverIdLoginSDK.getTokenType();

              try {
                WritableMap response = Arguments.createMap();
                response.putString("accessToken", accessToken);
                response.putString("refreshToken", refreshToken);
                response.putString("expiresAt", Long.toString(expiresAt));
                response.putString("tokenType", tokenType);
                // cb.invoke(null, response.toString());
                if (loginAllow) {
                  cb.invoke(null, response);
                  loginAllow = false;
                }
              } catch (Exception je) {
                Log.e(TAG, "Exception: " + je.getMessage());
                if (loginAllow) {
                  cb.invoke(je.getMessage(), null);
                  loginAllow = false;
                }
              }
            }

            @Override
            public void onFailure(int i, String s) {
              String errCode = naverIdLoginSDK.getLastErrorCode().getCode();
              String errDesc = naverIdLoginSDK.getLastErrorDescription();
              String message = "errCode: " + errCode + ", errDesc: " + errDesc;
              Log.e(TAG, message);
              if (loginAllow) {
                cb.invoke(message, null);
                loginAllow = false;
              }
            }

            @Override
            public void onError(int i, String s) {
              this.onFailure(i, s);
            }
          };

          naverIdLoginSDK.authenticate(reactContext, oAuthLoginCallback);
        }
      });
    } catch (Exception je) {
      Log.d(TAG, "Exception: " + je);
    }
  }
}
