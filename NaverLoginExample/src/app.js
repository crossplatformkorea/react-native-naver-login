import React, { Component } from 'react';
import { StatusBar, View } from 'react-native';
import { createAppContainer, createStackNavigator } from 'react-navigation';

import FirstPage from './components/pages/First';
import SecondPage from './components/pages/Second';

// const startPage = 'First';
const startPage = 'First';

class App extends Component {
  constructor(props) {
    super(props);
    this.navigator = null;
  }

  render() {
    const StackNavigator = createStackNavigator(
      {
        First: {
          screen: FirstPage,
          path: 'first',
        },
        Second: {
          screen: SecondPage,
          path: 'second',
        },
      },
      {
        initialRouteName: startPage,
        header: null,
        headerMode: 'none',
        navigationOptions: {
          header: null,
        },
      },
    );
    const AppContainer = createAppContainer(StackNavigator);
    return (
      <View style={{ flex: 1 }}>
        <StatusBar barStyle="dark-content" />
        <AppContainer />
      </View>
    );
  }
}

module.exports = { App };
