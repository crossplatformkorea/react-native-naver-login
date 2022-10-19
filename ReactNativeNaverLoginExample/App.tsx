import React, {useState} from 'react';
import {Alert, SafeAreaView, Button, View, Text} from 'react-native';
import NaverLogin, {NaverLoginResponse} from '@react-native-seoul/naver-login';

const consumerKey = 'UHpUrWB3eVuQz28e9x6v';
const consumerSecret = 'BF48UHwLU2';
const appName = 'Hello';
const serviceUrlScheme = 'navertest';

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
      setSuccessResponse(undefined);
      setErrorResponse(undefined);
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
      <Button
        title={success ? 'Logout' : 'Sign in with Naver'}
        onPress={success ? naverLogout : naverLogin}
      />
      <Gap />
      {success ? (
        <>
          <Button title="Get Profile" onPress={getUserProfile} />
          <Gap />
        </>
      ) : null}
      {success ? (
        <View style={{paddingHorizontal: 24}}>
          <Text style={{fontSize: 20, fontWeight: 'bold'}}>성공 응답</Text>
          <Text>{JSON.stringify(success, null, 2)}</Text>
        </View>
      ) : null}
      <Gap />
      {error ? (
        <View style={{paddingHorizontal: 24}}>
          <Text style={{fontSize: 20, fontWeight: 'bold'}}>실패 응답</Text>
          <Text>{JSON.stringify(error, null, 2)}</Text>
        </View>
      ) : null}
    </SafeAreaView>
  );
};
const Gap = () => <View style={{marginTop: 24}} />;

export default App;
