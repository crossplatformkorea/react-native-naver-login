# react-native-naver-login
<p align="left">
  <a href="https://npmjs.org/package/react-native-naver-login"><img alt="npm version" src="http://img.shields.io/npm/v/react-native-naver-login.svg?style=flat-square"></a>
  <a href="https://npmjs.org/package/react-native-naver-login"><img alt="npm version" src="http://img.shields.io/npm/dm/react-native-naver-login.svg?style=flat-square"></a>
  <a href="https://npmjs.org/package/react-native-naver-login"><img alt="npm version" src="http://img.shields.io/npm/dm/react-native-naver-login.svg?style=flat-square"></a>
</p>
React Native 네이버 로그인 라이브러리 입니다.
Tutorial을 곧 업데이트 예정중이나 현재는 NaverLoginExample 폴더 안의
튜토리얼을 확인해주시면 감사하겠습니다.

Repository 주소: https://github.com/dooboolab/react-native-naver-login

## Getting started

`$ npm install react-native-naver-login --save`

### Mostly automatic installation

`$ react-native link react-native-naver-login`

### Manual installation


#### iOS

프로젝트 링크(Xcode project 와 Build Phase에 libRNNaverLogin.a 파일 링크)는 react-native link 명령어를 통하여 세팅이 되며 추가적인 세팅, 주의사항은 아래와 같습니다.

1. [info.plist] 파일 LSApplicationQueriesSchemes 항목에 아래 항목을 추가합니다.
  - naversearchapp
  - naversearchthirdlogin
  * 세팅 후 Facebook 관련 세팅을 할 때 이 항목이 지워지는 경우가 있습니다.
2. 네이버 문서와 같이 세팅 페이지의 info 탭의 URL Types 에 URL Schemes 를 추가합니다.
3. AppDelegate 클래스에 추가되는 세팅은 매뉴얼로 하셔야 합니다.
  [application: openURL: options] 에서는  if ([url.scheme isEqualToString:@"your_apps_urlscheme"]) 을 통하여 이 함수를 사용하는 다른 액션과 구별하시면 됩니다.
4. NLoginThirdPartyOAuth20InAppBrowserViewController.m 파일의 다음 2군데에서 Crash 가 날 때가 있습니다.
  이 부분은 웹뷰를 띄울 경우 언어별 메시지를 표시하는 부분입니다만 에러가 나는 경우가 있어 현재는 영어로 표시했습니다.
```
  bannerMessage.text = kNaverAuthBannerMessage;
  NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:kNaverAuthBannerDownloadLink];

```

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.dooboolab.naverlogin.RNNaverLoginPackage;` to the imports at the top of the file
  - Add `new RNNaverLoginPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-naver-login'
  	project(':react-native-naver-login').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-naver-login/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-naver-login')
  	```

### Additional Check in Android
1. Check if applicationId is set in your defaultConfig in app/build.gradle file.
```
android {
    compileSdkVersion 23
    buildToolsVersion "23.0.3"
    ...

    defaultConfig {
        applicationId "com.my.app.name"
        ...
}
```
2. Build 과정에서 WrongManifestParent 에러 발생 시 (로그에 나오는 대로)아래 코드를 app/build.gradle 에 추가해 줍니다.
```
android {
    lintOptions {
        checkReleaseBuilds false
        // Or, if you prefer, you can continue to check for errors in release builds,
        // but continue the build even when errors are found:
        abortOnError false
    }
}
```
3. 필요하면 Manifest 파일에 Activity 를 추가합니다.
```
<activity
  android:name="com.nhn.android.naverlogin.ui.OAuthLoginActivity"
  android:screenOrientation="portrait"
  android:theme="@android:style/Theme.Translucent.NoTitleBar" />
<activity
  android:name="com.nhn.android.naverlogin.ui.OAuthLoginInAppBrowserActivity"
  android:label="OAuth2.0 In-app"
  android:screenOrientation="portrait" />
```

#### Methods
| Func  | Param  | Return | Description |
| :------------ |:---------------:| :---------------:| :-----|
| login | `Object` | `Promise` | 로그인. |
| getProfile | `String` | `Promise` | 프로필 불러오기. |
| logout |  |  | 로그아웃. |

## Usage
* 실제 예는 다음 소스를 참고하세요.
* https://github.com/dooboolab/react-native-naver-login/blob/master/NaverLoginExample/src/components/pages/First/index.js

```javascript

import { NaverLogin, getProfile } from 'react-native-naver-login';

// 현재 라이브러리는 3가지의 브릿지 함수로 구현되어 있습니다.
// 1. login
// 2. getProfile
// 3. naverLogin
// NaverLoginExample에 보시면 어떻게 쓰는지 확인할 수 있습니다. 간략한 코드는 아래 기재하겠습니다.

// 우선 네이버 로그인에 필요한 값들을 설정합니다.
console.log('Naver Login');
const initials = {
  kConsumerKey: 'VN6WKGFQ3pJ0xBXRtlN9',
  kConsumerSecret: 'AHBgzH9ZkM',
  kServiceAppName: 'dooboolab',
  kServiceAppUrlScheme: 'dooboolaburlscheme', // only for iOS
};

const naverLogin = (props) => {
  return new Promise(function (resolve, reject) {
    console.log(props);
    NaverLogin.login(props, (err, token) => {
      console.log(`\n\n  Token is fetched  :: ${token} \n\n`);
      if (err) {
        reject(err);
        return;
      }
      resolve(token);
    });
  });
};

const naverLogout = () => {
  NaverLogin.logout();
}

const getNaverProfile = async(token) => {
  let result = null;
  try {
    result = await getProfile(token);
  } catch (err) {
    console.log('err');
    console.log(err);
  }
  return result;
}

// 위와 같이 함수를 짜주고 아래서 사용한다.
onNaverLogin = async() => {
  try {
    const result = await naverLogin(initials);
    console.log('token: ' + result);

    if (result) {
      console.log('yes result');
      const profileResult = await getNaverProfile(result);
      console.log('profile');
      console.log(profileResult);
      if (profileResult.resultcode === '024') {
        Alert.alert('로그인 실패', profileResult.message);
        return;
      }

      result.profile = profileResult;

      // 성공시 다음 페이지로 넘어간다.
      this.props.navigation.navigate('Second', {
        result,
        profileResult,
      });
    } else {
      console.log('no result');
    }
  } catch (err) {
    console.log('error');
    console.log(err);
  }
}

```
