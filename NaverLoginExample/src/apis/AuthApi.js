import { Alert, AsyncStorage, NativeModules, Platform } from 'react-native';
// Below is version for real module test
import { NaverLogin, getProfile } from '@react-native-seoul/naver-login';

// version for local example test
// const AuthAndroid = NativeModules.ReactNaverModule;
// const AuthIOS = NativeModules.ReactIosAuth;

const naverLogin = (props) => {
  return new Promise(function(resolve, reject) {
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
};

const getNaverProfile = async (token) => {
  let result = null;
  try {
    result = await getProfile(token);
  } catch (err) {
    console.log('err');
    console.log(err);
  }
  return result;
};

module.exports = {
  naverLogin,
  naverLogout,
  getNaverProfile,
};
