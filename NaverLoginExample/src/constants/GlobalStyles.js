import { Dimensions, StyleSheet } from 'react-native';
const { width, height } = Dimensions.get('window');
const ratio = 18 * (width / height);
const screenRatio = (ratio < 9 ? width / 9 : height / 18) / (360 / 9);
console.log(`\n   Screen: ${width}x${height} screenRatio : ${screenRatio}`);

const styles = StyleSheet.create({});

module.exports = {
  stylesCommon: styles,
  ratio: screenRatio,
  width,
  height,
};
