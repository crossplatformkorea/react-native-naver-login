//
//  NaverThirdPartyConstantsForApp.h
//  NaverOAuthSample
//
//  Created by min sujin on 12. 3. 28..
//  Modified by TY Kim on 14. 8. 20..
//  Copyright 2014 Naver Corp. All rights reserved.
//

#define kCheckResultPage        @"thirdPartyLoginResult"
#define kThirdParty_IS_IPAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

typedef enum {
    SUCCESS = 0,
    PARAMETERNOTSET = 1,
    CANCELBYUSER = 2,
    NAVERAPPNOTINSTALLED = 3 ,
    NAVERAPPVERSIONINVALID = 4,
    OAUTHMETHODNOTSET = 5,
    INVALIDREQUEST = 6,
    CLIENTNETWORKPROBLEM = 7,
    UNAUTHORIZEDCLIENT = 8,
    UNSUPPORTEDRESPONSETYPE = 9,
    NETWORKERROR = 10,
    UNKNOWNERROR = 11
} THIRDPARTYLOGIN_RECEIVE_TYPE;

typedef enum {
    NEED_INIT = 0,
    NEED_LOGIN,
    NEED_REFRESH_ACCESS_TOKEN,
    OK
} OAuthLoginState;

//#define kServiceAppUrlScheme    @"thirdparty20samplegame"
//
//#define kConsumerKey            @"jyvqXeaVOVmV"
//#define kConsumerSecret         @"527300A0_COq1_XV33cf"
//#define kServiceAppName         @"네이버 아이디로 로그인"


#define kServiceAppUrlScheme    @"comthemoinremiturlscheme"

#define kConsumerKey            @"SIVlb8pJop7NMpNJcy9c"
#define kConsumerSecret         @"YV0HTkaPda"
#define kServiceAppName         @"MOIN"


