//
// Created by Luo Wei on 2017/9/4.
// Copyright (c) 2017 wodedata. All rights reserved.
//

#import "LWHelper.h"
#import "MBProgressHUD.h"
#import "LWSettingViewController.h"


@implementation LWHelper {

}

+(void)showHUDWithMessage:(NSString *)message{
    if(!message || message.length == 0){
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = message;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}
+(void)showHUDWithDetailMessage:(NSString *)message{
    if(!message || message.length == 0){
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.detailsLabel.text = message;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

+(MBProgressHUD *)showHUDWithMessage:(NSString *)message mode:(MBProgressHUDMode)mode {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = message;
    hud.mode = mode;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}


//判断是否是指定日期之后,dateString 格式 ：yyyy-MM-dd
+ (BOOL)isAfterDate:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger days = [LWHelper daysBetweenDate:dateString andDate:currentDate];
    return days >= 0;
}


//获得两个时间之间的日差
+ (NSInteger)daysBetweenDate:(NSString *)fromDateTime andDate:(NSString *)toDateTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *from = [dateFormatter dateFromString:fromDateTime];
    NSDate *to = [dateFormatter dateFromString:toDateTime];

    NSDate *fromDate;
    NSDate *toDate;
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:from];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:to];

    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

//是否已经购买过了
+(BOOL)isPurchased {
    NSNumber *isPurchasedValue = [[NSUserDefaults standardUserDefaults] objectForKey:Key_isPurchasedSuccessedUser];
    return isPurchasedValue && [isPurchasedValue boolValue];
}

@end
