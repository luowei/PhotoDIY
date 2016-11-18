//
//  ViewController.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWContentView;
@class LWToolBar;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet LWContentView *contentView;
@property (weak, nonatomic) IBOutlet LWToolBar *toolBar;
//@property (weak, nonatomic) IBOutlet UIView *titleView;

@end


@interface LWToolBar:UIView


@end