//
// Created by luowei on 16/10/8.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWConfigManager.h"


@implementation LWConfigManager {
    NSInteger _inkColorIndex;  // 自由画笔颜色定位
    CGFloat _inkLineWidth;     //自由画笔划线粗细
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setData];
    }
    return self;
}


+ (id)sharedInstance {
    static LWConfigManager *manager = nil;

    @synchronized (self) {
        if (!manager)
            manager = [[LWConfigManager alloc] init];
    }
    return manager;
}

- (void)setData {
    /**
        设置初始化的值
     */
    _inkColorIndex = 0;
    _inkLineWidth = 3.0;

}




- (NSArray *)getStandardColorArray {
    return @[[UIColor colorWithRed:0 green:0 blue:0 alpha:1],
            [UIColor colorWithRed:0 green:0 blue:1 alpha:1],
            [UIColor colorWithRed:234/255.0 green:51/255.0 blue:25/255.0 alpha:1],
            [UIColor colorWithRed:99/255.0 green:154/255.0 blue:68/255.0 alpha:1],
            [UIColor colorWithRed:1 green:1 blue:1 alpha:1],
            [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1],
            [UIColor colorWithRed:151/255.0 green:33/255.0 blue:19/255.0 alpha:1],
            [UIColor colorWithRed:200/255.0 green:89/255.0 blue:45/255.0 alpha:1],
            [UIColor colorWithRed:220/255.0 green:96/255.0 blue:42/255.0 alpha:1],
            [UIColor colorWithRed:228/255.0 green:159/255.0 blue:62/255.0 alpha:1],
            [UIColor colorWithRed:238/255.0 green:195/255.0 blue:71/255.0 alpha:1],
            [UIColor colorWithRed:241/255.0 green:230/255.0 blue:107/255.0 alpha:1],
            [UIColor colorWithRed:210/255.0 green:218/255.0 blue:76/255.0 alpha:1],
            [UIColor colorWithRed:182/255.0 green:209/255.0 blue:92/255.0 alpha:1],
            [UIColor colorWithRed:43/255.0 green:96/255.0 blue:30/255.0 alpha:1],
            [UIColor colorWithRed:134/255.0 green:175/255.0 blue:212/255.0 alpha:1],
            [UIColor colorWithRed:25/255.0 green:49/255.0 blue:139/255.0 alpha:1],
            [UIColor colorWithRed:158/255.0 green:120/255.0 blue:227/255.0 alpha:1],
            [UIColor colorWithRed:172/255.0 green:108/255.0 blue:228/255.0 alpha:1],
            [UIColor colorWithRed:165/255.0 green:74/255.0 blue:149/255.0 alpha:1],
            [UIColor colorWithRed:214/255.0 green:98/255.0 blue:165/255.0 alpha:1],
            [UIColor colorWithRed:229/255.0 green:85/255.0 blue:126/255.0 alpha:1],
            [UIColor colorWithRed:246/255.0 green:199/255.0 blue:209/255.0 alpha:1],
            [UIColor colorWithRed:247/255.0 green:206/255.0 blue:252/255.0 alpha:1]];
}

- (UIColor *)getFreeInkColorWithIndex:(NSInteger)index {
    NSArray *colorArr = [[LWConfigManager sharedInstance] getStandardColorArray];
    return colorArr[index];
}


- (void)setFreeInkColorWithIndex:(NSInteger)index {
    _inkColorIndex = index;
}

- (NSInteger)getInkColorIndex {
    return _inkColorIndex;
}

- (void)setFreeInkLineWidth:(CGFloat)lineWidth {
    _inkLineWidth = lineWidth;
}

- (CGFloat)getFreeInkLineWidth {
    return _inkLineWidth;
}





@end