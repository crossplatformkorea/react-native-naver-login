//
//  NLoginThirdPartyOAuth20InAppBrowserViewController.m
//  NaverOAuthSample
//
//  Created by TY Kim on 2014. 8. 20..
//  Copyright 2014 Naver Corp. All rights reserved.
//

#import "NLoginThirdPartyOAuth20InAppBrowserViewController.h"
#import "NaverThirdPartyConstantsForApp.h"
#import "NaverThirdPartyLoginConnection.h"

#define kThirdPartyMainWindowWidth ((int)UIScreen.mainScreen.bounds.size.width)
#define kThirdPartyMainWindowHeight ((int)UIScreen.mainScreen.bounds.size.height)

#define kBottomBarHeight    46
#define kButtonSize         24
#define kHeightOfStatusbar  20
#define kThirdPartyBannerHeight 57

#define kThirdPartyNaverAppIconSize 37

#define NAVERAUTH_BUNDLE                [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"NaverAuth" withExtension:@"bundle"]]

#define kNaverAuthBannerMessage         NSLocalizedStringFromTableInBundle(@"NaverAuthBannerMessage", @"NaverAuth", NAVERAUTH_BUNDLE, @"Get NAVER App and sign in faster")

#define kNaverAuthBannerDownloadLink    NSLocalizedStringFromTableInBundle(@"NaverAuthBannerDownloadLinkMessage", @"NaverAuth", NAVERAUTH_BUNDLE, @"Download App")


@interface NLoginThirdPartyOAuth20InAppBrowserViewController(PRIVATE_METHOD)
- (CGSize) mainWindowSize:(UIInterfaceOrientation)orientation;
@end

@interface NaverThirdPartyLoginConnection(PRIVATE_METHOD)
- (BOOL)validOneTimeStateCode:(NSString *)aState;
- (void)setAuthorizationCode:(NSString *)authCode;
- (void)loginFailWithErrorCode:(THIRDPARTYLOGIN_RECEIVE_TYPE)code;
- (void)failWithGetAuthCode:(NSString *)error withDescription:(NSString *)error_description;
@end

@implementation NLoginThirdPartyOAuth20InAppBrowserViewController
@synthesize parentOrientation;

- (BOOL)isUpperIOS8
{
    int version = [[[UIDevice currentDevice] systemVersion] intValue];
    return (8 <= version);
}

- (BOOL)isChangeWidthAndHeight:(UIInterfaceOrientation)orientation
{
    if ([self isUpperIOS8]) {
        return NO;
    }
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation) ? YES : NO;
    return isLandscape;
}

- (CGSize) mainWindowSize:(UIInterfaceOrientation)orientation  {
    CGSize mainWindowSize = [[UIScreen mainScreen] bounds].size;
	int statusBarHeight = [[UIApplication sharedApplication] isStatusBarHidden] ? 0 : kHeightOfStatusbar;
	BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation) ? YES : NO;
    
    BOOL isUpperIOS8 = (8 <= [[[UIDevice currentDevice] systemVersion] intValue]);
    if ( YES == isUpperIOS8) {
        isLandscape = NO;
    }
    
	if(isLandscape)
		mainWindowSize = CGSizeMake(mainWindowSize.height, mainWindowSize.width);
	mainWindowSize = CGSizeMake(mainWindowSize.width, mainWindowSize.height - statusBarHeight);
	return mainWindowSize;
}

