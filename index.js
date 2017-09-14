
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

export async function fetchProfile(token) {
  if (Platform.OS === 'ios') {
    IosNaverLogin.fetchProfile(token, (err, profile) => {

      console.log(`\n\n   Profile is fetched from iOS :: ${profile} \n\n`);

    });
  } else {
    // Android Part ..
  }
};
