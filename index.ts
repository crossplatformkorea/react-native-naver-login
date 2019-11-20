import { NativeModules, Platform } from 'react-native';

const { IosNaverLogin, RNNaverLogin } = NativeModules; // 여기 이름은 달라야 함.

// const getNaverProfile = {}

export interface ICallback<T> {
  (error: Error | undefined, result: T | undefined): void;
}


export interface ConfigParam {
    kConsumerKey: string
    kConsumerSecret: string
    kServiceAppName: string
    
    /** Only for iOS */
    kServiceAppUrlScheme?: string
}

const NaverLoginIos = {
  login(param: ConfigParam, callback: ICallback<string>) {
    IosNaverLogin.login(JSON.stringify(param), callback);
  },
  logout() {
    IosNaverLogin.logout();
  },
};

const RNNaverLoginAndr = {
  login(param: ConfigParam, callback: ICallback<string>) {
    RNNaverLogin.login(JSON.stringify(param), callback);
  },
  logout() {
    RNNaverLogin.logout();
  },
};

export const getProfile = (token: string): Promise<Response> => {
  return fetch('https://openapi.naver.com/v1/nid/me', {
    method: 'GET',
    headers: {
      Authorization: 'Bearer ' + token,
    },
  })
    .then((response) => response.json())
    .then((responseJson) => {
      return responseJson;
    })
    .catch((err) => {
      console.log('getProfile err');
      console.log(err);
    });
};

export const NaverLogin =
  Platform.OS === 'ios' ? NaverLoginIos : RNNaverLoginAndr;
