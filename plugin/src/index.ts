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

// const NAVER_HEADER_IMPORT_STRING_SWIFT = 'import NidThirdPartyLogin';
const NAVER_HEADER_IMPORT_STRING_SWIFT = 'import NaverThirdPartyLogin';

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

const modifyContentSwift = (contents: string, urlScheme: string) => {
  if (!contents.includes(NAVER_HEADER_IMPORT_STRING_SWIFT)) {
    contents = contents.replace(
      'import Expo',
      `import Expo
${NAVER_HEADER_IMPORT_STRING_SWIFT}`
    );
  }
  // Add URL handling for Naver login
  if (!contents.includes('NaverThirdPartyLoginConnection.getSharedInstance')) {
    contents = contents.replace(
      'return super.application(app, open: url, options: options) || RCTLinkingManager.application(app, open: url, options: options)',
      `if (url.scheme == "${urlScheme}") {
        return NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
      }
      return super.application(app, open: url, options: options) || RCTLinkingManager.application(app, open: url, options: options)`
    );
  }

  return contents;
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
      config.modResults.contents = modifyContentSwift(
        config.modResults.contents,
        urlScheme
      );

      WarningAggregator.addWarningIOS(
        'withNaverLogin',
        'Swift AppDelegate is experimental.'
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
