//
// Created by luowei on 16/10/8.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWDrafter.h"
#import "LWDrawBar.h"
#import "MyExtensions.h"


@implementation LWDrafter {

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pointArr = [NSMutableArray array];
        _isNew = YES;
        _colorIndex = 0;
    }
    return self;
}

- (UIColor *)color {
    return [UIColor colorWithHexString:Color_Items[(NSUInteger) _colorIndex]];
}


@end