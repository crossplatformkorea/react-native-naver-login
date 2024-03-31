import { NativeModules, Platform } from 'react-native';

const { RNNaverLogin } = NativeModules;

export interface NaverLoginRequest {
  consumerKey: string;
  consumerSecret: string;
  appName: string;
  /** (iOS) 네이버앱을 사용하는 인증을 비활성화 한다. (default: false) */
  disableNaverAppAuth?: boolean;
  /** (iOS) */
  serviceUrlScheme?: string;
}
export interface NaverLoginResponse {
  isSuccess: boolean;
  /** isSuccess가 true일 때 존재합니다. */
  successResponse?: {
    accessToken: string;
    refreshToken: string;
    expiresAtUnixSecondString: string;
    tokenType: string;
  };
  /** isSuccess가 false일 때 존재합니다. */
  failureResponse?: {
    message: string;
    isCancel: boolean;

    /** Android Only */
    lastErrorCodeFromNaverSDK?: string;
    /** Android Only */
    lastErrorDescriptionFromNaverSDK?: string;
  };
}

const login = ({
  appName,
  consumerKey,
  consumerSecret,
  serviceUrlScheme,
  disableNaverAppAuth = false,
}: NaverLoginRequest): Promise<NaverLoginResponse> => {
  console.log(1);
  return Platform.OS === 'ios'
    ? RNNaverLogin.login(
        serviceUrlScheme,
        consumerKey,
        consumerSecret,
        appName,
        disableNaverAppAuth
      )
    : RNNaverLogin.login(consumerKey, consumerSecret, appName);
};

const logout = async (): Promise<void> => {
  await RNNaverLogin.logout();
};

const deleteToken = async (): Promise<void> => {
  await RNNaverLogin.deleteToken();
};

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

const NaverLogin = {
  login,
  logout,
  deleteToken,
  getProfile,
};
export default NaverLogin;