- (void) closeInApp {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (CGFloat) topMargin {
    if(7 <= [[[UIDevice currentDevice] systemVersion] intValue] && (NO == [UIApplication sharedApplication].statusBarHidden)){
        return 20.0f;
    } else{
        return 0.0f;
    }
}

- (void)makeBottomBar   {
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, kThirdPartyMainWindowHeight - kBottomBarHeight, kThirdPartyMainWindowWidth, kBottomBarHeight)];
    _bottomBar.backgroundColor = [UIColor whiteColor];
    [_mainView addSubview:_bottomBar];
    
    _bottomBarTopDivLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomBar.frame.size.width, 1)];
    _bottomBarTopDivLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _bottomBarTopDivLine.backgroundColor = [UIColor colorWithRed:0xC6/255.0 green:0xC6/255.0 blue:0xC6/255.0 alpha:1.0];
    [_bottomBar addSubview:_bottomBarTopDivLine];
    
    // 24X24
    int numberOfBtn = 4;
    CGFloat btnWidth = CGRectGetWidth(_bottomBar.frame) / numberOfBtn;
    CGFloat btnHeight = CGRectGetHeight(_bottomBar.frame) - CGRectGetHeight(_bottomBarTopDivLine.bounds);
    
    CGFloat closeBtnOriginX = btnWidth * 3;
    _closeBt = [[UIButton alloc] initWithFrame:CGRectMake(closeBtnOriginX, 0, btnWidth, btnHeight)];

    [_closeBt setImage:[UIImage imageNamed:@"NaverAuth.bundle/btn_notice_close_normal.png"] forState:UIControlStateNormal];
    [_closeBt addTarget:self action:@selector(closeBtAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar addSubview:_closeBt];
}

- (void)makeMainView
{
    // Status bar의 텍스트가 흰색이라면 아래 색을 [UIColor blackColor]로 변경한다.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // XCode 5.X 에서 빌드 및 iOS 7 대응용
    // XCode 4.X 에서 빌드해서 등록한다면 _topMargin = 0; 만 두고 주석처리한다.
    
    CGFloat topMargin = [self topMargin];
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, topMargin, kThirdPartyMainWindowWidth, kThirdPartyMainWindowHeight - topMargin)];
    _mainView.backgroundColor = [UIColor colorWithRed:0x00/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:0.5];
    [self.view addSubview:_mainView];
    
}

