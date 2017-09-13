//
//  NaverAuthBridge.m
//  authMan
//
//  Created by JJTTMOON on 2017. 6. 28..
//  Copyright © 2017년 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <React/RCTLog.h>

#import "ReactIosAuth.h"

// 네이버 관련 세팅
#import "AppDelegate.h"
#import "NaverThirdPartyConstantsForApp.h"
#import "NaverThirdPartyLoginConnection.h"
#import "NLoginThirdPartyOAuth20InAppBrowserViewController.h"

@interface ReactIosAuth() {
  
}

@end

////////////////////////////////////////////////////     _//////////_
@implementation ReactIosAuth

-(instancetype)init {
  self = [super init];
  
  // 네이버 관련 세팅
  NSLog(@"\n\n\n\n\n     NaverAuthRct  init   set delegate  %@  \n\n\n\n\n .", kConsumerKey);
  _thirdPartyLoginConn = [NaverThirdPartyLoginConnection getSharedInstance];
  _thirdPartyLoginConn.delegate = self;
  naverTokenSend = nil;
  
  // Facebook 관련 세팅
  fbTokenSend = nil;
  fbTokenProfileSend = nil;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(appReturned:)
                                               name:@"TestNotification"
                                             object:nil];
  return self;
}

- (void)appReturned:(NSNotification *)notification
{
  // [notification name] should always be @"TestNotification"
  // unless you use this method for observation of other notifications
  // as well.
  
  //if ([[notification name] isEqualToString:@"TestNotification"]) {
//  if (fbTokenProfileSend != nil) {
//    [self fetchFbNameToken];
//  }
}


- (void)dealloc
{
   _thirdPartyLoginConn.delegate = nil;
}

////////////////////////////////////////////////////     _//////////_  // 네이버 관련 세팅

-(void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error {
  NSLog(@"\n\n\n  Nearo oauth20Connection \n\n\n");
  naverTokenSend = nil;
}

-(void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
  NSLog(@"\n\n\n  Nearo oauth20ConnectionDidFinishRequestACTokenWithAuthCode");
  NSString *token = [_thirdPartyLoginConn accessToken];
  NSLog(@"\n\n\n  Nearo Token ::  %@", token);
  if (naverTokenSend != nil) {
    NSLog(@" Nearo :: rctCallback != nil  JS 로 보냄.. .. \n");
    naverTokenSend(@[[NSNull null], token]);
    naverTokenSend = nil;
  }
}
-(void)oauth20ConnectionDidFinishRequestACTokenWithRefreshToken {
  NSString *token = [_thirdPartyLoginConn accessToken];
  NSLog(@" \n\n\n Nearo oauth20ConnectionDidFinishRequestACTokenWithRefreshToken \n\n\n  %@ \n\n .", token);
  if (naverTokenSend != nil) {
    naverTokenSend(@[[NSNull null], token]);
  }
}

-(void)oauth20ConnectionDidOpenInAppBrowserForOAuth:(NSURLRequest *)request {
  NSLog(@"\n\n\n Nearo oauth20ConnectionDidOpenInAppBrowserForOAuth \n\n\n xx");
  dispatch_async(dispatch_get_main_queue(), ^{
    NLoginThirdPartyOAuth20InAppBrowserViewController *inappAuthBrowser =
    [[NLoginThirdPartyOAuth20InAppBrowserViewController alloc] initWithRequest:request];
    
    
    UIViewController *vc = UIApplication.sharedApplication.delegate.window.rootViewController;
    [vc presentViewController:inappAuthBrowser animated:NO completion:nil];
  });
}

-(void)oauth20ConnectionDidFinishDeleteToken {
  NSLog(@" \n\n\n Nearo oauth20ConnectionDidFinishDeleteToken \n\n\n");
}

////////////////////////////////////////////////////     _//////////_//      EXPORT_MODULE
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(iosLog:(NSString *)memo) {
  RCTLogInfo(@"\n\n\n\n Obj c >> ReactIosAuth iosLog  %@  \n\n\n\n .", memo);
  
  NSLog(@"\n\n iosLog :  %@ \n\n", memo);
}

////////////////////////////////////////////////////     _//////////_// 네이버 관련 세팅
RCT_EXPORT_METHOD(startNaverAuth:(RCTResponseSenderBlock)callback) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: startNaverAuth \n\n\n\n .");
  NSLog(@" Nearo  log this ???");
  // [_thirdPartyLoginConn requestThirdPartyLogin];
  NSString *token = [_thirdPartyLoginConn accessToken];
  naverTokenSend = callback;
  NSLog(@"\n\n\n Nearo Token ::  %@", token);
  
  if ([_thirdPartyLoginConn isValidAccessTokenExpireTimeNow]) {
    NSLog(@"\n\n\n Nearo Token  ::   >>>>>>>>  VALID");
    naverTokenSend(@[[NSNull null], token]);
  } else {
    NSLog(@"\n\n\n Nearo Token  ::   >>>>>>>>  IN VALID  >>>>>");
    [_thirdPartyLoginConn requestThirdPartyLogin];
  }
}

RCT_EXPORT_METHOD(resetNaverAuth:(RCTResponseSenderBlock)callback) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: reset \n\n\n\n .");
  [_thirdPartyLoginConn resetToken];
  naverTokenSend = nil;
  callback(@[[NSNull null], @"reset called"]);
}

RCT_EXPORT_METHOD(isNaverValidToken:(RCTResponseSenderBlock)getToken) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: isNaverValidToken \n\n\n\n .");
  naverTokenSend = getToken;
  if ([_thirdPartyLoginConn isValidAccessTokenExpireTimeNow]) {
    NSString *token = [_thirdPartyLoginConn accessToken];
    naverTokenSend(@[[NSNull null], token]);
  } else {
    //naverTokenSend(@[[NSNull null], @"Token is invalid ..."]);
    RCTLogInfo(@"\n\n\n\n Obj c >> Nearo isNaverValidToken :: Token is In Valid  Reqest New One \n\n\n\n .");
    [_thirdPartyLoginConn requestThirdPartyLogin];
    //[_thirdPartyLoginConn requestAccessTokenWithRefreshToken];
  }
}

RCT_EXPORT_METHOD(getNaverToken:(RCTResponseSenderBlock)getNaverToken) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: startNaverAuth \n\n\n\n .");
  NSString *token = [_thirdPartyLoginConn accessToken];
  RCTLogInfo(@"\n\n\n  Nearo Token ::  %@", token);
  
  if (token != NULL) {
    getNaverToken(@[[NSNull null], token]);
  }
}

@end
