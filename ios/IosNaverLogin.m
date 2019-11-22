
#import "IosNaverLogin.h"

#import <React/RCTConvert.h>

// 네이버 관련 세팅
#import <NaverThirdPartyLogin/NaverThirdPartyConstantsForApp.h>
#import <NaverThirdPartyLogin/NaverThirdPartyLoginConnection.h>

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


-(void)oauth20ConnectionDidFinishDeleteToken {
    NSLog(@" \n\n\n Nearo oauth20ConnectionDidFinishDeleteToken \n\n\n");
}

////////////////////////////////////////////////////     _//////////_//      EXPORT_MODULE
RCT_EXPORT_MODULE();

////////////////////////////////////////////////////     _//////////_// 네이버 관련 세팅
RCT_EXPORT_METHOD(login:(NSString *)keyJson callback:(RCTResponseSenderBlock)callback) {
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
    [naverConn resetToken];
    naverTokenSend = nil;
}

// 자바스크립트에서 처리 하므로 네이티브 코드가 불필요 해서 주석처리 합니다

//RCT_EXPORT_METHOD(getProfile:(NSString *)token callback: (RCTResponseSenderBlock)callback) {
//    if (NO == [naverConn isValidAccessTokenExpireTimeNow]) {
//        return;
//    }
//
//    NSString *urlString = @"https://openapi.naver.com/v1/nid/getUserProfile.xml";  // 사용자 프로필 호출
//    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", token];
//
//    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
//
//    NSError *error = nil;
//    NSHTTPURLResponse *urlResponse = nil;
//    NSData *receivedData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
//    NSString *decodingString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
//
//    if (error) {
//        NSLog(@"Error happened - %@", [error description]);
//
//    } else {
//        NSLog(@"recevied data - %@", decodingString);
//        callback(@[[NSNull null], decodingString]);
//    }
//}


@end
