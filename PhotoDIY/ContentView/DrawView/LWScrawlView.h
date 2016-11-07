//
//  LWScrawlView.h
//  PhotoDIY
//
//  Created by luowei on 16/9/30.
//  Copyright © 2016年 wodedata. All rights reserved.
//  涂鸦视图

#import <UIKit/UIKit.h>
#import "LWDrafter.h"

@class LWControlImgV;
@class LWControlView;

@interface LWScrawlView : UIView

//是否橡皮擦模式
@property (nonatomic,assign) DrawType drawType;

//自由画笔颜色
@property(nonatomic, assign) NSInteger freeInkColorIndex;
//自由画笔线宽
@property(nonatomic, assign) CGFloat freeInkLinewidth;

//曲线集
@property (nonatomic, strong) NSMutableArray *curves;

@property(nonatomic, assign) NSInteger tileImageIndex;

@property(nonatomic, strong) NSURL *tileImageUrl;

@property(nonatomic, copy) NSString *fontName;

@property(nonatomic, weak) IBOutlet  UITextView *textView;
@property(nonatomic, weak) IBOutlet  NSLayoutConstraint *textConstraintX;
@property(nonatomic, weak) IBOutlet  NSLayoutConstraint *textConstraintY;

@property(nonatomic, weak) IBOutlet  LWControlView *controlView;
@property(nonatomic, weak) IBOutlet  NSLayoutConstraint *viewConstraintX;
@property(nonatomic, weak) IBOutlet  NSLayoutConstraint *viewConstraintY;

@property(nonatomic, weak) IBOutlet  LWControlImgV *control;
@property(nonatomic, weak) IBOutlet  NSLayoutConstraint *controlConstraintX;
@property(nonatomic, weak) IBOutlet  NSLayoutConstraint *controlConstraintY;

//画板重置
-(IBAction) resetDrawing;

@end


//文本输入框
@interface LWScratchTextView : UITextView


@end


//控制按钮
@interface LWControlImgV : UIImageView



@end


//控制框
@interface LWControlView : UIView

@property(nonatomic, weak) IBOutlet  LWControlImgV *control;
@property(nonatomic, weak) IBOutlet  LWControlImgV *rotate;

@end

