//
//  LWModifyExpressageInfoPlugin.m
//  ACERepair
//
//  Created by apple on 16/9/7.
//  Copyright © 2016年 wodedata.com. All rights reserved.
//

#import "LWModifyExpressageInfoPlugin.h"
#import "KINWebBrowserViewController.h"

@implementation LWModifyExpressageInfoPlugin

- (NSString *)scriptMessageHandlerName {
    return @"modifyExpressageInfo";
}

- (void)browser:(KINWebBrowserViewController *)browser didReceiveScriptMessage:(id)message {
    NSLog(@"%@", message);
    
    if ([message isKindOfClass:[NSDictionary class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyExpressInfoNotification" object:message];

    }
    
}

@end
