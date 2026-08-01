# @react-native-seoul/naver-login

[![npm version](http://img.shields.io/npm/v/@react-native-seoul/naver-login.svg)](https://npmjs.org/package/@react-native-seoul/naver-login)
![Android SDK - 5.9.1](https://img.shields.io/badge/Android_SDK-5.9.1-2ea44f)
![iOS SDK - 4.2.3](https://img.shields.io/badge/iOS_SDK-4.2.3-3522ff)

[![downloads](http://img.shields.io/npm/dm/@react-native-seoul/naver-login.svg)](https://npmjs.org/package/@react-native-seoul/naver-login)
[![license](http://img.shields.io/npm/l/@react-native-seoul/naver-login.svg)](https://npmjs.org/package/@react-native-seoul/naver-login)

React Native 네이버 로그인 라이브러리 입니다.

## Supported platforms

![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

## Supported typing

- TypeScript
- Flow

<img alt="screenshots" src="https://user-images.githubusercontent.com/33388801/196834333-69841305-ebd2-4b59-b02b-b079aafd7523.gif" width=400 />

## Installation

> ❗️ `2.x` 버전은 [2.x branch](https://github.com/react-native-seoul/react-native-naver-login/tree/2.x) 의 설치 가이드와 사용법을 따라주세요.

```shell
# npm
npm install @react-native-seoul/naver-login --save

# yarn
yarn add @react-native-seoul/naver-login
```

### RN version >= `0.60`

- Auto Linking 이 적용됩니다.
- iOS의 경우 추가적으로 Cocoapods 설치가 필요합니다.

```shell
cd ios && pod install
```

### RN version < `0.60`

- `0.60` 미만의 React Native를 사용중이시라면 [Manual Linking Guide](./README-manual-linking.md)를 참고해주세요.

## Configuration

### `initialize` 함수 호출

다음과 같이 앱의 `index.js`나 로그인이 필요한 시점 전에 초기화 함수를 호출합니다.

```tsx
NaverLogin.initialize({
  appName,
  consumerKey,
  consumerSecret,
  serviceUrlSchemeIOS,
  disableNaverAppAuthIOS: true,
});
```

### 추가 작업 - iOS 🍎

#### 1. Launch Service Queries Schemes 추가

로그인 시에 네이버 앱을 실행시키기 위해 [Launch Services Queries Schemes](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/LaunchServicesKeys.html) 를 등록해주어야 합니다.

`Info.plist` 파일안에 다음과 같은 항목을 추가합니다.

- `naversearchapp`
- `naversearchthirdlogin`

이미 `LSApplicationQueriesSchemes` 가 항목으로 추가되어 있다면, `<array>` 안에 두 가지만 더 추가해주세요.

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>naversearchapp</string>
  <string>naversearchthirdlogin</string>
</array>
```

![image](https://user-images.githubusercontent.com/33388801/196834997-40ca2368-50e6-45cb-9b68-2cf5307fd792.png)

#### 2. custom URL scheme 추가

네이버 로그인이 완료된 뒤 다시 우리의 앱으로 돌아오기 위해 `URL Scheme`를 `Info.plist` 에 정의해주어야 합니다.

아래 코드들에서 `{{ CUSTOM URL SCHEME }}`는 커스텀하게 정의할 우리 앱에 사용될 URL scheme라고 생각하시면 됩니다.

주의할 점은 다음과 같습니다.

- 네이버 개발자 콘솔에 기입한 `URL Scheme`와 동일해야 합니다.
- `initialize` 함수 호출시에 `serviceUrlSchemeIOS` 로 동일하게 전달해주어야 합니다.

대략 다음과 같이 `Info.plist`에 입력되게 됩니다.

```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>naver</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>{{ CUSTOM URL SCHEME }}</string>
		</array>
	</dict>
	...
</array>
```
![image](https://user-images.githubusercontent.com/33388801/196835050-3d887f3c-1d07-4be3-a2cf-27ed18a48691.png)

p.s 
Info.plist에 naversearchapp 추가해도 작동이 안된다면 최대개수를 넘은걸 수 있습니다.(최대수 50개)
참조) https://developer.apple.com/documentation/uikit/uiapplication/canopenurl(_:)
<img width="1674" height="422" alt="image" src="https://github.com/user-attachments/assets/b8252109-4e35-46b6-b59a-79b0f1eea651" />

```xml
<array>
    ...
    <string>naversearchapp</string> // 51번째일때에 미작동
</array>
```

#### 3. `AppDelegate`의 `application:openURL:options` 에서 URL 핸들링 로직 추가

네이버 로그인이 성공한 후 우리앱으로 다시 돌아와 URL을 처리하기 위해 필요한 과정입니다.

- 다른 URL 핸들링 로직이 없는경우

```objc
#import <NaverThirdPartyLogin/NaverThirdPartyLoginConnection.h>
...
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
   return [[NaverThirdPartyLoginConnection getSharedInstance] application:application openURL:url options:options];
}
```

- 다른 URL 핸들링 로직이 같이 있는 경우

```objc
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  // naver
  if ([url.scheme isEqualToString:@"{{ CUSTOM URL SCHEME }}"]) {
    return [[NaverThirdPartyLoginConnection getSharedInstance] application:application openURL:url options:options];
  }

  // kakao
  if([RNKakaoLogins isKakaoTalkLoginUrl:url]) {
    return [RNKakaoLogins handleOpenUrl: url];
  }
  ...
}
```

- AppDelegate.swift 사용 시

```swift
import NaverThirdPartyLogin

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
  // naver
  if url.scheme == "{{ CUSTOM URL SCHEME }}" {
    return NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
  }
}
```

### 추가 작업 - Android 🤖

#### 1. Proguard

만약 Release build에서 R8 컴파일러를 이용해 code obfuscating을 하신다면, app/build.gradle 설정에 `minifyEnabled`이 `true`로 설정이 되어있을 것입니다.

그 경우 다음과 같은 Proguard 규칙이 필요합니다.

만약 그렇지 않다면 별도의 설정이 필요하지 않습니다.

```text
-keep public class com.navercorp.nid.** { *; }
```

> [!NOTE]
> 이 규칙은 확실하지 않으나 Android Native SDK 코드에서 proguard consumer rules가 정의되어있지 않아 삽입된 구문입니다.
>
> 이것을 추가해주었음에도 난독화로 인해 에러가 나는 상황에서는 [OKHttp](https://square.github.io/okhttp/features/r8_proguard/), [Retrofit](https://github.com/square/retrofit/blob/trunk/retrofit/src/main/resources/META-INF/proguard/retrofit2.pro) 라이브러리들의 Proguard Rule들을 직접 같이 추가해주는 것을 추천드립니다.
>
> R8 컴파일러로 안드로이드 프로젝트를 빌드하면 Okhtttp, Retrofit과 같은 라이브러리들은 내부적으로 JAR, AAR에 rule을 포함시켜두었기 때문에 문제가 되지 않아야 정상입니다.

### 추가 작업 - EXPO

1. app.json 파일을 아래와 같이 수정합니다.

```json
{
  "expo": {
    ...
    "plugins": [
      ...,
      [
        "@react-native-seoul/naver-login",
        {
          "urlScheme": "CUSTOM URL SCHEME" // 네이버 url scheme를 적어주세요.
        }
      ]
    ],
    ...
  }
}
```

- Bare workflow의 경우에는 `expo prebuild`를 이용합니다.
- Managed Workflow의 경우에는 EAS Build 이후 `expo start --dev-client`를 이용합니다.

2. (Optional) Android에서 proguard rules 등을 적용하실 경우, [Expo BuildProperties](https://docs.expo.dev/versions/latest/sdk/build-properties/) 를 참고하세요.

## API

| Func         |         Param          |             Return              | Description                      |
| :----------- | :--------------------: | :-----------------------------: | :------------------------------- |
| initialize   | `NaverLoginInitParams` |             `void`              | 네이버 SDK 초기화                |
| login        |                        |  `Promise<NaverLoginResponse>`  | 로그인                           |
| getProfile   |        `String`        |  `Promise<GetProfileResponse>`  | 프로필 불러오기                  |
| getAgreement |        `String`        | `Promise<GetAgreementResponse>` | 약관 동의 대행 동의여부 불러오기 |
| logout       |                        |         `Promise<void>`         | 로그아웃                         |
| deleteToken  |                        |         `Promise<void>`         | 네이버 계정 연동 해제            |

### Type

**NaverLoginInitParams**

```typescript
export interface NaverLoginInitParams {
  consumerKey: string;
  consumerSecret: string;
  appName: string;
  /** (iOS) 네이버앱을 사용하는 인증을 비활성화 한다. (default: false) */
  disableNaverAppAuthIOS?: boolean;
  /** (iOS) */
  serviceUrlSchemeIOS?: string;
}
```

**NaverLoginResponse**

```ts
export interface NaverLoginResponse {
  isSuccess: boolean;
  /** isSuccess가 true일 때 존재합니다. */
  successResponse?: {
    accessToken: string;
    refreshToken: string;
    expiresAtUnixSecondString: string;
    tokenType: string;
  };
  /** isSuccess가 false일 때 존재합니다. */
  failureResponse?: {
    message: string;
    isCancel: boolean;

    /** Android Only */
    lastErrorCodeFromNaverSDK?: string;
    /** Android Only */
    lastErrorDescriptionFromNaverSDK?: string;
  };
}
```

**GetProfileResponse**

```ts
export interface GetProfileResponse {
  resultcode: string;
  message: string;
  response: {
    id: string;
    profile_image: string | null;
    email: string;
    name: string;
    birthday: string | null;
    age: string | null;
    birthyear: number | null;
    gender: string | null;
    mobile: string | null;
    mobile_e164: string | null;
    nickname: string | null;
  };
}
```

**GetAgreementResponse**

```ts
export interface GetAgreementResponse {
  result: string;
  accessToken: string;
  agreementInfos: AgreementInfo[];
}

export interface AgreementInfo {
  termCode: string;
  clientId: string;
  agreeDate: string;
}
```

## Usage

- 자세한 예제는 [예제 프로젝트](./example)를 참고해주세요

```tsx
/** Fill your keys */
const consumerKey = '';
const consumerSecret = '';
const appName = 'testapp';

/** This key is setup in iOS. So don't touch it */
const serviceUrlSchemeIOS = 'navertest';

const App = (): ReactElement => {
  useEffect(() => {
    NaverLogin.initialize({
      appName,
      consumerKey,
      consumerSecret,
      serviceUrlSchemeIOS,
      disableNaverAppAuthIOS: true,
    });
  }, []);

  const [success, setSuccessResponse] =
    useState<NaverLoginResponse['successResponse']>();

  const [failure, setFailureResponse] =
    useState<NaverLoginResponse['failureResponse']>();
  const [getProfileRes, setGetProfileRes] = useState<GetProfileResponse>();

  const login = async (): Promise<void> => {
    const { failureResponse, successResponse } = await NaverLogin.login();
    setSuccessResponse(successResponse);
    setFailureResponse(failureResponse);
  };

  const logout = async (): Promise<void> => {
    try {
      await NaverLogin.logout();
      setSuccessResponse(undefined);
      setFailureResponse(undefined);
      setGetProfileRes(undefined);
    } catch (e) {
      console.error(e);
    }
  };

  const getProfile = async (): Promise<void> => {
    try {
      const profileResult = await NaverLogin.getProfile(success!.accessToken);
      setGetProfileRes(profileResult);
    } catch (e) {
      setGetProfileRes(undefined);
    }
  };

  const deleteToken = async (): Promise<void> => {
    try {
      await NaverLogin.deleteToken();
      setSuccessResponse(undefined);
      setFailureResponse(undefined);
      setGetProfileRes(undefined);
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <SafeAreaView
      style={{ alignItems: 'center', justifyContent: 'center', flex: 1 }}
    >
      <ScrollView
        style={{ flex: 1 }}
        contentContainerStyle={{ flexGrow: 1, padding: 24 }}
      >
        <Button title={'Login'} onPress={login} />
        <Gap />
        <Button title={'Logout'} onPress={logout} />
        <Gap />
        {success ? (
          <>
            <Button title="Get Profile" onPress={getProfile} />
            <Gap />
          </>
        ) : null}
        {success ? (
          <View>
            <Button title="Delete Token" onPress={deleteToken} />
            <Gap />
            <ResponseJsonText name={'Success'} json={success} />
          </View>
        ) : null}
        <Gap />
        {failure ? <ResponseJsonText name={'Failure'} json={failure} /> : null}
        <Gap />
        {getProfileRes ? (
          <ResponseJsonText name={'GetProfile'} json={getProfileRes} />
        ) : null}
      </ScrollView>
    </SafeAreaView>
  );
};
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
