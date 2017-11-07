//
// Created by Luo Wei on 2017/9/4.
// Copyright (c) 2017 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface LWHelper : NSObject

+(void)showHUDWithMessage:(NSString *)message;
+(void)showHUDWithDetailMessage:(NSString *)message;

+(MBProgressHUD *)showHUDWithMessage:(NSString *)message mode:(MBProgressHUDMode)mode;


//判断是否是指定日期之后,dateString 格式 ：yyyy-MM-dd
+ (BOOL)isAfterDate:(NSString *)dateString;
//获得两个时间之间的日差
+ (NSInteger)daysBetweenDate:(NSString *)fromDateTime andDate:(NSString *)toDateTime;

//是否已经购买过了
+(BOOL)isPurchased;

@end