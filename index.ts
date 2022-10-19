import { NativeModules, Platform } from "react-native";

const { RNNaverLogin } = NativeModules;

export interface NaverLoginRequest {
  consumerKey: string;
  consumerSecret: string;
  appName: string;
  /** Only for iOS */
  serviceUrlScheme?: string;
}
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

const login = ({
  appName,
  consumerKey,
  consumerSecret,
  serviceUrlScheme,
}: NaverLoginRequest): Promise<NaverLoginResponse> =>
  Platform.OS === "ios"
    ? RNNaverLogin.login(serviceUrlScheme, consumerKey, consumerSecret, appName)
    : RNNaverLogin.login(consumerKey, consumerSecret, appName);
const logout = (): Promise<void> => RNNaverLogin.logout();

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

const getProfile = (token: string): Promise<GetProfileResponse> => {
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

const NaverLogin = {
  login,
  logout,
  getProfile,
};
export default NaverLogin;
