
#import "RNNaverLogin.h"


// 네이버 관련 세팅
// #import "AppDelegate.h"
#import "NaverThirdPartyConstantsForApp.h"
#import "NaverThirdPartyLoginConnection.h"
#import "NLoginThirdPartyOAuth20InAppBrowserViewController.h"

////////////////////////////////////////////////////     _//////////_  // Private Members
@interface RNNaverLogin() {
  NaverThirdPartyLoginConnection *naverConn;
  RCTResponseSenderBlock naverTokenSend;
}
@end


////////////////////////////////////////////////////     _//////////_  // Implementation
// TODO :: 아래 소스는 필요한 건지요 ?
@implementation RNNaverLogin

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

////////////////////////////////////////////////////     _//////////_  // 네이버 관련 세팅
-(void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error {
  NSLog(@"\n\n\n  Nearo oauth20Connection \n\n\n");
  naverTokenSend = nil;
}

-(void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
  NSLog(@"\n\n\n  Nearo oauth20ConnectionDidFinishRequestACTokenWithAuthCode");
  NSString *token = [naverConn accessToken];
  NSLog(@"\n\n\n  Nearo Token ::  %@", token);
  if (naverTokenSend != nil) {
    NSLog(@" Nearo :: rctCallback != nil  JS 로 보냄.. .. \n");
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
  // 여기서 웹뷰를 띄웁니다.
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

////////////////////////////////////////////////////     _//////////_// 네이버 관련 세팅
RCT_EXPORT_METHOD(login:(NSDictionary *)keyObj callback:(RCTResponseSenderBlock)callback) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: login \n\n\n\n .");

  naverTokenSend = callback;

  // kServiceAppUrlScheme, kConsumerKey, kConsumerSecret, kServiceAppName }
  [naverConn setConsumerKey:[RCTConvert NSString:details[@"kConsumerKey"]]];
  [naverConn setConsumerSecret:[RCTConvert NSString:details[@"kConsumerSecret"]]];
  [naverConn setAppName:[RCTConvert NSString:details[@"kServiceAppName"]]];
  [naverConn setServiceUrlScheme:[RCTConvert NSString:details[@"kServiceAppUrlScheme"]]];

  [naverConn setIsNaverAppOauthEnable:YES]; // 네이버 앱 사용 안할 때는 NO
  [naverConn setIsInAppOauthEnable:YES]; // 내장 웹뷰 사용 안할 때는 NO

  NSString *token = [naverConn accessToken];
  NSLog(@"\n\n\n Nearo Token ::  %@", token);

  if ([naverConn isValidAccessTokenExpireTimeNow]) {
    NSLog(@"\n\n\n Nearo Token  ::   >>>>>>>>  VALID");
    naverTokenSend(@[[NSNull null], token]);
  } else {
    NSLog(@"\n\n\n Nearo Token  ::   >>>>>>>>  IN VALID  >>>>>");
    [naverConn requestThirdPartyLogin];
  }
}

RCT_EXPORT_METHOD(fetchProfile:(NSDictionary *)token callback:(RCTResponseSenderBlock)callback) {
  NSString *urlString = @"https://openapi.naver.com/v1/nid/me"; // 사용자 프로필 호출 API URL
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  NSString *authValue = [NSString stringWithFormat:@"Bearer %@", token];
  [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
  NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:Nil error:&error];
  if(data == NULL){
    // 통신 실패 !
    NSLog(@"통신 실패 ! : %@",[error LocalizedDescription]);
  }
  else{
    // 통신 성공 // 받아온 정보가 스트링인 경우
    NSString *returnStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Return String : %@",returnStr);
    callback(@[[NSNull null], returnStr]);
  }
}


RCT_EXPORT_METHOD(resetNaverAuth:(RCTResponseSenderBlock)callback) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: reset \n\n\n\n .");
  [naverConn resetToken];
  naverTokenSend = nil;
  callback(@[[NSNull null], @"reset called"]);
}

RCT_EXPORT_METHOD(logout) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: logout \n\n\n\n .");
  [naverConn resetToken];
  naverTokenSend = nil;
}


RCT_EXPORT_METHOD(getProfile:(NSString *)token resp:(RCTResponseSenderBlock)response) {
  NSString *urlString = @"https://openapi.naver.com/v1/nid/getUserProfile.xml";  // 사용자 프로필 호출
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  NSString *authValue = [NSString stringWithFormat:@"Bearer %@", _thirdPartyLoginConn.accessToken];

  [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];

  NSHTTPURLResponse *response = nil;
  NSError *error = nil;
  NSData *receivedData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
  NSString *decodingString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

  NSLog(@" Naver Profile to send from obj-c :  %@", decodingString);

  if (error) {
    NSLog(@"Error happened - %@", [error description]);
  } else {
    NSLog(@"recevied data - %@", decodingString);
    response(@[[NSNull null], decodingString]);
  }
}

RCT_EXPORT_METHOD(isNaverValidToken:(RCTResponseSenderBlock)getToken) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: isNaverValidToken \n\n\n\n .");
  naverTokenSend = getToken;
  if ([naverConn isValidAccessTokenExpireTimeNow]) {
    NSString *token = [naverConn accessToken];
    naverTokenSend(@[[NSNull null], token]);
  } else {
    //naverTokenSend(@[[NSNull null], @"Token is invalid ..."]);
    RCTLogInfo(@"\n\n\n\n Obj c >> Nearo isNaverValidToken :: Token is In Valid  Reqest New One \n\n\n\n .");
    [naverConn requestThirdPartyLogin];
    //[naverConn requestAccessTokenWithRefreshToken];
  }
}

RCT_EXPORT_METHOD(getNaverToken:(RCTResponseSenderBlock)getNaverToken) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: startNaverAuth \n\n\n\n .");
  NSString *token = [naverConn accessToken];
  RCTLogInfo(@"\n\n\n  Nearo Token ::  %@", token);

  if (token != NULL) {
    getNaverToken(@[[NSNull null], token]);
  }
}

@end
