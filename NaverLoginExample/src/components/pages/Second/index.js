import React, { Component } from 'react';
import {
  Animated,
  Platform,
  StatusBar,
  StyleSheet,
  TouchableHighlight,
  TouchableOpacity,
  Image,
  ScrollView,
  Text,
  View,
} from 'react-native';
import NativeButton from 'apsl-react-native-button';
import styles from './styles';
import Navbar from '../../shared/Navbar';
import { naverLogout } from '../../../apis/AuthApi';

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
  }

  onNaverLogout = () => {
    this.props.navigation.goBack();
    console.log('onNaverLogout');
  }

  render() {
    return (
      <View style={styles.container}>
        <View style={ styles.header }>
          <Navbar
            showBack={true}
            handleBack={this.handleBack}
          >SOCIAL LOGIN RESULT</Navbar>
        </View>
        <View style={ styles.content }>
          <ScrollView style={{ alignSelf: 'stretch', }}>
            <Text style={ styles.txtResult }>
              {JSON.stringify(this.props.navigation.state.params.results, null, '\t')}
            </Text>
            <NativeButton
              onPress={this.onNaverLogout}
              activeOpacity={0.5}
              style={styles.btnNaverLogin}
              textStyle={styles.txtNaverLogin}
            >LOGOUT</NativeButton>
          </ScrollView>
        </View>
      </View>
    );
  }
}

export default Page;
