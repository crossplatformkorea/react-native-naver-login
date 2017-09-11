import { AsyncStorage, Alert, NativeModules, Platform, } from 'react-native';

// version for local example test
// const AuthAndroid = NativeModules.ReactNaverModule;
// const AuthIOS = NativeModules.ReactIosAuth;

// Below is version for real module test
import RNNaverLogin from 'react-native-naver-login';


const naverLogin = (initials) => {
  return new Promise(function (resolve, reject) {
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
      // AuthAndroid.naverLogin(initials, (err, response) => {
      //   if (err) {
      //     reject(err);
      //     return;
      //   }
      //   console.log('response');
      //   console.log(response);
      //   resolve(JSON.parse(response));
      // });
      RNNaverLogin.naverLogin(initials, (err, response) => {
        if (err) {
          reject(err);
          return;
        }
        console.log('response');
        console.log(response);
        resolve(JSON.parse(response));
      });
    }
  });
};

const naverLogout = () => {
  if (Platform.OS === 'ios') {
    console.log(' iOS Naver Logout ');
  } else {
    AuthAndroid.naverLogout();
  }
}

module.exports = {
  naverLogin,
  naverLogout,
};
