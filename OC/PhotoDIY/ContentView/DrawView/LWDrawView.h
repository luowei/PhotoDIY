//
//  LWDrawView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/27.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWDataManager.h"

@class LWScratchView;
@class LWScrawlView;
@class LWDrawBar;

@interface LWDrawView : UIView

@property(nonatomic,weak) IBOutlet UIImageView *mosaicImageView;
@property(nonatomic,weak) IBOutlet LWScratchView *scratchView;
@property(nonatomic,weak) IBOutlet LWScrawlView *scrawlView;

@property(nonatomic,weak) IBOutlet LWDrawBar *drawBar;
@property(nonatomic,weak) IBOutlet UIButton *mosaicBtn;
@property(nonatomic,weak) IBOutlet UIButton *deleteBtn;
@property(nonatomic,weak) IBOutlet UIButton *okBtn;
@property(nonatomic,weak) IBOutlet UIButton *editBtn;


@property(nonatomic,weak) IBOutlet NSLayoutConstraint *clearBottomConstrant;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *okBottomConstrant;


@property(nonatomic) BOOL oldHiddenStatus;

@property(nonatomic) enum DIYMode oldDrawMode;

- (IBAction)openOrCloseMosaic:(UIButton *)mosaicButton;
-(IBAction)okAction:(UIButton *)okBtn;

- (void)setImage:(UIImage *)image;

//暂存绘制的图片
- (void)cacheDrawImage;

//获得drawView 的 Image
-(UIImage *)drawImage;

@end
