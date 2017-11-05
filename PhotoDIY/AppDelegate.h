//
//  AppDelegate.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#ifdef DEBUG
#define Log(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define Log(format, ...)
#endif

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define Notification_ShowViewController   @"Notification_ShowViewController"


#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property(nonatomic) BOOL portraitVC;
@end

