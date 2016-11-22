//
//  KINWebBrowserViewController.m
//
//  KINWebBrowser
//
//  Created by David F. Muir V
//  dfmuir@gmail.com
//  Co-Founder & Engineer at Kinwa, Inc.
//  http://www.kinwa.co
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 David Muir
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <objc/message.h>
#import "KINWebBrowserViewController.h"
#import "LWBrowserPluginManager.h"
#import "UIWebView+Cookie.h"
#import "NSHTTPCookie+javascriptString.h"
#import "RegExCategories.h"
//#import <MJRefresh/MJRefresh.h>

static void *KINWebBrowserContext = &KINWebBrowserContext;

@interface KINWebBrowserViewController () <UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, strong) UIBarButtonItem *backButton, *forwardButton, *refreshButton, *stopButton, *fixedSeparator, *flexibleSeparator;
@property (nonatomic, strong) NSTimer *fakeProgressTimer;
@property (nonatomic, strong) UIPopoverController *actionPopoverController;
@property (nonatomic, assign) BOOL uiWebViewIsLoading;
@property (nonatomic, strong) NSURL *uiWebViewCurrentURL;
@property (nonatomic, strong) NSURL *URLToLaunchWithPermission;
@property (nonatomic, strong) UIAlertView *externalAppPermissionAlertView;
@property (nonatomic, strong) LWBrowserPluginManager *pluginManager;
@property (nonatomic, assign) BOOL hasAddCookie;
@property (nonatomic, assign) BOOL isPoping; //是否正在手势返回中的标示状态

@end

@implementation KINWebBrowserViewController{
    NSError *_provisionalError;
}

#pragma mark - Static Initializers

+ (KINWebBrowserViewController *)webBrowser {
    KINWebBrowserViewController *webBrowserViewController = [KINWebBrowserViewController webBrowserWithConfiguration:nil];
    return webBrowserViewController;
}

+ (KINWebBrowserViewController *)webBrowserWithConfiguration:(WKWebViewConfiguration *)configuration {
    KINWebBrowserViewController *webBrowserViewController = [[self alloc] initWithConfiguration:configuration];
    return webBrowserViewController;
}

+ (UINavigationController *)navigationControllerWithWebBrowser {
    KINWebBrowserViewController *webBrowserViewController = [[self alloc] initWithConfiguration:nil];
    return [KINWebBrowserViewController navigationControllerWithBrowser:webBrowserViewController];
}

+ (UINavigationController *)navigationControllerWithWebBrowserWithConfiguration:(WKWebViewConfiguration *)configuration {
    KINWebBrowserViewController *webBrowserViewController = [[self alloc] initWithConfiguration:configuration];
    return [KINWebBrowserViewController navigationControllerWithBrowser:webBrowserViewController];
}

+ (UINavigationController *)navigationControllerWithBrowser:(KINWebBrowserViewController *)webBrowser {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webBrowser action:@selector(doneButtonPressed:)];
    [webBrowser.navigationItem setRightBarButtonItem:doneButton];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webBrowser];
    return navigationController;
}

#pragma mark - Initializers

- (id)init {
    return [self initWithConfiguration:nil];
//    return [KINWebBrowserViewController navigationControllerWithWebBrowser];
}

