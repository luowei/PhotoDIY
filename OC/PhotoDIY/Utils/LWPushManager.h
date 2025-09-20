//
// Created by Luo Wei on 2017/5/18.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LWPushManager : NSObject

+ (instancetype)shareManager;

//程序启动时处理推送
- (void)handPushInApplicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

//处理推送消息
-(void)handRemotePushNotificationWithUserInfo:(NSDictionary *)userInfo;

//打开推送，注册远程推送
-(void)openRemotPush;

//关闭推送，注销信鸽绑定设备,
-(void)closeRemotePush;

@end