//
//  AppDelegate.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "AppDelegate.h"
#import <StoreKit/StoreKit.h>
#import "LWPushManager.h"
#import "XGPush.h"
#import "Categorys.h"
#import <UMSocialCore/UMSocialCore.h>
#import <GoogleMobileAds/GADMobileAds.h>



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    application.applicationIconBadgeNumber = 0;
    //程序启动时处理推送
    [[LWPushManager shareManager] handPushInApplicationDidFinishLaunchingWithOptions:launchOptions];

    [GADMobileAds configureWithApplicationID:@"ca-app-pub-8760692904992206~9489732700"];

    //打开日志
    [[UMSocialManager defaultManager] openLog:YES];
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"582bd955ae1bf879f700044f"];


    NSString *redirectURL = @"http://wodedata.com/PhotoDIY/AppCallback.php";
//    NSString *redirectURL = @"PhotoDIY://";
    //各平台的详细配置
    //设置微信的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxe9ee15bc76746188" appSecret:@"fb4ca3b28e9110091fad90769279e789" redirectURL:redirectURL];

    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105751861" appSecret:@"umZZAIFQOJwnRmYy" redirectURL:redirectURL];

    //设置新浪的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3082351787" appSecret:@"51f1d3ff556e7ab2f593ab787c4cabad" redirectURL:redirectURL];

    //设置Twitter的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Twitter appKey:@"CHbOjdkIMQgUKRkHBr2Oz77ij" appSecret:@"ACPIwOzeWfFMVIpUEsCA0VxydhuOELAql2EakyoYf1kbZnnvUY" redirectURL:redirectURL];

//    //设置Facebook的appKey和UrlString
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Facebook appKey:@"326136004438567" appSecret:@"43eafc5c6dde0656e7031c40f414b8fc" redirectURL:redirectURL];

    //设置Instagram的appKey和UrlString
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Instagram appKey:@"47a60b44365442e3b16b2b052bd8f0b6" appSecret:@"ee31f229723641c4b3084f05cdbbec00" redirectURL:redirectURL];

//    // Attach an observer to the payment queue
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:[StoreObserver sharedInstance]];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

//    // Remove the observer
//    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[StoreObserver sharedInstance]];
}


//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    if (self.portraitVC) {
//        return UIInterfaceOrientationMaskAll;
//    } else {
//        return UIInterfaceOrientationMaskPortrait;
//    }
//}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) { // 其他如支付等SDK的回调
    }

    NSString *from = [url queryDictionary][@"from"];
    NSTimeInterval duration = [from isEqualToString:@"native"] ? .05 : .15;

    NSString *host = [url host];
    NSString *hostPrefix = [host subStringWithRegex:@"^([\\w_-]*)\\..*" matchIndex:1];
    [self performSelector:@selector(postNotification:) withObject:@{@"URL": url} afterDelay:duration];

    return YES;
}

- (void)postNotification:(NSDictionary *)dict {
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_ShowViewController object:nil userInfo:dict];
}


#pragma mark - 处理推送

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {

}

//远程通知 Remote Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //向信息注册设备号
    NSString *deviceTokenStr = [XGPush registerDevice:deviceToken account:nil successCallback:^{
        Log(@"XGPush registerDevice:%@ account:%@  Success", deviceToken, nil);
    }                                   errorCallback:^{
        Log(@"XGPush registerDevice:%@ account:%@  Faild", deviceToken, nil);
    }];
    NSLog(@"[PhotoDIY] device token is %@", deviceTokenStr);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {

    }
    return result;
}


//收到静默推送的回调
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    //清除角标
    application.applicationIconBadgeNumber = 0;

    //处理推送消息
    [[LWPushManager shareManager] handRemotePushNotificationWithUserInfo:userInfo];

    //推送反馈XG
    [XGPush handleReceiveNotification:userInfo successCallback:nil errorCallback:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        Log(@"iOS Simulator 不支持远程推送消息");
    } else {
        Log(@"application:didFailToRegisterForRemoteNotificationsWithError:%@", error.localizedFailureReason);
    }
}


//handleAction
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {

}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {

}

//本地通知 Local Notification
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {

}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {

}

//收到远程通知的回调,iOS10 废弃的方法 Deprecated Message
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    Log(@"--------%d:%s \n\n", __LINE__, __func__);
    //清除角标
    application.applicationIconBadgeNumber = 0;

    //处理推送消息
    [[LWPushManager shareManager] handRemotePushNotificationWithUserInfo:userInfo];

    //推送反馈XG
    [XGPush handleReceiveNotification:userInfo successCallback:nil errorCallback:nil];
}

//收到本地通知的回调
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    Log(@"--------%d:%s \n\n", __LINE__, __func__);
    //清除角标
    application.applicationIconBadgeNumber = 0;
}


@end
