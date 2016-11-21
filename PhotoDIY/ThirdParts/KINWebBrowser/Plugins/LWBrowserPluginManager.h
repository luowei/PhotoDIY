//
//  LWBrowserPluginManager.h
//  union
//
//  Created by apple  on 16/4/25.
//  Copyright © 2016年 wodedata.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KINWebBrowserViewController.h"
#import "LWBrowserPlugin.h"

@interface LWBrowserPluginManager : NSObject

- (instancetype)initWithBrowser:(KINWebBrowserViewController *)browser;

- (void)addPlugin:(id<LWBrowserPlugin>)plugin name:(NSString *)name;

- (id<LWBrowserPlugin>)getPlugin:(NSString *)name;

- (void)addDefaultPlugins;

@end