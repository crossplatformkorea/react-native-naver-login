
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import "NaverThirdPartyLoginConnection.h"

@interface IosNaverLogin : NSObject <RCTBridgeModule, NaverThirdPartyLoginConnectionDelegate>

@end
  
