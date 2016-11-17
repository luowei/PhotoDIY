//
//  AppDelegate.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "AppDelegate.h"
#import <StoreKit/StoreKit.h>
#import "StoreObserver.h"

#import <UMSocialCore/UMSocialCore.h>



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //打开日志
    [[UMSocialManager defaultManager] openLog:YES];
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"582bd955ae1bf879f700044f"];


//    NSString *redirectURL = @"http://wodedata.com/PhotoDIY/AppCallback.php";
    NSString *redirectURL = @"PhotoDIY://";
    //各平台的详细配置
    //设置微信的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"xxxxxxxxxxxxxx" appSecret:@"xxxxxxxxxxxxxxxxxxxxx" redirectURL:redirectURL];

    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105751861" appSecret:@"umZZAIFQOJwnRmYy" redirectURL:redirectURL];

    //设置新浪的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3082351787" appSecret:@"51f1d3ff556e7ab2f593ab787c4cabad" redirectURL:redirectURL];

    //设置Twitter的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Twitter appKey:@"CHbOjdkIMQgUKRkHBr2Oz77ij" appSecret:@"ACPIwOzeWfFMVIpUEsCA0VxydhuOELAql2EakyoYf1kbZnnvUY" redirectURL:redirectURL];

    //设置Facebook的appKey和UrlString
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Facebook appKey:@"325600794492088" appSecret:@"c8387c35222f95bfab9550ab182b94bd" redirectURL:redirectURL];

    //设置Instagram的appKey和UrlString
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Instagram appKey:@"47a60b44365442e3b16b2b052bd8f0b6" appSecret:@"ee31f229723641c4b3084f05cdbbec00" redirectURL:redirectURL];

    // Attach an observer to the payment queue
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[StoreObserver sharedInstance]];
    return YES;
}

//回调处理
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) { // 其他如支付等SDK的回调
    }
    return result;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {

    }
    return result;
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

    // Remove the observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[StoreObserver sharedInstance]];
}


//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    if (self.portraitVC) {
//        return UIInterfaceOrientationMaskAll;
//    } else {
//        return UIInterfaceOrientationMaskPortrait;
//    }
//}

@end
