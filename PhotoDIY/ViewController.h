//
//  ViewController.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDDrawView;
@class LWToolBar;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet PDDrawView *drawView;
@property (weak, nonatomic) IBOutlet LWToolBar *toolBar;

@end


@interface LWToolBar:UIView


@end