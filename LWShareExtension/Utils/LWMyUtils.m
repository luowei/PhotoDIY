//
// Created by luowei on 2018/1/24.
// Copyright (c) 2018 wodedata. All rights reserved.
//

#import "LWMyUtils.h"


@implementation LWMyUtils {

}

+(NSURL *)URLWithGroupName:(NSString *)group {
    //获取App分组的共享目录
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:group];
    return groupURL;
}

+(NSURL *)writableURLWithGroupName:(NSString *)group {
    //获取App分组的共享目录
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:group];
    if(![[NSFileManager defaultManager] isWritableFileAtPath:groupURL.path]){
        groupURL = [groupURL URLByAppendingPathComponent: @"Library" isDirectory: YES];
        groupURL = [groupURL URLByAppendingPathComponent:@"Caches" isDirectory: YES];
    }
    return groupURL;
}


+(NSString *)getCurrentTimeStampText {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *timeStampText = [dateFormatter stringFromDate:[NSDate new]];
    return timeStampText;
}

@end