#import "RNNaverLogin-Bridging-Header.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>

@interface RCT_EXTERN_MODULE(RNNaverLogin, NSObject)
RCT_EXTERN_METHOD(
				  logout: (RCTPromiseResolveBlock)resolve
				  reject: (RCTPromiseRejectBlock)reject
				  )
RCT_EXTERN_METHOD(
          initialize: (NSString) serviceUrlScheme
          consumerKey: (NSString) consumerKey
          consumerSecret: (NSString) consumerSecret
          appName: (NSString) appName
          disableNaverAppAuth: (BOOL) disableNaverAppAuth
          )
RCT_EXTERN_METHOD(
				  login: (RCTPromiseResolveBlock) resolve
				  reject: (RCTPromiseRejectBlock) reject
				  )
RCT_EXTERN_METHOD(
				  deleteToken: (RCTPromiseResolveBlock) resolve
				  reject: (RCTPromiseRejectBlock) reject
				  )
@end
