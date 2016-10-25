//
//  LWScrawlView.h
//  PhotoDIY
//
//  Created by luowei on 16/9/30.
//  Copyright © 2016年 wodedata. All rights reserved.
//  涂鸦视图

#import <UIKit/UIKit.h>

@interface LWScrawlView : UIView

//是否橡皮擦模式
@property (nonatomic, assign) BOOL isEraseMode;
@property (nonatomic, assign) BOOL isLine;
@property (nonatomic, assign) BOOL isLineArrow;
@property (nonatomic, assign) BOOL isRect;
@property (nonatomic, assign) BOOL isOval;
@property (nonatomic, assign) BOOL isText;
@property(nonatomic, assign) BOOL isTile;

//自由画笔颜色
@property(nonatomic, assign) NSInteger freeInkColorIndex;
//自由画笔线宽
@property(nonatomic, assign) CGFloat freeInkLinewidth;



//画板重置
-(IBAction) resetDrawing;

@end
