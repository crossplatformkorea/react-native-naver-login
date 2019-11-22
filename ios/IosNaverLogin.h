
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <NaverThirdPartyLogin/NaverThirdPartyLoginConnection.h>

@interface IosNaverLogin : NSObject <RCTBridgeModule, NaverThirdPartyLoginConnectionDelegate>

@end
  
