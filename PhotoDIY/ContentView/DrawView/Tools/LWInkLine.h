//
// Created by luowei on 16/10/8.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface LWInkLine : NSObject

@property (nonatomic, strong) NSMutableArray *pointArr;
@property (nonatomic, assign) NSInteger colorIndex;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic,assign) BOOL isEraseMode;
@property (nonatomic,assign) BOOL isLine;
@property (nonatomic,assign) BOOL isLineArrow;
@property (nonatomic,assign) BOOL isRect;
@property (nonatomic,assign) BOOL isOval;
@property (nonatomic, assign) BOOL isText;
@property(nonatomic, assign) BOOL isTile;


@end