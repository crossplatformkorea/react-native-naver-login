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
      // // kServiceAppUrlScheme, kConsumerKey, kConsumerSecret, kServiceAppName }
      // kConsumerKey: 'VN6WKGFQ3pJ0xBXRtlN9',
      // kConsumerSecret: 'AHBgzH9ZkM',
      // kServiceAppName: 'dooboolab',
      // kServiceAppUrlScheme: 'dooboolaburlscheme', // only for iOS

      kConsumerKey: "SIVlb8pJop7NMpNJcy9c",
      kServiceAppUrlScheme: "comthemoinremiturlscheme",
      kConsumerSecret: "YV0HTkaPda",
      kServiceAppName: "MOIN"
    };

    try {
      // const result = await naverLogin(JSON.stringify(initials));

      const result = await naverLogin(initials);

      // Alert.alert('results');
      console.log('response');
      console.log(result);
      //
      // if (result) {
      //   const profileResult = await getNaverProfile(result.accessToken);
      //   console.log('profile');
      //   console.log(profileResult);
      //   result.profile = profileResult;
      //
      //   this.props.navigation.navigate('Second', {
      //     result,
      //   });
      // }

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