- (void)makeBannerView
{
    CGFloat pointY = 0.0f;
    CGFloat bannerHeight = 0.0f;

    if ([_thirdPartyLoginConn isPossibleToOpenNaverApp] || _isCloseBannerView) {
        bannerHeight = 0;
        _bannerView.hidden = YES;
    } else {
        bannerHeight = kThirdPartyBannerHeight;
        _bannerView.hidden = NO;
    }
    _bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, pointY, kThirdPartyMainWindowWidth, bannerHeight)];
    _bannerView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:251.0/255.0 blue:229.0/255.0 alpha:1];
    
    UIImageView *naverAppIconView = [[UIImageView alloc] init];
    naverAppIconView.image = [UIImage imageNamed:@"NaverAuth.bundle/login_naverapp_logo.png"];
    naverAppIconView.frame = CGRectIntegral(CGRectMake(10, 10, 37, 37));
    
    UILabel *bannerMessage = [[UILabel alloc] init];
    bannerMessage.font = [UIFont boldSystemFontOfSize:13];
    bannerMessage.backgroundColor = [UIColor clearColor];
    bannerMessage.textColor = [UIColor colorWithRed:(CGFloat)(33.0/255.0) green:(CGFloat)(33.0/255.0) blue:(CGFloat)(33.0/255.0) alpha:(CGFloat)1.0];
    bannerMessage.textAlignment = NSTextAlignmentLeft;
    bannerMessage.lineBreakMode = NSLineBreakByWordWrapping;
    bannerMessage.numberOfLines = 0;
    bannerMessage.text = kNaverAuthBannerMessage;
    
    CGSize bannerMessageSize = [NaverThirdPartyLoginConnection sizeWithText:bannerMessage.text withFont:bannerMessage.font];
    
    UILabel *downloadLinkMessage = [[UILabel alloc] init];
    downloadLinkMessage.font = [UIFont boldSystemFontOfSize:11];
    downloadLinkMessage.backgroundColor = [UIColor clearColor];
    downloadLinkMessage.textColor = [UIColor colorWithRed:(CGFloat)(0x2D/255.0) green:(CGFloat)(0xB4/255.0) blue:(CGFloat)(0x00/255.0) alpha:(CGFloat)1.0];
    downloadLinkMessage.textAlignment = NSTextAlignmentLeft;
    downloadLinkMessage.lineBreakMode = NSLineBreakByWordWrapping;
    downloadLinkMessage.numberOfLines = 0;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:kNaverAuthBannerDownloadLink];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    downloadLinkMessage.attributedText = attributeString;
    

    CGSize downloadLinkSize = [NaverThirdPartyLoginConnection sizeWithText:downloadLinkMessage.text withFont:downloadLinkMessage.font];

    
    downloadLinkMessage.frame = CGRectMake(0, 0, downloadLinkSize.width, downloadLinkSize.height);

    CGFloat messageHeightDelta = 1.0f;
    CGFloat totalHeight = bannerMessageSize.height + downloadLinkSize.height + messageHeightDelta;

    
    bannerMessage.frame = CGRectMake(CGRectGetMaxX(naverAppIconView.frame) + 10, 10 + (kThirdPartyNaverAppIconSize - totalHeight)/2.0 ,bannerMessageSize.width, bannerMessageSize.height);

    downloadLinkMessage.frame = CGRectMake(CGRectGetMinX(bannerMessage.frame), CGRectGetMaxY(bannerMessage.frame) + messageHeightDelta, downloadLinkSize.width, downloadLinkSize.height);
    
    UIButton *appDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    appDownloadButton.frame = CGRectMake(0, 0, CGRectGetMaxX(bannerMessage.frame), kThirdPartyBannerHeight);
    [appDownloadButton addTarget:self action:@selector(openNaverAppDownloadInAppStore) forControlEvents:UIControlEventTouchUpInside];
    
    [appDownloadButton addSubview:naverAppIconView];
    [appDownloadButton addSubview:bannerMessage];
    [appDownloadButton addSubview:downloadLinkMessage];
    [_bannerView addSubview:appDownloadButton];
    
    UIImageView *closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NaverAuth.bundle/login_banner_btn_close.png"]];
    _bannerCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeImageView.frame = CGRectMake(kThirdPartyBannerHeight - 10 - 11, 10, 11, 11);
    _bannerCloseButton.frame = CGRectMake(kThirdPartyMainWindowWidth - kThirdPartyBannerHeight, 0, kThirdPartyBannerHeight, kThirdPartyBannerHeight);
    [_bannerCloseButton addSubview:closeImageView];
    
    [_bannerCloseButton addTarget:self action:@selector(closeBannerView) forControlEvents:UIControlEventTouchUpInside];
    [_bannerView addSubview:_bannerCloseButton];
    
    [_mainView addSubview:_bannerView];
}

- (void)makeWebView
{
    CGFloat webViewHeight = kThirdPartyMainWindowHeight - kBottomBarHeight - CGRectGetHeight(_bannerView.frame);
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                           CGRectGetMaxY(_bannerView.frame),
                                                           kThirdPartyMainWindowWidth,
                                                           webViewHeight)];
    _webView.delegate = self;
	_webView.scalesPageToFit = YES;
    [_mainView addSubview:_webView];
}

- (void)showIndicator
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)hideIndicator
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (id)initWithRequest:(NSURLRequest *) urlRequest {
    self = [super init];
    if (self) {
        _thirdPartyLoginConn = [NaverThirdPartyLoginConnection getSharedInstance];        
        _urlRequest = urlRequest;
        _isCloseBannerView = [_thirdPartyLoginConn isPossibleToOpenNaverApp];
        [self makeMainView];
        [self makeBannerView];
        [self makeWebView];
        [self makeBottomBar];

    }
    return self;
}

- (void)setOAuthWebViewDelegate:(id)aDelegate
{
    _webView.delegate = aDelegate;
}

- (void)viewWillAppear:(BOOL)animated   {
    if(_linkUrl != nil) {
        NSString *escapedString = [_linkUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:escapedString];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    } else if (_urlRequest != nil) {
        [_webView loadRequest:_urlRequest];
    }
}
- (void)viewWillDisappear:(BOOL)animated    {
    if ( [UIApplication sharedApplication].networkActivityIndicatorVisible )    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    if ([_webView isLoading]) {
        _isLeaving = YES;
        [_webView stopLoading];
        [self performSelector:@selector(closeInApp) withObject:_webView afterDelay:0.3];
    }
}

