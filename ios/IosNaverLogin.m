
#import "IosNaverLogin.h"

#import <React/RCTLog.h>
#import <React/RCTConvert.h>

// 네이버 관련 세팅
#import "NaverThirdPartyConstantsForApp.h"
#import "NaverThirdPartyLoginConnection.h"

////////////////////////////////////////////////////     _//////////_  // Private Members
@interface IosNaverLogin() {
    NaverThirdPartyLoginConnection *naverConn;
    RCTResponseSenderBlock naverTokenSend;
}
    @end


////////////////////////////////////////////////////     _//////////_  // Implementation
@implementation IosNaverLogin
    
    ////////////////////////////////////////////////////     _//////////_  // 네이버
-(void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error {
    NSLog(@"\n\n\n  Nearo oauth20Connection \n\n\n");
    naverTokenSend = nil;
}
    
-(void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
    NSLog(@"\n\n\n  Nearo oauth20ConnectionDidFinishRequestACTokenWithAuthCode");
    NSString *token = [naverConn accessToken];
    if (naverTokenSend != nil) {
        naverTokenSend(@[[NSNull null], token]);
        naverTokenSend = nil;
    }
}
-(void)oauth20ConnectionDidFinishRequestACTokenWithRefreshToken {
    NSString *token = [naverConn accessToken];
    NSLog(@" \n\n\n Nearo oauth20ConnectionDidFinishRequestACTokenWithRefreshToken \n\n\n  %@ \n\n .", token);
    if (naverTokenSend != nil) {
        naverTokenSend(@[[NSNull null], token]);
    }
}
    
-(void)oauth20ConnectionDidOpenInAppBrowserForOAuth:(NSURLRequest *)request {
    NSLog(@"\n\n\n Nearo oauth20ConnectionDidOpenInAppBrowserForOAuth \n\n\n xx");
    // 웹뷰 띄우기. RN에서는 ViewController 에서 띄우는 것이 아니므로 앱의 뷰를 가져와서 띄운다.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NLoginThirdPartyOAuth20InAppBrowserViewController *inappAuthBrowser =
        [[NLoginThirdPartyOAuth20InAppBrowserViewController alloc] initWithRequest:request];
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        
        [topController presentViewController:inappAuthBrowser animated:YES completion:nil];
    });
}
    
-(void)oauth20ConnectionDidFinishDeleteToken {
    NSLog(@" \n\n\n Nearo oauth20ConnectionDidFinishDeleteToken \n\n\n");
}
    
    ////////////////////////////////////////////////////     _//////////_//      EXPORT_MODULE
    RCT_EXPORT_MODULE();
    
    ////////////////////////////////////////////////////     _//////////_// 네이버 관련 세팅
    RCT_EXPORT_METHOD(login:(NSString *)keyJson callback:(RCTResponseSenderBlock)callback) {
        RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: login \n\n\n\n .");
        naverTokenSend = callback;
        
        naverConn = [NaverThirdPartyLoginConnection getSharedInstance];
        naverConn.delegate = self;
        
        NSData *jsonData = [keyJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *keyObj = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
        
        [naverConn setConsumerKey:[keyObj objectForKey:@"kConsumerKey"]];
        [naverConn setConsumerSecret:[keyObj objectForKey:@"kConsumerSecret"]];
        [naverConn setAppName:[keyObj objectForKey:@"kServiceAppName"]];
        [naverConn setServiceUrlScheme:[keyObj objectForKey:@"kServiceAppUrlScheme"]];
        
        [naverConn setIsNaverAppOauthEnable:YES]; // 네이버 앱 사용 안할 때는 NO
        [naverConn setIsInAppOauthEnable:YES]; // 내장 웹뷰 사용 안할 때는 NO
        
        [naverConn setOnlyPortraitSupportInIphone:YES]; // 포트레이트 레이아웃만 사용하는 경우.
        
        NSString *token = [naverConn accessToken];
        NSLog(@"\n\n\n Nearo Token ::  %@", token);
        
        if ([naverConn isValidAccessTokenExpireTimeNow]) {
            NSLog(@"\n\n\n Nearo Token  ::   >>>>>>>>  VALID 바로 RN 로 넘겨줌.");
            naverTokenSend(@[[NSNull null], token]);
        } else {
            NSLog(@"\n\n\n Nearo Token  ::   >>>>>>>>  IN VALID  >>>>>");
            [naverConn requestThirdPartyLogin];
        }
    }
    
    RCT_EXPORT_METHOD(logout) {
        RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: logout \n\n\n\n .");
        [naverConn resetToken];
        naverTokenSend = nil;
    }
    
    //RCT_EXPORT_METHOD(getProfile:(NSString *)token resp(RCTResponseSenderBlock)response) {
    //  if (NO == [naverConn isValidAccessTokenExpireTimeNow]) {
    //    return;
    //  }
    //
    //  NSString *urlString = @"https://openapi.naver.com/v1/nid/getUserProfile.xml";  // 사용자 프로필 호출
    //  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //  NSString *authValue = [NSString stringWithFormat:@"Bearer %@", token];
    //
    //  [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    //
    //  NSError *error = nil;
    //  NSHTTPURLResponse *urlResponse = nil;
    //  NSData *receivedData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
    //  NSString *decodingString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    //
    //  if (error) {
    //    NSLog(@"Error happened - %@", [error description]);
    //
    //  } else {
    //    NSLog(@"recevied data - %@", decodingString);
    //    response(@[[NSNull null], decodingString]);
    //  }
    //}
    
    
    @end
