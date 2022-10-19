import React, {useState} from 'react';
import {Alert, SafeAreaView, Button, View, Text} from 'react-native';
import NaverLogin, {NaverLoginResponse} from '@react-native-seoul/naver-login';

const consumerKey = '';
const consumerSecret = '';
const appName = 'Hello';
const serviceUrlScheme = '';

const App = () => {
  const [success, setSuccessResponse] =
    useState<NaverLoginResponse['successResponse']>();
  const [failure, setFailureResponse] =
    useState<NaverLoginResponse['failureResponse']>();

  const login = async () => {
    const {failureResponse, successResponse} = await NaverLogin.login({
      appName,
      consumerKey,
      consumerSecret,
      serviceUrlScheme,
    });
    setSuccessResponse(successResponse);
    setFailureResponse(failureResponse);
  };

  const logout = async () => {
    try {
      await NaverLogin.logout();
      setSuccessResponse(undefined);
      setFailureResponse(undefined);
    } catch (e) {
      console.error(e);
    }
  };

  const getProfile = async () => {
    const profileResult = await NaverLogin.getProfile(success!.accessToken);
    if (profileResult.resultcode === '024') {
      Alert.alert('로그인 실패', profileResult.message);
      return;
    }
    console.log('profileResult', profileResult);
  };

  const deleteToken = async () => {
    try {
      await NaverLogin.deleteToken();
      setSuccessResponse(undefined);
      setFailureResponse(undefined);
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <SafeAreaView
      style={{alignItems: 'center', justifyContent: 'center', flex: 1}}>
      <Button
        title={success ? 'Logout' : 'Sign in with Naver'}
        onPress={success ? logout : login}
      />
      <Gap />
      {success ? (
        <>
          <Button title="Get Profile" onPress={getProfile} />
          <Gap />
        </>
      ) : null}
      {success ? (
        <View style={{paddingHorizontal: 24}}>
          <Button title="Delete Token" onPress={deleteToken} />
          <Gap />
          <Text style={{fontSize: 20, fontWeight: 'bold'}}>성공 응답</Text>
          <Text>{JSON.stringify(success, null, 2)}</Text>
        </View>
      ) : null}
      <Gap />
      {failure ? (
        <View style={{paddingHorizontal: 24}}>
          <Text style={{fontSize: 20, fontWeight: 'bold'}}>실패 응답</Text>
          <Text>{JSON.stringify(failure, null, 2)}</Text>
        </View>
      ) : null}
    </SafeAreaView>
  );
};
const Gap = () => <View style={{marginTop: 24}} />;

export default App;
