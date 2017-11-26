/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

// 네이버 관련 세팅
#import "NaverThirdPartyConstantsForApp.h"
#import "NaverThirdPartyLoginConnection.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"NaverLoginExample"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  NSLog(@"\n\n\n  url scheme :: %@   \n\n\n .", url.scheme);

  return [self handleWithUrl:url];
}


- (BOOL)handleWithUrl:(NSURL *)url {
  NSLog(@"url : %@", url);
  NSLog(@"url scheme : %@", url.scheme);
  //NSLog(@"url scheme : %@", kServiceAppUrlScheme);
  // NSLog(@"result - %d", [url.scheme isEqualToString:kServiceAppUrlScheme]);

  
      // 네이버앱으로부터 전달받은 url값을 NaverThirdPartyLoginConnection의 인스턴스에 전달
      NaverThirdPartyLoginConnection *thirdConnection = [NaverThirdPartyLoginConnection getSharedInstance];
      THIRDPARTYLOGIN_RECEIVE_TYPE resultType = [thirdConnection receiveAccessToken:url];

      if (SUCCESS == resultType) {
        NSLog(@"Getting auth code from NaverApp success!");
      } else {
        NSLog(@"  Error  ::  %u", resultType);
        // 앱에서 resultType에 따라 실패 처리한다.
        /*  SUCCESS = 0, PARAMETERNOTSET = 1, CANCELBYUSER = 2, NAVERAPPNOTINSTALLED = 3 , NAVERAPPVERSIONINVALID = 4,
         .  OAUTHMETHODNOTSET = 5, INVALIDREQUEST = 6, CLIENTNETWORKPROBLEM = 7, UNAUTHORIZEDCLIENT = 8,
         .  UNSUPPORTEDRESPONSETYPE = 9, NETWORKERROR = 10, UNKNOWNERROR = 11 */
      }
  return YES;
}

@end
