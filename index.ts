import { NativeModules, Platform } from "react-native";

const { IosNaverLogin, RNNaverLogin } = NativeModules; // 여기 이름은 달라야 함.

export const UserCancelErrorCode = {
  android: 'user_cancel',
  iOS: 2
};

export interface NaverLoginError extends Error {
  errCode?: number | string;
  errDesc?: string;
}

export interface ICallback<T> {
  (error: NaverLoginError | undefined, result: T | undefined): void;
}

export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  expiresAt: string;
  tokenType: string;
}

export interface GetProfileResponse {
  resultcode: string;
  message: string;
  response: {
    id: string;
    profile_image: string | null;
    email: string;
    name: string;
    birthday: string | null;
    age: string | null;
    birthyear: number | null;
    gender: string | null;
    mobile: string | null;
    mobile_e164: string | null;
    nickname: string | null;
  };
}

export interface ConfigParam {
  kConsumerKey: string;
  kConsumerSecret: string;
  kServiceAppName: string;

  /** Only for iOS */
  kServiceAppUrlScheme?: string;
}

const NaverLoginIos = {
  login(param: ConfigParam, callback: ICallback<TokenResponse>): void {
    IosNaverLogin.login(param, callback);
  },
  logout(): void {
    IosNaverLogin.logout();
  },
};

const RNNaverLoginAndr = {
  login(param: ConfigParam, callback: ICallback<TokenResponse>): void {
    RNNaverLogin.login(param, callback);
  },
  logout(): void {
    RNNaverLogin.logout();
  },
};

export const getProfile = (token: string): Promise<GetProfileResponse> => {
  return fetch("https://openapi.naver.com/v1/nid/me", {
    method: "GET",
    headers: {
      Authorization: "Bearer " + token,
    },
  })
    .then((response) => response.json())
    .then((responseJson) => {
      return responseJson;
    })
    .catch((err) => {
      console.log("getProfile err");
      console.log(err);
    });
};

export const NaverLogin =
  Platform.OS === "ios" ? NaverLoginIos : RNNaverLoginAndr;
