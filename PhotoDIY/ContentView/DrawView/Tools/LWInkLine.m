//
// Created by luowei on 16/10/8.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWInkLine.h"


@implementation LWInkLine {

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pointArr = [NSMutableArray array];
        _isNew = YES;
    }
    return self;
}

@end