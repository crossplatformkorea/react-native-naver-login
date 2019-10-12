import { NativeModules, Platform } from 'react-native';

const { IosNaverLogin, RNNaverLogin } = NativeModules; // 여기 이름은 달라야 함.

// const getNaverProfile = {}

export interface ICallback<T> {
  (error: Error | undefined, result: T | undefined): void;
}

const NaverLoginIos = {
  login(param: string, callback: ICallback<string>) {
    IosNaverLogin.login(JSON.stringify(param), callback);
  },
  logout() {
    IosNaverLogin.logout();
  },
};

const RNNaverLoginAndr = {
  login(param: string, callback: ICallback<string>) {
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
