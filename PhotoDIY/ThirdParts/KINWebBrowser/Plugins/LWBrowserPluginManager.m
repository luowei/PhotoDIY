//
//  LWBrowserPluginManager.m
//  union
//
//  Created by apple  on 16/4/25.
//  Copyright © 2016年 wodedata.com. All rights reserved.
//

#import "LWBrowserPluginManager.h"

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "LWModifyExpressageInfoPlugin.h"

@interface LWBrowserPluginManager () <WKScriptMessageHandler>

@property (nonatomic, weak) KINWebBrowserViewController *browser;
@property (nonatomic, strong) NSMutableDictionary *plugins;
@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, strong) NSMutableDictionary *messageHandlers;
@property (nonatomic, strong) NSMutableDictionary *fakeJSWebKit;

@end

@implementation LWBrowserPluginManager

#pragma mark - Initialization
- (instancetype)initWithBrowser:(KINWebBrowserViewController *)browser {
    self = [super init];
    if (self) {
        self.browser = browser;
        self.plugins = [NSMutableDictionary dictionary];
        if (self.browser.uiWebView) {
            self.messageHandlers = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    id<LWBrowserPlugin> plugin = [self.plugins objectForKey:message.name];
    
    if (plugin) {
        [plugin browser:self.browser didReceiveScriptMessage:message.body];
    }
}

#pragma mark - Public Methods
- (void)addPlugin:(id<LWBrowserPlugin>)plugin name:(NSString *)name{
    if (self.plugins[name]) {
        return;
    }
    
    self.plugins[name] = plugin;
    
    if ([plugin scriptMessageHandlerName]) {
        if (self.browser.wkWebView) {
            [[[[self.browser wkWebView] configuration] userContentController] addScriptMessageHandler:self name:[plugin scriptMessageHandlerName]];
            
        }
        
        if (self.browser.uiWebView) {
            self.jsContext.exceptionHandler = ^(JSContext *con, JSValue *exception) {
                NSLog(@"%@", exception);
                con.exception = exception;
            };
            
            if (!self.messageHandlers[name]) {
                self.messageHandlers[name] = @{@"postMessage": ^(id data) {
                    [plugin browser:self.browser didReceiveScriptMessage:data];
                }};
                
            }
        }
    }
}

- (id<LWBrowserPlugin>)getPlugin:(NSString *)name {
    return self.plugins[name];
}

- (void)addDefaultPlugins {
       
    //修改快递信息
    LWModifyExpressageInfoPlugin *modifyExpressageInfoPlugin = [[LWModifyExpressageInfoPlugin alloc] init];
    [self addPlugin:modifyExpressageInfoPlugin name:[modifyExpressageInfoPlugin scriptMessageHandlerName]];
    
    if (self.browser.uiWebView) {
        self.jsContext[@"webkit"] = self.fakeJSWebKit;
    }
}

#pragma mark - Getters & Setters
- (JSContext *)jsContext {
    JSContext *context = [self.browser.uiWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    return context;
}

- (NSMutableDictionary *)fakeJSWebKit {
    if (!_fakeJSWebKit) {
        _fakeJSWebKit = [NSMutableDictionary dictionaryWithDictionary:@{@"messageHandlers": self.messageHandlers}];
    }
    return _fakeJSWebKit;
}

@end
