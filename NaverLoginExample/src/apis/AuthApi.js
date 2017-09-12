import { AsyncStorage, Alert, NativeModules, Platform, } from 'react-native';

// version for local example test
// const AuthAndroid = NativeModules.ReactNaverModule;
// const AuthIOS = NativeModules.ReactIosAuth;

// Below is version for real module test
import RNNaverLogin from 'react-native-naver-login';


const naverLogin = (initials) => {
  return new Promise(function (resolve, reject) {
    /*
      야래 코드는 develop용으로 사용한다.
    */
    if (Platform.OS === 'ios') {
      console.log(' iOS Naver Login ');
      // AuthIOS.startNaverAuth(initials, (err, token) => {
      //   Alert.alert(token);
      //   if (err) {
      //     reject(err);
      //     return;
      //   }
        //resolve(JSON.parse(response)); 토큰을 파싱할 때 에러..
      // });
    } else {
      // AuthAndroid.login(initials, (err, response) => {
      //   if (err) {
      //     reject(err);
      //     return;
      //   }
      //   console.log('response');
      //   console.log(response);
      //   resolve(JSON.parse(response));
      // });
    }
    /*
      퍼블리싱 라이브러리 소스는 따로 ios와 android 구분없이 만들기로 한다.
    */
    RNNaverLogin.login(initials, (err, response) => {
      if (err) {
        reject(err);
        return;
      }
      console.log('response');
      console.log(response);
      resolve(JSON.parse(response));
    });
  });
};

const naverLogout = () => {
  RNNaverLogin.logout();
}

const getNaverProfile = (token) => {
  return new Promise(function (resolve, reject) {
    RNNaverLogin.getProfile(token, (err, response) => {
      if (err) {
        reject(err);
        return;
      }
      console.log('response');
      console.log(response);
      resolve(JSON.parse(response));
    });
  });
}

module.exports = {
  naverLogin,
  naverLogout,
  getNaverProfile,
};
