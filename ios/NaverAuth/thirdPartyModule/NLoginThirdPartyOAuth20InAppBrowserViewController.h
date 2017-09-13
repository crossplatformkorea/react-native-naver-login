//
//  NLoginThirdPartyOAuth20InAppBrowserViewController.h
//  NaverOAuthSample
//
//  Created by TY Kim on 2014. 8. 20..
//  Copyright 2014 Naver Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NaverThirdPartyLoginConnection.h"

@interface NLoginThirdPartyOAuth20InAppBrowserViewController : UIViewController <UIWebViewDelegate> {
    NaverThirdPartyLoginConnection *_thirdPartyLoginConn;
    
    NSString *_linkUrl;
    NSURLRequest *_urlRequest;
    
    UIView *_mainView;
    
    UIView *_bannerView;
    UIButton *_bannerCloseButton;
    UIWebView *_webView;
	BOOL _isLeaving;
    BOOL _isCloseBannerView;
    
    UIView *_bottomBar;
    UIView *_bottomBarTopDivLine;
    UIButton *_closeBt;
    
    UIInterfaceOrientation parentOrientation;
}

@property (nonatomic, assign) UIInterfaceOrientation parentOrientation;

- (id) initWithRequest:(NSURLRequest *) urlRequest;
- (void)setOAuthWebViewDelegate:(id)aDelegate;
- (NSString *)parameterValueWithUrl:(NSString *)url paramName:(NSString *)name;

@end