- (id)initWithConfiguration:(WKWebViewConfiguration *)configuration {
    self = [super init];
    if(self) {
        if([WKWebView class]) {
            //组成网页端需要的cookie
            NSDictionary *properties = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACEUserCookieProperty"];
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
            NSString *cookieString = [cookie javascriptString];
            
            WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:[NSString stringWithFormat:@"document.cookie = '%@';", cookieString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            
            WKUserContentController *userContentController = [[WKUserContentController alloc] init];
            [userContentController addUserScript:cookieScript];

            //添加ScriptMessageHandler
            [userContentController addScriptMessageHandler:self name:@"webViewBack"];
            [userContentController addScriptMessageHandler:self name:@"webViewReload"];


            if(configuration) {
                configuration.userContentController = userContentController;
                self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
            }
            else {
                configuration = [[WKWebViewConfiguration alloc] init];
                configuration.userContentController = userContentController;
                self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
            }

//            self.wkWebView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self.wkWebView refreshingAction:@selector(reload)];
        }
        else {
            self.uiWebView = [[UIWebView alloc] init];
//            self.uiWebView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self.uiWebView refreshingAction:@selector(reload)];
        }
        
        self.wkWebView.backgroundColor = [UIColor whiteColor];
        
        self.tintColor = [UIColor whiteColor];
        self.toolbarHidden = YES;
        self.showsURLInNavigationBar = NO;
        self.showsPageTitleInNavigationBar = YES;
        self.historyEnable = YES;
        
        self.externalAppPermissionAlertView = [[UIAlertView alloc] initWithTitle:@"Leave this app?" message:@"This web page is trying to open an outside app. Are you sure you want to open it?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open App", nil];
        
        self.pluginManager = [[LWBrowserPluginManager alloc] initWithBrowser:self];
        
        if ([WKWebView class]) {
            [self.pluginManager addDefaultPlugins];
        }
        
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.wkWebView && !self.uiWebView) {
        (void)[self init];
    }
    
//    self.previousNavigationControllerToolbarHidden = self.navigationController.toolbarHidden;
    self.previousNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    
    if(self.wkWebView) {
        [self.wkWebView setFrame:self.view.bounds];
        [self.wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.wkWebView setNavigationDelegate:self];
        [self.wkWebView setUIDelegate:self];
        [self.wkWebView setMultipleTouchEnabled:YES];
        [self.wkWebView setAutoresizesSubviews:YES];
        [self.wkWebView.scrollView setAlwaysBounceVertical:YES];

        self.wkWebView.navigationDelegate = self;
        self.wkWebView.UIDelegate = self;
        self.wkWebView.allowsBackForwardNavigationGestures = YES;

//        //开启离线缓存
//        SEL sel = NSSelectorFromString([@"_setOfflineApplication" stringByAppendingString:@"CacheIsEnabled:"]);
//        [self.wkWebView.configuration.preferences performSelector:sel withObject:@(YES)];

        [self.view addSubview:self.wkWebView];
        
        [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:KINWebBrowserContext];
    }
    else if(self.uiWebView) {
        [self.uiWebView setFrame:self.view.bounds];
        [self.uiWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.uiWebView setDelegate:self];
        [self.uiWebView setMultipleTouchEnabled:YES];
        [self.uiWebView setAutoresizesSubviews:YES];
        [self.uiWebView setScalesPageToFit:YES];
        [self.uiWebView.scrollView setAlwaysBounceVertical:YES];
        [self.view addSubview:self.uiWebView];
    }
    
    _progressBar = [[LWProgressBar alloc] initWithFrame:CGRectMake(0, 41, CGRectGetWidth(self.view.frame), 2)];
    _progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _progress = _progressBar;
    
//    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//    [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
//    [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-self.progressView.frame.size.height, self.view.frame.size.width, self.progressView.frame.size.height)];
//    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    
    if (self.navigationController) {
        NSArray *viewCtls = self.navigationController.viewControllers;
        if (viewCtls.count > 0 &&
            viewCtls.firstObject != self) {
            [self configureNavBar];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:self.toolbarHidden animated:YES];
    
    [self.navigationController.navigationBar addSubview:self.progress];
    
    [self updateToolbarState];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 在didAppear时置为NO
    _isPoping = NO;
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:self.previousNavigationControllerNavigationBarHidden animated:animated];
    
//    [self.navigationController setToolbarHidden:self.previousNavigationControllerToolbarHidden animated:animated];
    
    [self.uiWebView setDelegate:nil];
    [_progress removeFromSuperview];
}

#pragma mark - Public Interface

- (void)loadRequest:(NSURLRequest *)request {
    //组成网页端需要的cookie
    NSDictionary *properties = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACEUserCookieProperty"];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSString *cookieString = [cookie javascriptString];

    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:request.URL];
    [mutableRequest addValue:cookieString forHTTPHeaderField:@"Cookie"];

    if(self.wkWebView) {
        [self.wkWebView loadRequest:mutableRequest];
    }
    else if(self.uiWebView) {
        [self.uiWebView loadRequest:mutableRequest];
    }

}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

