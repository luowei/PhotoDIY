//
//  LWImageZoomView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/27.
//  Copyright (c) 2016 wodedata. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "LWImageZoomView.h"
#import "LWDataManager.h"
#import "LWContentView.h"
#import "Categorys.h"

@implementation LWImageZoomView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.minimumZoomScale = 0.5;
    self.maximumZoomScale = 2.0;
    self.delegate = self;

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    self.contentSize = self.imageView.frame.size;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self updateConstraintsForSize:self.bounds.size];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

-(void)updateConstraintsForSize:(CGSize)size{
    CGFloat yOffset = MAX(0, (size.height - self.imageView.frame.size.height) / 2);
    CGFloat xOffset = MAX(0, (size.width - self.imageView.frame.size.width) / 2);

    self.topConstraint.constant = yOffset;
    self.bottomConstraint.constant = yOffset;
    self.leadingConstraint.constant = xOffset;
    self.trainingConstraint.constant = xOffset;

    [self layoutIfNeeded];
}

-(void)updateMinZoomScaleForSize:(CGSize)size{
    CGFloat widthScale = size.width / self.imageView.bounds.size.width;
    CGFloat heightScale = size.height / self.imageView.bounds.size.height;
    CGFloat minScale = MIN(widthScale, heightScale);

    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
}

- (void)didLayoutSubviews {
    [super didLayoutSubviews];
    [self updateMinZoomScaleForSize:self.bounds.size];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
////    if (gestureRecognizer==_panRecognizer && otherGestureRecognizer==_swipeRecognizer)
////        return YES;
////    if (gestureRecognizer==_swipeRecognizer && otherGestureRecognizer==_panRecognizer)
////        return YES;
////    return NO;
//    return YES;
//}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
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
