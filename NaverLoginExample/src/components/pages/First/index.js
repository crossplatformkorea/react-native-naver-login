import React, { Component } from 'react';
import {
  View,
  Text,
  Alert,
} from 'react-native';

import NativeButton from 'apsl-react-native-button';

import Navbar from '../../shared/Navbar';
import styles from './styles';
import { naverLogin, getNaverProfile } from '../../../apis/AuthApi';

class Page extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isNaverLoggingin: false,
    };
  }

  onNaverLogin = async() => {
    console.log('Naver Login');
    const initials = {
      kConsumerKey: 'VN6WKGFQ3pJ0xBXRtlN9',
      kConsumerSecret: 'AHBgzH9ZkM',
      kServiceAppName: 'dooboolab',
      kServiceAppUrlScheme: 'dooboolaburlscheme', // only for iOS
    };

    try {
      const result = await naverLogin(JSON.stringify(initials));
      // const result = await naverLogin(initials);

      // Alert.alert('results');
      console.log('response');
      console.log(result);

      if (result) {
        console.log('yes result');
        const profileResult = await getNaverProfile(result);
        console.log('profile');
        console.log(profileResult);
        if (profileResult.resultcode === '024') {
          Alert.alert('로그인 실패', profileResult.message);
          return;
        }

        result.profile = profileResult;
        this.props.navigation.navigate('Second', {
          result,
          profileResult,
        });
      } else {
        console.log('no result');
      }

    } catch (err) {
      console.log('error');
      console.log(err);
    }
  }

  render() {
    return (
      <View style={ styles.container }>
        <View style={ styles.header }>
          <Navbar>SOCIAL LOGIN</Navbar>
        </View>
        <View style={ styles.content }>
          <NativeButton
            isLoading={this.state.isNaverLoggingin}
            onPress={this.onNaverLogin}
            activeOpacity={0.5}
            style={styles.btnNaverLogin}
            textStyle={styles.txtNaverLogin}
          >NAVER LOGIN</NativeButton>
        </View>
      </View>
    );
  }
}

export default Page;
