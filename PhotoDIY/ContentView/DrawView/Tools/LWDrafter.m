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
        _rotateAngle = 0;
    }
    return self;
}

- (UIColor *)color {
    return [UIColor colorWithHexString:Color_Items[(NSUInteger) _colorIndex]];
}


-(NSShadow *)shadow {
    if(!_shadow){
        UIColor *shadowColor = self.color.isLight ? [UIColor.blackColor colorWithAlphaComponent:0.6] : [UIColor.whiteColor colorWithAlphaComponent:0.6];
        _shadow = [[NSShadow alloc] init];
        [_shadow setShadowColor:shadowColor];
        [_shadow setShadowOffset:CGSizeMake(1.1, 1.1)];
        [_shadow setShadowBlurRadius:2];
    }
    return _shadow;
}

@end