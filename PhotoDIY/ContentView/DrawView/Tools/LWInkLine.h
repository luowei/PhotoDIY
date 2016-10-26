//
// Created by luowei on 16/10/8.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//键盘类型
typedef NS_OPTIONS(NSUInteger, DrawType) {
    Hand = 1,
    Erase = 1 << 1,
    Line = 1 << 2,
    LineArrow = 1 << 3,
    Rectangle = 1 << 4,
    Oval = 1 << 5,
    Text = 1 << 6,
    Tile = 1 << 7
};

@interface LWInkLine : NSObject

@property (nonatomic, strong) NSMutableArray *pointArr;
@property (nonatomic, assign) NSInteger colorIndex;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic,assign) DrawType drawType;


@property(nonatomic, assign) NSInteger tileImageIndex;
@end