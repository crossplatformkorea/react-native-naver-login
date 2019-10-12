import {
  Animated,
  Image,
  Platform,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableHighlight,
  TouchableOpacity,
  View,
} from 'react-native';
import React, { Component } from 'react';

import NativeButton from 'apsl-react-native-button';
import Navbar from '../../shared/Navbar';
import { naverLogout } from '../../../apis/AuthApi';
import styles from './styles';

class Page extends Component {
  constructor(props) {
    super(props);
    this.state = {
      searchViewVisible: false,
    };
  }

  handleBack = () => {
    this.props.navigation.goBack();
    console.log('handleBack');
  };

  onNaverLogout = () => {
    this.props.navigation.goBack();
    console.log('onNaverLogout');
  };

  render() {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Navbar showBack={true} handleBack={this.handleBack}>
            SOCIAL LOGIN RESULT
          </Navbar>
        </View>
        <View style={styles.content}>
          <ScrollView style={{ alignSelf: 'stretch' }}>
            <Text style={styles.txtResult}>
              AccessToken:{' '}
              {JSON.stringify(
                this.props.navigation.state.params.result,
                null,
                '\t',
              ) + '\n\n'}
              Profile:{' '}
              {JSON.stringify(
                this.props.navigation.state.params.profileResult,
                null,
                '\t',
              )}
            </Text>
            <NativeButton
              onPress={this.onNaverLogout}
              activeOpacity={0.5}
              style={styles.btnNaverLogin}
              textStyle={styles.txtNaverLogin}
            >
              LOGOUT
            </NativeButton>
          </ScrollView>
        </View>
      </View>
    );
  }
}

export default Page;
