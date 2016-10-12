//
//  LWScratchView.h
//  PhotoDIY
//
//  Created by luowei on 16/9/30.
//  Copyright © 2016年 wodedata. All rights reserved.
//  马赛克草稿用的

#import <UIKit/UIKit.h>

@interface LWScratchView : UIView{
    CGPoint previousTouchLocation;
    CGPoint currentTouchLocation;

    CGImageRef hideImage;
    CGImageRef scratchImage;

    CGContextRef contextMask;
}

@property (nonatomic, assign) float sizeBrush;

@property(nonatomic,weak) IBOutlet UIButton *mosaicBtn;


- (void)setHideView:(UIView *)hideView;



@end
