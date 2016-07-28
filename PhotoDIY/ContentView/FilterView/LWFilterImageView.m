//
//  LWFilterImageView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/27.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWFilterImageView.h"
#import "Categorys.h"
#import "LWDataManager.h"
#import "LWContentView.h"

@implementation LWFilterImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
    self.contentMode = UIViewContentModeScaleAspectFill;

}

- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [super rotationToInterfaceOrientation:orientation];
    [self reloadGPUImagePicture];
}

- (void)reloadGPUImagePicture{
    LWDataManager *dm = [LWDataManager sharedInstance];
    if (!dm.currentImage) {
        return;
    }
    self.contentMode = UIViewContentModeScaleAspectFill;

    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:dm.currentImage smoothlyScaleOutput:YES];
    [self.sourcePicture forceProcessingAtSize:dm.currentImage.size];
    [self.sourcePicture addTarget:self];
    [self.sourcePicture processImage];
}

//load 照片到 GPUImagePicture
- (void)loadImage2GPUImagePicture:(UIImage *)image {
    if (!image) {
        return;
    }
    self.contentMode = UIViewContentModeScaleAspectFill;

    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    [self.sourcePicture forceProcessingAtSize:image.size];
    [self.sourcePicture addTarget:self];
    [self.sourcePicture processImage];
}

- (void)renderWithFilter:(GPUImageOutput <GPUImageInput> *)filter {
    LWDataManager *dm = [LWDataManager sharedInstance];

    self.filter = filter;
    [self.filter forceProcessingAtSize:dm.currentImage.size];
    [self.sourcePicture removeAllTargets];
    [self.filter removeAllTargets];

    [self.sourcePicture addTarget:self.filter];
    [self.filter addTarget:self];

    [self.filter useNextFrameForImageCapture];
    [self.sourcePicture processImage];

    UIImage *image = [self.filter imageFromCurrentFramebuffer];

    //重新加载图片
    LWContentView *contentView = [self superViewWithClass:[LWContentView class]];
    [contentView reloadImage:image];
}

@end
