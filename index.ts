import { NativeModules, Platform } from "react-native";

const { IosNaverLogin, RNNaverLogin } = NativeModules; // 여기 이름은 달라야 함.

export interface NaverLoginResponse {
  isSuccess: boolean;
  /** isSuccess가 true일 때 존재합니다. */
  successResponse?: {
    accessToken: string;
    refreshToken: string;
    expiresAt: string;
    tokenType: string;
  };
  /** isSuccess가 false일 때 존재합니다. */
  errorResponse?: {
    message: string;
    lastErrorCodeFromNaverSDK: string;
    lastErrorDescriptionFromNaverSDK: string;
    isCancel: boolean;
  };
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
  consumerKey: string;
  consumerSecret: string;
  appName: string;
  /** Only for iOS */
  serviceUrlScheme?: string;
}

const NaverLoginIos = {
  login: async ({
    appName,
    consumerKey,
    consumerSecret,
    serviceUrlScheme,
  }: ConfigParam): Promise<NaverLoginResponse> => {
    try {
      return await IosNaverLogin.login(
        serviceUrlScheme,
        consumerKey,
        consumerSecret,
        appName,
      );
    } catch (e) {
      throw e;
    }
  },
  logout: async (): Promise<void> => {
    await IosNaverLogin.logout();
  },
} as const;

const RNNaverLoginAndr = {
  login: ({
    consumerSecret,
    consumerKey,
    appName,
  }: ConfigParam): Promise<NaverLoginResponse> =>
    RNNaverLogin.login(consumerKey, consumerSecret, appName),
  logout: (): Promise<void> => RNNaverLogin.logout(),
} as const;

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