- (void) drawRotateLayout:(UIInterfaceOrientation)orientation   {
    
    CGSize mainWindowSize = [self mainWindowSize:orientation];
    
    _mainView.frame = CGRectMake(0, [self topMargin], mainWindowSize.width, mainWindowSize.height);
    if ([_thirdPartyLoginConn isPossibleToOpenNaverApp] || YES == _isCloseBannerView) {
        _bannerView.frame = CGRectMake(0, 0, mainWindowSize.width, 0);
        _bannerView.hidden = YES;
    } else {
        _bannerView.frame = CGRectMake(0, 0, mainWindowSize.width, kThirdPartyBannerHeight);
        _bannerView.hidden = NO;
        _bannerCloseButton.frame = CGRectMake(kThirdPartyMainWindowWidth - kThirdPartyBannerHeight, 0, kThirdPartyBannerHeight, kThirdPartyBannerHeight);
    }
    _webView.frame = CGRectMake(0, CGRectGetMaxY(_bannerView.frame), mainWindowSize.width, mainWindowSize.height - kBottomBarHeight - CGRectGetHeight(_bannerView.frame));
    _bottomBar.frame = CGRectMake(0, mainWindowSize.height - kBottomBarHeight, mainWindowSize.width, kBottomBarHeight);
    _bottomBarTopDivLine.frame = CGRectMake(0, 0, mainWindowSize.width, 1);
    
    int btnWidth = mainWindowSize.width / 4.0;
    int btnHeight = CGRectGetHeight(_bottomBar.frame) - CGRectGetHeight(_bottomBarTopDivLine.frame);
    
    _closeBt.frame = CGRectMake(btnWidth * 3, CGRectGetHeight(_bottomBarTopDivLine.frame), btnWidth, btnHeight);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (kThirdParty_IS_IPAD) {
        [self drawRotateLayout:parentOrientation];
        return (interfaceOrientation == parentOrientation);
    } else {
        [self drawRotateLayout:interfaceOrientation];
        return YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    /**
     * iOS5이상 부터는 회전할 때 viewWillLayoutSubviews가 호출되기 때문에 그 이전 버전에 대해서만 동작하도록 함
     */
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 5) {
        [self drawRotateLayout:toInterfaceOrientation];
    }
}

