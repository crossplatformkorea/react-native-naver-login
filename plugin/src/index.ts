import type { ConfigPlugin } from '@expo/config-plugins';
import {
  withAppDelegate,
  withInfoPlist,
  WarningAggregator,
} from '@expo/config-plugins';

interface NaverLoginPluginProps {
  urlScheme: string;
}

const NAVER_LAUNCH_SERVICE_QUERIES_SCHEMES = [
  'naversearchapp',
  'naversearchthirdlogin',
];

const NAVER_HEADER_IMPORT_STRING =
  '#import <NaverThirdPartyLogin/NaverThirdPartyLoginConnection.h>';

const createNaverLinkingString = (
  urlScheme: string
) => `if ([url.scheme isEqualToString:@"${urlScheme}"]) {
    return [[NaverThirdPartyLoginConnection getSharedInstance] application:application openURL:url options:options];
  }`;

const modifyInfoPlist: ConfigPlugin<NaverLoginPluginProps> = (
  config,
  { urlScheme }
) => {
  return withInfoPlist(config, (config) => {
    if (!Array.isArray(config.modResults.LSApplicationQueriesSchemes)) {
      config.modResults.LSApplicationQueriesSchemes =
        NAVER_LAUNCH_SERVICE_QUERIES_SCHEMES;
    } else {
      NAVER_LAUNCH_SERVICE_QUERIES_SCHEMES.forEach((scheme) => {
        if (!config.modResults.LSApplicationQueriesSchemes?.includes(scheme)) {
          config.modResults.LSApplicationQueriesSchemes?.push(scheme);
        }
      });
    }

    if (!Array.isArray(config.modResults.CFBundleURLTypes)) {
      config.modResults.CFBundleURLTypes = [];
    }

    const isExist = config.modResults.CFBundleURLTypes.some(
      (item) =>
        item.CFBundleURLName === 'naver' &&
        item.CFBundleURLSchemes.includes(urlScheme)
    );

    if (!isExist) {
      config.modResults.CFBundleURLTypes.push({
        CFBundleURLName: 'naver',
        CFBundleURLSchemes: [urlScheme],
      });
    }

    return config;
  });
};

const modifyContents = (contents: string, urlScheme: string) => {
  if (!contents.includes(NAVER_HEADER_IMPORT_STRING)) {
    contents = contents.replace(
      '#import <React/RCTLinkingManager.h>',
      `#import <React/RCTLinkingManager.h>
${NAVER_HEADER_IMPORT_STRING}`
    );
  }

  const naverLinkingString = createNaverLinkingString(urlScheme);

  if (!contents.includes(naverLinkingString)) {
    contents = contents.replace(
      'options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {',
      `options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  ${naverLinkingString}
`
    );
  }

  return contents;
};

const modifyAppDelegate: ConfigPlugin<NaverLoginPluginProps> = (
  config,
  { urlScheme }
) => {
  return withAppDelegate(config, async (config) => {
    if (['objc', 'objcpp'].includes(config.modResults.language)) {
      config.modResults.contents = modifyContents(
        config.modResults.contents,
        urlScheme
      );
    } else {
      WarningAggregator.addWarningIOS(
        'withNaverLogin',
        'Swift AppDelegate files are not supported yet.'
      );
    }

    return config;
  });
};

const withNaverLogin: ConfigPlugin<NaverLoginPluginProps> = (config, props) => {
  config = modifyInfoPlist(config, props);
  config = modifyAppDelegate(config, props);
  return config;
};

export default withNaverLogin;
