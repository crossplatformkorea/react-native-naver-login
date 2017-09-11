import React, { Component } from 'react';
import {
  View,
  Text,
  Alert,
} from 'react-native';

import NativeButton from 'apsl-react-native-button';

import Navbar from '../../shared/Navbar';
import styles from './styles';
import { naverLogin } from '../../../apis/AuthApi';

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
      key: 'VN6WKGFQ3pJ0xBXRtlN9',
      secret: 'AHBgzH9ZkM',
      name: 'dooboolab',
      urlScheme: 'dooboolaburlscheme', // only for iOS
    };
    const results = await naverLogin(JSON.stringify(initials));
    // Alert.alert('results');
    console.log('response');
    console.log(results);


    this.props.navigation.navigate('Second', {
      results,
    });
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
