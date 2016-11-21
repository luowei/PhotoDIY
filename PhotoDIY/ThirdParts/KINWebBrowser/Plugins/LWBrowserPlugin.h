//
//  LWBrowserPlugin.h
//  union
//
//  Created by apple  on 16/4/25.
//  Copyright © 2016年 wodedata.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LWBrowserPlugin <NSObject>

@required

- (NSString *)scriptMessageHandlerName;

- (void)browser:(id)browser didReceiveScriptMessage:(id)message;

@end

