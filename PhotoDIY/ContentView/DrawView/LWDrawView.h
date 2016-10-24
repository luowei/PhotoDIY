//
//  LWDrawView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/27.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

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


- (IBAction)openOrCloseMosaic:(UIButton *)mosaicButton;

- (void)setImage:(UIImage *)image;

@end
