import { NativeModules, Platform } from 'react-native';

const { IosNaverLogin } = NativeModules; // 여기 이름은 달라야 함.

const RNNaverLogin = {
  login(param, callback) {
    if (Platform.OS === 'ios') {
      IosNaverLogin.login(param, callback);
    } else {
      // Android Login..
    }
  },
  logout() {
    if (Platform.OS === 'ios') {
      IosNaverLogin.logout();
    } else {
      // Android Login..
    }
  }
}

module.exports = { RNNaverLogin }
