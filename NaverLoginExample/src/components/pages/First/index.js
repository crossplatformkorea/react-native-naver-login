import { Alert, Text, View } from 'react-native';
import { NaverLogin, getProfile } from 'react-native-naver-login';
import React, { Component } from 'react';

import NativeButton from 'apsl-react-native-button';
import Navbar from '../../shared/Navbar';
import styles from './styles';

// import { naverLogin, getNaverProfile } from '../../../apis/AuthApi';

const initials = {
  kConsumerKey: 'VN6WKGFQ3pJ0xBXRtlN9',
  kConsumerSecret: 'AHBgzH9ZkM',
  kServiceAppName: 'dooboolab',
  kServiceAppUrlScheme: 'dooboolaburlscheme', // only for iOS
};
const naverInit = {
  kConsumerKey: 'jyvqXeaVOVmV',
  kConsumerSecret: '527300A0_COq1_XV33cf',
  kServiceAppName: '네이버 아이디로 로그인하기',
  kServiceAppUrlScheme: 'thirdparty20samplegame', // only for iOS
};

class Page extends Component {
  constructor(props) {
    super(props);

    console.log(
      '\n\n Initial Page :: src/components/pages/First/index.js \n\n',
    );

    this.state = {
      isNaverLoggingin: false,
      theToken: 'token has not fetched',
    };
  }

  // 로그인 후 내 프로필 가져오기.
  async fetchProfile() {
    const profileResult = await getProfile(this.state.theToken);
    console.log(profileResult);
    if (profileResult.resultcode === '024') {
      Alert.alert('로그인 실패', profileResult.message);
      return;
    }
    this.props.navigation.navigate('Second', {
      profileResult,
    });
  }

  // 네이버 로그인 시작.
  async naverLoginStart() {
    console.log('  naverLoginStart  ed');
    NaverLogin.login(initials, (err, token) => {
      console.log(`\n\n  Token is fetched  :: ${token} \n\n`);
      this.setState({ theToken: token });
      if (err) {
        console.log(err);
      }
    });
  }

  render() {
    const { theToken } = this.state;
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Navbar>SOCIAL LOGIN</Navbar>
        </View>
        <View style={styles.content}>
          <NativeButton
            isLoading={this.state.isNaverLoggingin}
            onPress={() => this.naverLoginStart()}
            activeOpacity={0.5}
            style={styles.btnNaverLogin}
            textStyle={styles.txtNaverLogin}
          >
            NAVER LOGIN
          </NativeButton>
          <Text>{theToken}</Text>
          <NativeButton
            isLoading={this.state.isNaverLoggingin}
            onPress={() => this.fetchProfile()}
            activeOpacity={0.5}
            style={styles.btnNaverLogin}
            textStyle={styles.txtNaverLogin}
          >
            Fetch Profile
          </NativeButton>
        </View>
      </View>
    );
  }
}

export default Page;
