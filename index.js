
import { NativeModules, Platform } from 'react-native';

const { RNNaverLogin } = NativeModules;

export default RNNaverLogin;

// const AuthAndroid = NativeModules.ReactAuthModule;
const IosNaverLogin = NativeModules.RNNaverLogin;

export async function startNaverLogin(keyObj) {
  // keyObj = { kServiceAppUrlScheme, kConsumerKey, kConsumerSecret, kServiceAppName }

  if (Platform.OS === 'ios') {
    IosNaverLogin.startNaverAuth(keyObj, (err, token) => {

      console.log(`\n\n   Token is fetched from iOS :: ${token} \n\n`);

    });
  } else {
    // Android Part ..
  }
};
