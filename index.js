import { NativeModules, Platform } from 'react-native';

const { IosNaverLogin, RNNaverLogin } = NativeModules; // 여기 이름은 달라야 함.

// const getNaverProfile = {}


const NaverLoginIos = {
  login(param, callback) {
    IosNaverLogin.login(JSON.parse(param), callback);
  },
  logout() {
    IosNaverLogin.logout();
  }
}

const getProfile = (token) => {
  return fetch('https://openapi.naver.com/v1/nid/me', {
    method: 'GET',
    headers: {
      Authorization: 'Bearer ' + token,
    },
  }).then((response) => response.json()).then((responseJson) => {
    return responseJson;
  }).catch((err) => {
    console.log('getProfile err');
    console.log(err);
  });
};

const NaverLogin = Platform.OS === 'ios'
  ? NaverLoginIos
  : RNNaverLogin;

module.exports = { NaverLogin, getProfile }
