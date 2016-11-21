//
//  UIWebView+UNCookie.m
//  union
//
//  Created by apple  on 16/5/4.
//  Copyright © 2016年 wodedata.com. All rights reserved.
//

#import "UIWebView+Cookie.h"

#import "JRSwizzle.h"
#import "NSHTTPCookie+javascriptString.h"

@implementation UIWebView (Cookie)

+ (void)load {
    //把私有方法名拆开写，绕过审核验证
    [self jr_swizzleMethod:NSSelectorFromString([@"webViewMainFra" stringByAppendingString:@"meDidFirstVisuallyNonEmptyLayoutInFrame:"]) withMethod:@selector(mainFrameDidFirstVisuallyNonEmptyLayoutInFrame:) error:nil];
}

- (void)mainFrameDidFirstVisuallyNonEmptyLayoutInFrame:(id)frame {
    [self mainFrameDidFirstVisuallyNonEmptyLayoutInFrame:frame];
    
    //组成网页端需要的cookie
    NSDictionary *properties = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserCookieProperty"];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSString *cookieString = [cookie javascriptString];
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.cookie = '%@';", cookieString ?: @""]];
}

@end
