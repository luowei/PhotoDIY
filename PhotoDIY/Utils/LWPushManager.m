//
// Created by Luo Wei on 2017/5/18.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import "LWPushManager.h"
#import "XGPush.h"
#import "AppDelegate.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

#import <UserNotifications/UserNotifications.h>

@interface LWPushManager () <UNUserNotificationCenterDelegate>
@end

#endif

@implementation LWPushManager {

}

+ (id)shareManager {
    static LWPushManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


//注册苹果推送通知服务
- (void)registerAPNS {
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if (sysVer >= 10) {
        [self registerPush10];      // iOS 10
    } else if (sysVer >= 8) {
        [self registerPush8to9];    // iOS 8-9
    }
#else
    [self registerPush8to9];    // iOS 8-9
#endif
}

- (void)registerPush10 {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *_Nullable error) {
        if (granted) {
        }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)registerPush8to9 {
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark - UNUserNotificationCenterDelegate

// iOS 10 新增 API
// iOS 10 会走新 API, iOS 10 以前会走到老 API
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

// App 用户点击通知的回调
// 无论本地推送还是远程推送都会走这个回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"[XGDemo] click notification");
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self handRemotePushNotificationWithUserInfo:userInfo];

    [XGPush handleReceiveNotification:userInfo successCallback:^{
        NSLog(@"[XGDemo] Handle receive success");
    }                   errorCallback:^{
        NSLog(@"[XGDemo] Handle receive error");
    }];

    completionHandler();
}

// App 在前台弹通知需要调用这个接口
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;

    if(application.applicationState == UIApplicationStateActive){
        [self handRemotePushNotificationWithUserInfo:userInfo];
    }else{
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    }
}

#endif


#pragma mark - Custom Method

//程序启动时处理推送
- (void)handPushInApplicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [XGPush startApp:2200270218 appKey:@"IL6V81D91GEC"];

    [XGPush isPushOn:^(BOOL isPushOn) {
        NSLog(@"==== Push Is %@", isPushOn ? @"ON" : @"OFF");
    }];
    [self openRemotPush];


    //推送反馈(app不在前台运行时，点击推送激活时)
    [XGPush handleLaunching:launchOptions successCallback:nil errorCallback:nil];
    //当 App 是 Terminated 状态
    if (launchOptions != nil) {
        NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        //处理iOS10以下的推送消息
        if (userInfo != nil && SYSTEM_VERSION_LESS_THAN(@"10")) {
            NSLog(@"userInfo->%@", userInfo[@"aps"]);
            [self handRemotePushNotificationWithUserInfo:userInfo];
        }
    }
}


//打开推送，注册远程推送
- (void)openRemotPush {
    [XGPush isPushOn:^(BOOL isPushOn) {
        NSLog(@"==== Push Is %@", isPushOn ? @"ON" : @"OFF");
    }];
    [self registerAPNS];

}

//关闭推送，注销信鸽绑定设备,
- (void)closeRemotePush {
//    if(![XGPush isUnRegisterStatus]){
//    }
    [XGPush unRegisterDevice:^{
        Log(@"XGPush unRegisterDevice Success");
    }          errorCallback:^{
        Log(@"XGPush unRegisterDevice Faild");
    }];
}

//处理推送消息
- (void)handRemotePushNotificationWithUserInfo:(NSDictionary *)userInfo {
    NSString *urlString = userInfo[@"url"];
    if(urlString){
        NSURL *url = [NSURL URLWithString:urlString];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else{
            [[UIApplication sharedApplication] openURL:url];
        }
    }

}


@end
