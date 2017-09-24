
# react-native-naver-login
React Native 네이버 로그인 라이브러리 입니다.
Tutorial을 곧 업데이트 예정중이나 현재는 NaverLoginExample 폴더 안의
튜토리얼을 확인해주시면 감사하겠습니다.

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
5. include LSApplicationQueriesSchemes 
  - naversearchapp
  - naversearchthirdlogin

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

## Usage
```javascript
import { NaverLogin, getProfile } from 'react-native-naver-login';

// 현재 라이브러리는 3가지의 브릿지 함수로 구현되어 있습니다.
// 1. login
// 2. getProfile
// 3. naverLogin
// NaverLoginExample에 보시면 어떻게 쓰는지 확인할 수 있습니다. 간략한 코드는 아래 기재하겠습니다.

// 우선 네이버 로그인에 필요한 값들을 설정합니다.
const initials = {
	key: 'VN6WKGFQ3pJ0xBXRtlN9',
	secret: 'AHBgzH9ZkM',
	name: 'dooboolab',
	urlScheme: 'dooboolaburlscheme', // only for iOS
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
		const result = await naverLogin(JSON.stringify(initials));
		if (result) {
			const profileResult = await getNaverProfile(result.accessToken);
			result.profile = profileResult;

			// 다음 페이지로 넘어간다.
			this.props.navigation.navigate('Second', {
				result,
			});
		}
	} catch (err) {
		console.log('error');
		console.log(err);
	}
}

```
  
