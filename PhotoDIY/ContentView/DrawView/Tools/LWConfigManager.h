//
// Created by luowei on 16/10/8.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface LWConfigManager : NSObject

// 取单例
+(id)sharedInstance;

// 获取颜色数组
-(NSArray *)getStandardColorArray;

-(void)setFreeInkColorWithIndex:(NSInteger)index;

-(UIColor *)getFreeInkColorWithIndex:(NSInteger)index;

-(NSInteger)getInkColorIndex;

// 设定自由画笔笔迹宽度
-(void)setFreeInkLineWidth:(CGFloat)lineWidth;

-(CGFloat)getFreeInkLineWidth;

@end