- (void)viewWillLayoutSubviews {
    [self drawRotateLayout:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (kThirdParty_IS_IPAD) {
        return UIInterfaceOrientationMaskAll;
    } else if ([[NaverThirdPartyLoginConnection getSharedInstance] isOnlyPortraitSupportedInIphone]) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma BannerView

- (void)openNaverAppDownloadInAppStore
{
    [_thirdPartyLoginConn openAppStoreForNaverApp];
}

- (void)closeBannerView
{
    _isCloseBannerView = YES;
    CGRect frame = _bannerView.frame;
    _bannerView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0.0f);
    _bannerView.hidden = YES;
    
    [self viewWillLayoutSubviews];
}

#pragma -
#pragma UIWebViewDelegate Method
- (void)webViewDidStartLoad:(UIWebView *)aWebView   {
	[self showIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView  {
	[self hideIndicator];
}
- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
	[self hideIndicator];
	if (_isLeaving) {
		_isLeaving = NO;
        [self closeInApp];
	}
}

- (BOOL)isStartsWithString:(NSString *)originString prefix:(NSString *)prefix
{
    NSRange range = [originString rangeOfString:prefix options:NSAnchoredSearch];
    if (range.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}
- (BOOL)isContainWithString:(NSString *)originString string:(NSString *)string
{
    //    NSLog(@"url - %@", originString);
    NSRange range = [originString rangeOfString:string];
    if (range.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (NSString *)parameterValueWithUrl:(NSString *)url paramName:(NSString *)name
{
	NSArray *separtedUrl = [url componentsSeparatedByString:@"?"];
	if ( [separtedUrl count] <= 1 )
		return nil;
	
	NSString *params = [separtedUrl objectAtIndex:1];
	NSArray *separtedParam = [params componentsSeparatedByString:@"&"];
	for ( NSString *param in separtedParam )
	{
		if ( [[param lowercaseString] hasPrefix:[name lowercaseString]] )
		{
			return [[param substringFromIndex:[name length]+1]
                    stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            //ex) @"url="
		}
	}
	return nil;
}

- (void) closeByUserCancel {
    [[NaverThirdPartyLoginConnection getSharedInstance] loginFailWithErrorCode:CANCELBYUSER];
    [self closeInApp];
}

- (void) closeBtAction:(id)sender {
    [self closeByUserCancel];
}

- (void) errorStateCode {
    [[NaverThirdPartyLoginConnection getSharedInstance] loginFailWithErrorCode:UNAUTHORIZEDCLIENT];
    NSLog(@"not valid state");
    NSLog(@"state code is invalid!");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSLog(@"request url = [%@]", [request.URL absoluteString]);
    
    if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
        NSString *original_ua = [[request valueForHTTPHeaderField:@"User-Agent"] copy];
        NSString *useragent = [[NaverThirdPartyLoginConnection getSharedInstance] userAgentForThirdPartyLogin];
        NSString *ua = [NSString stringWithFormat:@"%@ %@",original_ua, useragent];
        [(id)request setValue:ua forHTTPHeaderField:@"User-Agent"];
        original_ua = nil;
    }
    
    
    NSURL *url = [request URL];
    NSString *urlString = [[request URL] absoluteString];
    
    if ([url query].length > 0) {
        NSRange state_range = [[url query] rangeOfString:@"state="];

        NSRange error_range = [[url query] rangeOfString:@"error="];
        if (NSNotFound != error_range.location && NSNotFound != state_range.location) {
            NSString *state = [self parameterValueWithUrl:urlString paramName:@"state"];

            if (NO == [_thirdPartyLoginConn validOneTimeStateCode:state]) {
                [self errorStateCode];
            } else {
                NSString *error = [self parameterValueWithUrl:urlString paramName:@"error"];
                NSString *error_description = [self parameterValueWithUrl:urlString paramName:@"error_description"];
                [_thirdPartyLoginConn failWithGetAuthCode:error withDescription:error_description];
            }
            [self closeInApp];
            return NO;
        }
        
        NSRange code_range = [[url query] rangeOfString:@"code="];
        if (NSNotFound != code_range.location && NSNotFound != state_range.location ) {
            NSString *state = [self parameterValueWithUrl:urlString paramName:@"state"];
            if (NO == [_thirdPartyLoginConn validOneTimeStateCode:state]) {
                [self errorStateCode];
            } else {
                NSString *authorizationCode = [self parameterValueWithUrl:urlString paramName:@"code"];
                [_thirdPartyLoginConn setAuthorizationCode:authorizationCode];
            }
            [self closeInApp];
            return NO;
        }
	}
    
    // 취소버튼관련페이지
    if ([self isContainWithString:urlString string:@"://nid.naver.com/nidlogin.logout"]
        || [self isContainWithString:urlString string:@"http://m.naver.com"]
        || [self isContainWithString:urlString string:@"//nid.naver.com/com.nhn.login_global/inweb/finish"]) {
        [self closeByUserCancel];
        return NO;
    }
    
    // 실명인증관련페이지
    if ([self isContainWithString:urlString string:@"/sso/logout.nhn"]
        || [self isContainWithString:urlString string:@"/sso/cross-domain.nhn"]
        || [self isContainWithString:urlString string:@"/sso/finalize.nhn"] )
    {
        return YES;
    }
    
    // 로그관련페이지
    if ([self isStartsWithString:urlString prefix:@"http://cc.naver.com"]
        || [self isStartsWithString:urlString prefix:@"http://cr.naver.com"])
    {
        return YES;
    }
    
    return YES;
}

@end
