//
//  LWImageView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/27.
//  Copyright (c) 2016 wodedata. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "LWImageView.h"
#import "LWDataManager.h"
#import "LWContentView.h"
#import "Categorys.h"

@implementation LWImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentMode = UIViewContentModeScaleAspectFit;
}


- (void)rotateWithRotateMode:(GPUImageRotationMode)rotateMode {
    LWDataManager *dm = [LWDataManager sharedInstance];
    UIImage *image = dm.currentImage;
    CGFloat scale = [UIScreen mainScreen].scale;
    switch (rotateMode) {
        case kGPUImageRotateLeft: {
            image = [self rotateUIImage:image orientation:UIImageOrientationLeft];
            break;
        }
        case kGPUImageRotateRight: {
            image = [self rotateUIImage:image orientation:UIImageOrientationRight];
            break;
        }
        case kGPUImageFlipVertical: {
            image = [self rotateUIImage:image orientation:UIImageOrientationDownMirrored];
            image = [self rotateUIImage:image orientation:UIImageOrientationUp];
            break;
        }
        case kGPUImageFlipHorizonal: {
            image = [self rotateUIImage:image orientation:UIImageOrientationLeftMirrored];
            image = [self rotateUIImage:image orientation:UIImageOrientationRight];
            break;
        }
        case kGPUImageRotate180: {
            image = [self rotateUIImage:image orientation:UIImageOrientationDown];
            break;
        }
        default: {
            break;
        }
    }

    LWContentView *contentView = [self superViewWithClass:[LWContentView class]];
    [contentView reloadImage:image];

}

- (UIImage *)rotateUIImage:(UIImage *)sourceImage orientation:(UIImageOrientation)orientation {
    CGSize size = sourceImage.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:scale orientation:orientation]
            drawInRect:CGRectMake(0, 0, size.height, size.width)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (void)rotateRight {
    [self rotateWithRotateMode:kGPUImageRotateRight];
}

- (void)rotateLeft {
    [self rotateWithRotateMode:kGPUImageRotateLeft];
}

- (void)flipHorizonal {
    [self rotateWithRotateMode:kGPUImageFlipHorizonal];
}

@end
