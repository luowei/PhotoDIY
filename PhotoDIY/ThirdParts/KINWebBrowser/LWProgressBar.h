//
//  LWProgressBar.h
//  union
//
//  Created by apple on 16/5/6.
//  Copyright © 2016年 wodedata.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWProgressBar : UIView

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) CGFloat progress;
@property(nonatomic, strong) UIView *progressView;

- (void)progressUpdate:(CGFloat)progress;
- (void)setProgressZero;

@end
