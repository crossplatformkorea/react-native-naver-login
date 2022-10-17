# @react-native-seoul/naver-login

[![npm version](http://img.shields.io/npm/v/@react-native-seoul/naver-login.svg?style=flat-square)](https://npmjs.org/package/@react-native-seoul/naver-login)
[![downloads](http://img.shields.io/npm/dm/@react-native-seoul/naver-login.svg?style=flat-square)](https://npmjs.org/package/@react-native-seoul/naver-login)
[![license](http://img.shields.io/npm/l/@react-native-seoul/naver-login.svg?style=flat-square)](https://npmjs.org/package/@react-native-seoul/naver-login)

React Native 네이버 로그인 라이브러리 입니다. 자세한 예제는 [NaverLoginExample](https://github.com/react-native-seoul/react-native-naver-login/tree/main/NaverLoginExample)에서 확인 가능합니다

`typescript`와 `flow`를 지원합니다

## Getting started

`$ npm install @react-native-seoul/naver-login --save`  
또는  
`$ yarn add @react-native-seoul/naver-login`

### Mostly automatic installation

#### RN version < 0.60

`$ react-native link @react-native-seoul/naver-login`

#### RN version >= 0.60 

- [Autolinking](https://github.com/react-native-community/cli/blob/main/docs/autolinking.md)이 지원됩니다.
- iOS의 경우 추가적으로 pod install이 필요합니다.

    `cd ios && pod install && cd .. # CocoaPods on iOS needs this extra step`

### Manual installation (Post installation) ❗️Important

#### iOS

프로젝트 링크(Xcode project 와 Build Phase에 libRNNaverLogin.a 파일 링크)는 react-native link 명령어를 통하여 세팅이 되며 추가적인 세팅, 주의사항은 아래와 같습니다.

1. [info.plist] 파일 LSApplicationQueriesSchemes 항목에 아래 항목을 추가합니다.

```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
     <string>naversearchapp</string>
     <string>naversearchthirdlogin</string>
   </array>
```

- 세팅 후 Facebook 관련 세팅을 할 때 이 항목이 지워지는 경우가 있습니다.

2. [네이버 문서](https://developers.naver.com/docs/login/ios/)와 같이 세팅 페이지의 info 탭의 URL Types 에 URL Schemes 를 추가합니다(공식문서를 자세히 읽어볼 것을 추천드립니다)
3. AppDelegate 클래스에 추가되는 세팅은 매뉴얼로 하셔야 합니다.([예제 프로젝트](https://github.com/react-native-seoul/react-native-naver-login/blob/main/NaverLoginExample/ios/NaverLoginExample/AppDelegate.m)를 참고 하세요)
   `[application: openURL: options]` 에서는 `if ([url.scheme isEqualToString:@"your_apps_urlscheme"])` 을 통하여 이 함수를 사용하는 다른 액션과 구별하시면 됩니다.
   
   ```objc
   #import <NaverThirdPartyLogin/NaverThirdPartyLoginConnection.h>
   ```

   네이버 로그인만 사용하는 경우
   
   ```objc
   - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
      return [[NaverThirdPartyLoginConnection getSharedInstance] application:app openURL:url options:options];
   }
   ```
   
   구글 로그인 등과 같이 사용하는 경우

   ```objc
   - (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
     if ([url.scheme isEqualToString:@"your_apps_urlscheme"]) {
       return [[NaverThirdPartyLoginConnection getSharedInstance] application:application openURL:url options:options];
     }
  
     return [RNGoogleSignin application:application openURL:url options:options];
   }
   ```
4. 인증방법

- 네이버 앱으로 인증하는 방식을 활성화하려면 앱 델리게이트 `didFinishLaunchingWithOptions` 메소드 내부에 다음 코드를 추가합니다.

```objc
#import <NaverThirdPartyLogin/NaverThirdPartyLoginConnection.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { ... }
```

```objc
[[NaverThirdPartyLoginConnection getSharedInstance] setIsNaverAppOauthEnable:YES];
```

- SafariViewContoller에서 인증하는 방식을 활성화하려면 다음 코드를 추가합니다.

```objc
[[NaverThirdPartyLoginConnection getSharedInstance] setIsInAppOauthEnable:YES];
```

#### Android

RN >= 0.60에서는 Autolinking이 지원되어 proguard를 제외한 별도의 설정이 필요하지 않습니다.

1. Open up `android/app/src/main/java/[...]/MainApplication.java`

- Add `import com.dooboolab.naverlogin.RNNaverLoginPackage;` to the imports at the top of the file
- Add `new RNNaverLoginPackage()` to the list returned by the `getPackages()` method

  ```java
  List<ReactPackage> packages = new PackageList(this).getPackages();
  packages.add(new RNNaverLoginPackage());
  ```

2. Append the following lines to `android/settings.gradle`:

   ```gradle
   include ':react-native-seoul-naver-login'
   project(':react-native-seoul-naver-login').projectDir = new File(rootProject.projectDir, 	'../node_modules/@react-native-seoul/naver-login/android')
   ```

3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:

   ```gradle
    implementation project(':react-native-seoul-naver-login')
   ```

### Additional Check in Android

1. `app/build.gradle file` => `defaultConfig` 에 `applicationId`가 셋팅 되어 있는지 확인하세요

```gradle
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

```gradle
android {
    lintOptions {
        checkReleaseBuilds false
        // Or, if you prefer, you can continue to check for errors in release builds,
        // but continue the build even when errors are found:
        abortOnError false
    }
}
```

3. Proguard 적용 제외 설정
   네이버 아이디로 로그인 라이브러리는 ProGuard로 코드 난독화를 적용하면 안 됩니다. 네이버 아이디로 로그인 라이브러리를 사용하는 애플리케이션을 .apk 파일로 빌드할 때 ProGuard를 적용한다면, 다음과 같이 proguard-project.txt 파일을 수정해 ProGuard 적용 대상에서 네이버 아이디로 로그인 라이브러리 파일을 제외합니다. 라이브러리 파일의 이름과 폴더는 버전이나 개발 환경에 따라 다를 수 있습니다. (혹은 proguard-rules.pro)

```
-keep public class com.nhn.android.naverlogin.** {
       public protected *;
}
```

4. `MainActivity`에 SDK 초기화 설정

```kotlin
class MainActivity : ReactActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        RNNaverLoginModule.initialize(this)
```

#### Methods

| Func       |  Param   |  Return   | Description      |
| :--------- | :------: | :-------: | :--------------- |
| login      | `Object` | `Promise` | 로그인.          |
| getProfile | `String` | `Promise` | 프로필 불러오기. |
| logout     |          |           | 로그아웃.        |

## Usage

- 자세한 예제는 [NaverLoginExample](https://github.com/react-native-seoul/react-native-naver-login/tree/main/NaverLoginExample)에서 확인하세요

```javascript
import React from "react";
import {
  Alert,
  SafeAreaView,
  StyleSheet,
  Button,
  Platform
} from "react-native";
import { NaverLogin, getProfile } from "@react-native-seoul/naver-login";

const iosKeys = {
  kConsumerKey: "VC5CPfjRigclJV_TFACU",
  kConsumerSecret: "f7tLFw0AHn",
  kServiceAppName: "테스트앱(iOS)",
  kServiceAppUrlScheme: "testapp" // only for iOS
};

const androidKeys = {
  kConsumerKey: "QfXNXVO8RnqfbPS9x0LR",
  kConsumerSecret: "6ZGEYZabM9",
  kServiceAppName: "테스트앱(안드로이드)"
};

const initials = Platform.OS === "ios" ? iosKeys : androidKeys;

const App = () => {
  const [naverToken, setNaverToken] = React.useState(null);

  const naverLogin = props => {
    return new Promise((resolve, reject) => {
      NaverLogin.login(props, (err, token) => {
        console.log(`\n\n  Token is fetched  :: ${token} \n\n`);
        setNaverToken(token);
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
    setNaverToken("");
  };

  const getUserProfile = async () => {
    const profileResult = await getProfile(naverToken.accessToken);
    if (profileResult.resultcode === "024") {
      Alert.alert("로그인 실패", profileResult.message);
      return;
    }
    console.log("profileResult", profileResult);
  };

  return (
    <SafeAreaView style={styles.container}>
      <Button
        title="네이버 아이디로 로그인하기"
        onPress={() => naverLogin(initials)}
      />
      {!!naverToken && <Button title="로그아웃하기" onPress={naverLogout} />}

      {!!naverToken && (
        <Button title="회원정보 가져오기" onPress={getUserProfile} />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "space-evenly",
    alignItems: "center"
  }
});

export default App;
```