- (void)loadHTMLString:(NSString *)HTMLString {
    if(self.wkWebView) {
        [self.wkWebView loadHTMLString:HTMLString baseURL:nil];
    }
    else if(self.uiWebView) {
        [self.uiWebView loadHTMLString:HTMLString baseURL:nil];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
//    [self.progressView setTintColor:tintColor];
//    [self.navigationController.navigationBar setTintColor:tintColor];
    [self.navigationController.toolbar setTintColor:tintColor];
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
//    [self.navigationController.navigationBar setBarTintColor:barTintColor];
    [self.navigationController.toolbar setBarTintColor:barTintColor];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.uiWebView) {
        
        if(![self externalAppRequiredToOpenURL:request.URL]) {
            self.uiWebViewCurrentURL = request.URL;
            self.uiWebViewIsLoading = YES;
            [self updateToolbarState];
            
//            [self fakeProgressViewStartLoading];
            
            if([self.delegate respondsToSelector:@selector(webBrowser:didStartLoadingURL:)]) {
                [self.delegate webBrowser:self didStartLoadingURL:request.URL];
            }
            
            [self.pluginManager addDefaultPlugins];
            
            return YES;
        }
        else {
            [self launchExternalAppWithURL:request.URL];
            return NO;
        }
    }
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView == self.uiWebView) {
        
        if(!self.uiWebView.isLoading) {
            self.uiWebViewIsLoading = NO;
            [self updateToolbarState];
            
//            [self fakeProgressBarStopLoading];
        }
        
        if([self.delegate respondsToSelector:@selector(webBrowser:didFinishLoadingURL:)]) {
            [self.delegate webBrowser:self didFinishLoadingURL:self.uiWebView.request.URL];
        }
        
//        [self.uiWebView.scrollView.mj_header endRefreshing];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(webView == self.uiWebView) {
        if(!self.uiWebView.isLoading) {
            self.uiWebViewIsLoading = NO;
            [self updateToolbarState];
            
//            [self fakeProgressBarStopLoading];
        }
        if([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)]) {
            [self.delegate webBrowser:self didFailToLoadURL:self.uiWebView.request.URL error:error];
        }
        
