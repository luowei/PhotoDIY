//
//  NSHTTPCookie+javascriptString.m
//  ACERepair
//
//  Created by apple  on 16/5/18.
//  Copyright © 2016年 wodedata.com. All rights reserved.
//

#import "NSHTTPCookie+javascriptString.h"

@implementation NSHTTPCookie (javascriptString)

- (NSString *)javascriptString {
    NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",
                        self.name,
                        self.value,
                        self.domain,
                        self.path ?: @"/"];
    
    if (self.secure) {
        string = [string stringByAppendingString:@";secure=true"];
    }
    
    return string;
}

@end
