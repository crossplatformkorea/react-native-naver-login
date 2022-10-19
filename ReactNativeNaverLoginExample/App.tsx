import React, {useState} from 'react';
import {Alert, SafeAreaView, Button, View, Text} from 'react-native';
import {
  NaverLogin,
  getProfile,
  NaverLoginResponse,
} from '@react-native-seoul/naver-login';

const consumerKey = 'UHpUrWB3eVuQz28e9x6v';
const consumerSecret = 'BF48UHwLU2';
const appName = 'Hello';
const serviceUrlScheme = 'testapp';

const App = () => {
  const [success, setSuccessResponse] =
    useState<NaverLoginResponse['successResponse']>();
  const [error, setErrorResponse] =
    useState<NaverLoginResponse['errorResponse']>();

  const naverLogin = async () => {
    const {errorResponse, successResponse} = await NaverLogin.login({
      appName,
      consumerKey,
      consumerSecret,
      serviceUrlScheme,
    });
    setSuccessResponse(successResponse);
    setErrorResponse(errorResponse);
  };

  const naverLogout = async () => {
    try {
      await NaverLogin.logout();
    } catch (e) {
      console.error(e);
    }
  };

  const getUserProfile = async () => {
    const profileResult = await getProfile(success!.accessToken);
    if (profileResult.resultcode === '024') {
      Alert.alert('로그인 실패', profileResult.message);
      return;
    }
    console.log('profileResult', profileResult);
  };

  return (
    <SafeAreaView
      style={{alignItems: 'center', justifyContent: 'center', flex: 1}}>
      <Button title="Sign in with Naver" onPress={naverLogin} />
      <Gap />
      {success ? (
        <>
          <Button title="Logout" onPress={naverLogout} />
          <Gap />
          <Button title="Get Profile" onPress={getUserProfile} />
          <Gap />
        </>
      ) : null}
      <Text>{JSON.stringify(success || {}, null, 2)}</Text>
      <Gap />
      <Text>{JSON.stringify(error || {}, null, 2)}</Text>
    </SafeAreaView>
  );
};
const Gap = () => <View style={{marginTop: 24}} />;

export default App;