//        [self.uiWebView.scrollView.mj_header endRefreshing];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//处理当接收到验证窗口时
- (void)  webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSString *hostName = webView.URL.host;

    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]
            || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]
            || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {

        NSString *title = @"Authentication Challenge";
        NSString *message = [NSString stringWithFormat:@"%@ requires user name and password", hostName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"User";
            //textField.secureTextEntry = YES;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Password";
            textField.secureTextEntry = YES;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            NSString *userName = ((UITextField *) alertController.textFields[0]).text;
            NSString *password = ((UITextField *) alertController.textFields[1]).text;

            NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];

            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);

        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alertController animated:YES completion:nil];
        });

    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }

}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if(webView == _wkWebView) {
        [self updateToolbarState];
        
        _progressBar.isLoading = YES;
        [_progressBar progressUpdate:.05];
        
        if([_delegate respondsToSelector:@selector(webBrowser:didStartLoadingURL:)]) {
            [_delegate webBrowser:self didStartLoadingURL:_wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if(webView == self.wkWebView) {
        
        self.hasAddCookie = NO;
        
        [self updateToolbarState];
        
        _progressBar.isLoading = NO;
        
        if([self.delegate respondsToSelector:@selector(webBrowser:didFinishLoadingURL:)]) {
            [self.delegate webBrowser:self didFinishLoadingURL:self.wkWebView.URL];
        }
        
//        [self.wkWebView.scrollView.mj_header endRefreshing];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        [self updateToolbarState];
        
        _progressBar.isLoading = NO;
        [_progressBar setProgressZero];
        
//        if([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)]) {
//            [self.delegate webBrowser:self didFailToLoadURL:self.wkWebView.URL error:error];
//        }

        _provisionalError = error;
        switch ([error code]) {
            case kCFURLErrorServerCertificateUntrusted: {
                //解决12306不能买票问题
                NSRange range = [[webView.URL host] rangeOfString:@"12306.cn"];

                if (range.location != NSNotFound && range.location) {
                    NSArray *chain = error.userInfo[@"NSErrorPeerCertificateChainKey"];
                    NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                    [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
                    [webView loadRequest:[NSURLRequest requestWithURL:failingURL]];
                } else {
                    // 网站证书不被信任，给出提示
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:
                                    [NSString stringWithFormat:NSLocalizedString(@"HTTPS Certifcate Not Trust", nil), webView.URL.host]
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                         destructiveButtonTitle:NSLocalizedString(@"Ok", nil)
                                                              otherButtonTitles:nil, nil];
                    [sheet showInView:self.view];
                }
                break;
            }
            case kCFURLErrorBadServerResponse:
            case kCFURLErrorNotConnectedToInternet:
            case kCFSOCKS5ErrorNoAcceptableMethod:
            case kCFErrorHTTPBadCredentials:
            case kCFErrorHTTPConnectionLost:
            case kCFErrorHTTPBadURL:
            case kCFErrorHTTPBadProxyCredentials:
            case kCFURLErrorBadURL:
            case kCFURLErrorTimedOut:
            case kCFURLErrorCannotFindHost:
            case kCFURLErrorCannotConnectToHost:
            case kCFURLErrorNetworkConnectionLost:
            case kCFNetServiceErrorTimeout:
            case kCFNetServiceErrorNotFound:
//            NSLog(@"errorCode:%ld",(long)[error code]);
                //error webView
                if (self.wkWebView.estimatedProgress < 0.3) {
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"failedPage" ofType:@"htm"];
                    NSError *error2;
                    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error2];
                    NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                    [webView loadHTMLString:htmlString baseURL:failingURL];
                }
                break;
            default: {
                break;
            }
        }
        
//        [self.wkWebView.scrollView.mj_header endRefreshing];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if(webView == self.wkWebView) {
        [self updateToolbarState];
        
        _progressBar.isLoading = NO;
        [_progressBar setProgressZero];

        switch ([error code]) {
            case kCFURLErrorServerCertificateUntrusted: {
                //解决12306不能买票问题
                NSRange range = [[webView.URL host] rangeOfString:@"12306.cn"];
                if (range.location != NSNotFound) {
                    NSArray *chain = error.userInfo[@"NSErrorPeerCertificateChainKey"];
                    NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                    [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
                    [webView loadRequest:[NSURLRequest requestWithURL:failingURL]];
                }
                break;
            }
            case kCFURLErrorBadServerResponse:
            case kCFURLErrorNotConnectedToInternet:
            case kCFSOCKS5ErrorNoAcceptableMethod:
            case kCFErrorHTTPBadCredentials:
            case kCFErrorHTTPConnectionLost:
            case kCFErrorHTTPBadURL:
            case kCFErrorHTTPBadProxyCredentials:
            case kCFURLErrorBadURL:
            case kCFURLErrorTimedOut:
            case kCFURLErrorCannotFindHost:
            case kCFURLErrorCannotConnectToHost:
            case kCFURLErrorNetworkConnectionLost:
            case kCFNetServiceErrorTimeout:
            case kCFNetServiceErrorNotFound:
                NSLog(@"errorCode:%ld", (long) [error code]);
                //error webView
                if (self.wkWebView.estimatedProgress < 0.3) {
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"failedPage" ofType:@"htm"];
                    NSError *error2;
                    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error2];
                    NSURL *failingURL = error.userInfo[@"NSErrorFailingURLKey"];
                    [webView loadHTMLString:htmlString baseURL:failingURL];
                }
                break;
            default: {
                break;
            }
        }

//        if([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)]) {
//            [self.delegate webBrowser:self didFailToLoadURL:self.wkWebView.URL error:error];
//        }
        
//        [self.wkWebView.scrollView.mj_header endRefreshing];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(webView == self.wkWebView) {
//        NSURL *URL = navigationAction.request.URL;
//        if(![self externalAppRequiredToOpenURL:URL]) {
//            if(!navigationAction.targetFrame) {
//                [self loadURL:URL];
//                decisionHandler(WKNavigationActionPolicyCancel);
//                return;
//            }
//        }
//        else if([[UIApplication sharedApplication] canOpenURL:URL]) {
//            [self launchExternalAppWithURL:URL];
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
        NSURL *url = navigationAction.request.URL;
        NSString *urlString = (url) ? url.absoluteString : @"";
        // iTunes: App Store link跳转不了问题
        if ([urlString isMatch:RX(@"\\/\\/itunes\\.apple\\.com\\/")]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        //蒲公英安装不了问题
        if ([urlString hasPrefix:@"itms-services://?action=download-manifest"]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        if ([url.scheme isEqualToString:@"tel"]) {
            NSString *phoneNumber = url.resourceSpecifier.stringByRemovingPercentEncoding;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:phoneNumber message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Call", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:url];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKScriptMessageHandler

//处理当接收到html页面脚本发来的消息
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //返回
    if ([message.name isEqualToString:@"webViewBack"]) {
        [self.wkWebView goBack];
        //重新加载
    } else if ([message.name isEqualToString:@"webViewReload"]) {
        [self.wkWebView reload];
    }
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

//处理页面的alert弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//处理页面的confirm弹窗
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

    // TODO We have to think message to confirm "YES"
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//处理页面的promt弹窗
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:webView.URL.host preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *) alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

// 网站证书不被信任的情况
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            NSArray *chain = _provisionalError.userInfo[@"NSErrorPeerCertificateChainKey"];
            NSURL *failingURL = _provisionalError.userInfo[@"NSErrorFailingURLKey"];
            [self setAllowsHTTPSCertifcateWithCertChain:chain ForHost:[failingURL host]];
            [self loadRequest:[NSURLRequest requestWithURL:failingURL]];
            break;
        }
        default:
            break;
    }
}

