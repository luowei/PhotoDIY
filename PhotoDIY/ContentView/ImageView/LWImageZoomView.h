//
//  LWImageZoomView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/27.
//  Copyright (c) 2016 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWImageZoomView : UIScrollView<UIScrollViewDelegate>

@property(nonatomic,weak) IBOutlet UIImageView *imageView;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *leadingConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *trainingConstraint;

- (void)setImage:(UIImage *)image;

- (void)rotateRight;

- (void)rotateLeft;

- (void)flipHorizonal;

@end
