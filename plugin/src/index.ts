import type { ConfigPlugin } from '@expo/config-plugins';
import {
  withAppDelegate,
  withInfoPlist,
  IOSConfig, 
  WarningAggregator,
  withDangerousMod, 

} from '@expo/config-plugins';

import fs from 'fs/promises';
import fsSync from 'fs';
import path from 'path';
interface NaverLoginPluginProps {
  urlScheme: string;
}

const NAVER_LAUNCH_SERVICE_QUERIES_SCHEMES = [
  'naversearchapp',
  'naversearchthirdlogin',
];

const NAVER_HEADER_IMPORT_STRING =
  '#import <NaverThirdPartyLogin/NaverThirdPartyLoginConnection.h>';

const NAVER_HEADER_IMPORT_STRING_SWIFT = 'import NidThirdPartyLogin';

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
  // Add NidOAuth initialization in didFinishLaunchingWithOptions
  if (!contents.includes('NidOAuth.shared.initialize()')) {
    contents = contents.replace(
      'return super.application(application, didFinishLaunchingWithOptions: launchOptions)',
      `    NidOAuth.shared.initialize()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)`
    );
  }

  // Add URL handling for Naver login
  if (!contents.includes('NidOAuth.shared.handle')) {
    contents = contents.replace(
      'return super.application(app, open: url, options: options) || RCTLinkingManager.application(app, open: url, options: options)',
      `if (url.scheme == "${urlScheme}" && NidOAuth.shared.handleURL(url)) {
      
      return true
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



const withCustomPodfile: ConfigPlugin = config => {
  return withDangerousMod(config, [
    'ios',
    async config => {
      // 파일 시스템으로 언어 확인
      try {
        const iosPath = path.join(config.modRequest.projectRoot, 'ios');
        const projectName = IOSConfig.XcodeUtils.getProjectName(config.modRequest.projectRoot);
        
        const swiftPath = path.join(iosPath, `${projectName}`, 'AppDelegate.swift');
        const objcPath = path.join(iosPath, `${projectName}`, 'AppDelegate.m');
        
        let isSwift = false;
        if (fsSync.existsSync(swiftPath)) {
          isSwift = true;
        } else if (fsSync.existsSync(objcPath)) {
          isSwift = false;
        }
        
        console.log('AppDelegate language detected:', isSwift ? 'swift' : 'objc');
        
        if (isSwift) {
          const podfilePath = path.join(config.modRequest.platformProjectRoot, 'Podfile');
          try {
            let contents = await fs.readFile(podfilePath, 'utf8');
            contents = addCustomPod(contents, projectName);
            await fs.writeFile(podfilePath, contents);
            console.log('✅ Successfully added custom pod to Podfile for Swift');
          } catch (error) {
            console.warn('⚠️ Podfile not found, skipping modification');
          }
        } else {
          console.log('⚠️ Not Swift, skipping pod modification');
        }
      } catch (error) {
        console.log('Error checking AppDelegate language:', error);
      }
      
      return config;
    },
  ]);
};
function addCustomPod(contents: string, projectName: string): string {
  if (contents.includes("pod 'NidThirdPartyLogin'")) {
    console.log('NidThirdPartyLogin pod already exists, skipping');
    return contents;
  }

  const targetRegex = new RegExp(
    `(target ['"]${projectName}['"] do[\\s\\S]*?use_expo_modules!)`,
    'm'
  );

  return contents.replace(targetRegex, `$1\n  pod 'NidThirdPartyLogin'`);
}



const withNaverLogin: ConfigPlugin<NaverLoginPluginProps> = (config, props) => {
  
  config = modifyInfoPlist(config, props);
  config = modifyAppDelegate(config, props)
    
  config = withCustomPodfile(config);
  
  return config;
};

export default withNaverLogin;