//允许HTTPS验证钥匙中证书
- (void)setAllowsHTTPSCertifcateWithCertChain:(NSArray *)certChain ForHost:(NSString *)host {
    ((void (*)(id, SEL, id, id)) objc_msgSend)(self.wkWebView.configuration.processPool,
            //- (void)_setAllowsSpecificHTTPSCertificate:(id)arg1 forHost:(id)arg2;
            //NSSelectorFromString([NSString base64Decoding:@"X3NldEFsbG93c1NwZWNpZmljSFRUUFNDZXJ0aWZpY2F0ZTpmb3JIb3N0Og=="]),
            NSSelectorFromString([@"_setAllowsSpe" stringByAppendingString:@"cificHTTPSCertificate:forHost:"]),
            certChain, host);
}


#pragma mark - NavigationItem

- (void)configureNavBar {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    backBtn.frame = CGRectMake(0, 0, 50, 44);
    [backBtn setImage:[UIImage imageNamed:@"navbar_btn_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    //自定义返回按钮
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)goBack:(UIButton *)sender {
    if (_historyEnable) {
        if (_uiWebView && [_uiWebView canGoBack]) {
            [_uiWebView goBack];
            return;
        } else if (_wkWebView && [_wkWebView canGoBack]) {
            [_wkWebView goBack];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Toolbar State

- (void)updateToolbarState {
    
    BOOL canGoBack = self.wkWebView.canGoBack || self.uiWebView.canGoBack;
    BOOL canGoForward = self.wkWebView.canGoForward || self.uiWebView.canGoForward;
    
    [self.backButton setEnabled:canGoBack];
    [self.forwardButton setEnabled:canGoForward];
    
    if(!self.backButton) {
        [self setupToolbarItems];
    }
    
    NSArray *barButtonItems;
    if(self.wkWebView.loading || self.uiWebViewIsLoading) {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.stopButton, self.flexibleSeparator];
        
        if(self.showsURLInNavigationBar) {
            NSString *URLString;
            if(self.wkWebView) {
                URLString = [self.wkWebView.URL absoluteString];
            }
            else if(self.uiWebView) {
                URLString = [self.uiWebViewCurrentURL absoluteString];
            }
            
            URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            URLString = [URLString substringToIndex:[URLString length]-1];
            self.navigationItem.title = URLString;
        }
    }
    else {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.refreshButton, self.flexibleSeparator];
        
        if(self.showsPageTitleInNavigationBar) {
            if(self.wkWebView) {
                self.navigationItem.title = self.wkWebView.title;
            }
            else if(self.uiWebView) {
                self.navigationItem.title = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
            }
        }
    }
    
    [self setToolbarItems:barButtonItems animated:YES];
    
    self.tintColor = self.tintColor;
    self.barTintColor = self.barTintColor;
    
    
}

- (void)setupToolbarItems {
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed:)];
    
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"  ◁" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithTitle:@"▷  " style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonPressed:)];
    self.fixedSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.fixedSeparator.width = 50.0f;
    self.flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

