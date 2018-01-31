//
// Created by luowei on 2018/1/24.
// Copyright (c) 2018 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LWMyUtils : NSObject

+(NSURL *)URLWithGroupName:(NSString *)group;

+(NSURL *)writableURLWithGroupName:(NSString *)group;

+(NSString *)getCurrentTimeStampText;

@end