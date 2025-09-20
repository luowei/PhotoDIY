//
//  USAssetScrollView.h
//  USImagePickerController
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "USTorusIndicatorView.h"

@interface USAssetScrollView : UIScrollView

@property (nonatomic, weak, readonly) UIImageView *imageView;

@property (nonatomic, weak) USTorusIndicatorView *indicatorView;

- (void)initWithImage:(UIImage *)image;

- (void)initWithALAsset:(ALAsset *)asset;

- (void)initWithPHAsset:(PHAsset *)asset;

- (void)doubleTapWithPoint:(CGPoint)point;

@end