#pragma mark - Done Button Action

- (void)doneButtonPressed:(id)sender {
    [self dismissAnimated:YES];
}

#pragma mark - UIBarButtonItem Target Action Methods

- (void)backButtonPressed:(id)sender {
    
    if(self.wkWebView) {
        [self.wkWebView goBack];
    }
    else if(self.uiWebView) {
        [self.uiWebView goBack];
    }
    [self updateToolbarState];
}

- (void)forwardButtonPressed:(id)sender {
    if(self.wkWebView) {
        [self.wkWebView goForward];
    }
    else if(self.uiWebView) {
        [self.uiWebView goForward];
    }
    [self updateToolbarState];
}

- (void)refreshButtonPressed:(id)sender {
    if(self.wkWebView) {
        [self.wkWebView stopLoading];
        [self.wkWebView reload];
    }
    else if(self.uiWebView) {
        [self.uiWebView stopLoading];
        [self.uiWebView reload];
    }
}

- (void)stopButtonPressed:(id)sender {
    if(self.wkWebView) {
        [self.wkWebView stopLoading];
    }
    else if(self.uiWebView) {
        [self.uiWebView stopLoading];
    }
}

#pragma mark - Estimated Progress KVO (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _wkWebView &&
        [keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        double estimatedProgress = [change[@"new"] doubleValue];
        [_progressBar progressUpdate:estimatedProgress];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Fake Progress Bar Control (UIWebView)

//- (void)fakeProgressViewStartLoading {
//    [self.progressView setProgress:0.0f animated:NO];
//    [self.progressView setAlpha:1.0f];
//    
//    if(!self.fakeProgressTimer) {
//        self.fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(fakeProgressTimerDidFire:) userInfo:nil repeats:YES];
//    }
//}
//
//- (void)fakeProgressBarStopLoading {
//    if(self.fakeProgressTimer) {
//        [self.fakeProgressTimer invalidate];
//    }
//    
//    if(self.progressView) {
//        [self.progressView setProgress:1.0f animated:YES];
//        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [self.progressView setAlpha:0.0f];
//        } completion:^(BOOL finished) {
//            [self.progressView setProgress:0.0f animated:NO];
//        }];
//    }
//}
//
//- (void)fakeProgressTimerDidFire:(id)sender {
//    CGFloat increment = 0.005/(self.progressView.progress + 0.2);
//    if([self.uiWebView isLoading]) {
//        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
//        if(self.progressView.progress < 0.95) {
//            [self.progressView setProgress:progress animated:YES];
//        }
//    }
//}

#pragma mark - External App Support

- (BOOL)externalAppRequiredToOpenURL:(NSURL *)URL {
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https"]];
    return ![validSchemes containsObject:URL.scheme];
}

- (void)launchExternalAppWithURL:(NSURL *)URL {
    self.URLToLaunchWithPermission = URL;
    if (![self.externalAppPermissionAlertView isVisible]) {
        [self.externalAppPermissionAlertView show];
    }
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == self.externalAppPermissionAlertView) {
        if(buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:self.URLToLaunchWithPermission];
        }
        self.URLToLaunchWithPermission = nil;
    }
}

#pragma mark - Dismiss

- (void)dismissAnimated:(BOOL)animated {
    if([self.delegate respondsToSelector:@selector(webBrowserViewControllerWillDismiss:)]) {
        [self.delegate webBrowserViewControllerWillDismiss:self];
    }
    [self.navigationController dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark - Interface Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.uiWebView setDelegate:nil];
    
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
    if ([self isViewLoaded]) {
        [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
}


@end

@implementation UINavigationController(KINWebBrowser)

- (KINWebBrowserViewController *)rootWebBrowser {
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    return (KINWebBrowserViewController *)rootViewController;
}

@end
