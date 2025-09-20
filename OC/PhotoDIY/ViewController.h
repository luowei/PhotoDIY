//
//  ViewController.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressBar.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define Key_AdOpenCount @"Key_AdOpenCount"

@class LWContentView;
@class LWToolBar;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet LWContentView *contentView;
@property (weak, nonatomic) IBOutlet LWToolBar *toolBar;
//@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *previewIcon;

@property(nonatomic, strong) CircleProgressBar *circleProgressBar;
@property(nonatomic, strong) NSDictionary <NSString *,NSString *>* fontURLMap;
@end


@interface LWToolBar:UIView


@end


@interface LWTittleView : UIView

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;

@end