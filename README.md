
# react-native-naver-login
React Native 네이버 로그인 라이브러리 입니다.
Tutorial을 곧 업데이트 예정중이나 현재는 NaverLoginExample 폴더 안의
튜토리얼을 확인해주시면 감사하겠습니다.

현재는 안드로이드만 작업되었습니다.

## Getting started

`$ npm install react-native-naver-login --save`

### Mostly automatic installation

`$ react-native link react-native-naver-login`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-naver-login` and add `RNNaverLogin.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNNaverLogin.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

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

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNNaverLogin.sln` in `node_modules/react-native-naver-login/windows/RNNaverLogin.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Naver.Login.RNNaverLogin;` to the usings at the top of the file
  - Add `new RNNaverLoginPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNNaverLogin from 'react-native-naver-login';

// TODO: What to do with the module?
RNNaverLogin;
```
  