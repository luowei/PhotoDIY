//
//  PDDrawView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "PDDrawView.h"
#import "Categorys.h"
#import "LWFilterCollectionView.h"
#import "LWPhotoCollectionView.h"

@implementation PDDrawView

- (void)awakeFromNib {
    [super awakeFromNib];

}

//加载默认图片
- (void)loadDefaultImage {
    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
    [self loadPhoto:inputImage];
}

//加载照片选择器
- (void)showPhotos {
    if(!self.filterCollectionView.hidden){
        self.filterCollectionView.hidden = !self.filterCollectionView.hidden;
    }

    self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    if(!self.photoCollectionView.hidden){
        [self removeConstraint:self.gpuImgPaddingBottomZero];
        [self removeConstraint:self.gpuImgPaddingFiltersCollectionV];
        [self addConstraint:self.gpuImgPaddingPhotosCollectionV];
        [self setNeedsUpdateConstraints];

        [self.photoCollectionView reloadPhotos];
    }else{
        [self removeConstraint:self.gpuImgPaddingFiltersCollectionV];
        [self removeConstraint:self.gpuImgPaddingPhotosCollectionV];
        [self addConstraint:self.gpuImgPaddingBottomZero];
        [self setNeedsUpdateConstraints];
    }

}

//加载滤镜
-(void)showFilters{
    if(!self.photoCollectionView.hidden){
        self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    }

    self.filterCollectionView.hidden = !self.filterCollectionView.hidden;
    if(!self.filterCollectionView.hidden){
        [self removeConstraint:self.gpuImgPaddingBottomZero];
        [self removeConstraint:self.gpuImgPaddingPhotosCollectionV];
        [self addConstraint:self.gpuImgPaddingFiltersCollectionV];
        [self setNeedsUpdateConstraints];

        [self.filterCollectionView reloadFilters];
    }else{
        [self removeConstraint:self.gpuImgPaddingFiltersCollectionV];
        [self removeConstraint:self.gpuImgPaddingPhotosCollectionV];
        [self addConstraint:self.gpuImgPaddingBottomZero];
        [self setNeedsUpdateConstraints];
    }
}


#pragma mark - PDPhotoPickerProtocol 实现

- (void)collectPhotoFailed {

}

- (void)loadPhoto:(UIImage *)image{
    if(!image){
        return;
    }
    self.currentImage = image;
    
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    [self.sourcePicture addTarget: self.gpuImageView];
    [self.sourcePicture processImage];
}


- (void)renderWithFilter:(GPUImageOutput<GPUImageInput> *)filter {
    self.filter = filter;
    [self.filter forceProcessingAtSize:self.sourcePicture.outputImageSize];
    [self.sourcePicture removeAllTargets];
    [self.filter removeAllTargets];

    [self.sourcePicture addTarget:self.filter];
    [self.filter addTarget:self.gpuImageView];

    [self.filter useNextFrameForImageCapture];
    [self.sourcePicture processImage];
    
    self.currentImage = [self.filter imageFromCurrentFramebuffer];
}

- (void)saveImage {
    [self.filter forceProcessingAtSize:self.sourcePicture.outputImageSize];
    [self.sourcePicture processImageUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage) {
        if(!processedImage){
            UIImageWriteToSavedPhotosAlbum(self.currentImage, self, nil, nil);
        }else{
            UIImageWriteToSavedPhotosAlbum(processedImage, self, nil, nil);
        }
    }];
}


- (void)rotateWithRotateMode:(GPUImageRotationMode)rotateMode {
    [self.filter setInputRotation:rotateMode atIndex:0];
    CGSize size = self.sourcePicture.outputImageSize;
    if(rotateMode == kGPUImageRotateRight || rotateMode == kGPUImageRotateLeft
            || rotateMode == kGPUImageRotateRightFlipHorizontal || rotateMode == kGPUImageRotateRightFlipVertical){
        size = CGSizeMake(self.sourcePicture.outputImageSize.height, self.sourcePicture.outputImageSize.width);
    }
    [self.filter forceProcessingAtSize:size];

    [self.filter useNextFrameForImageCapture];
    [self.sourcePicture processImage];

    UIImage *image = [self.filter imageByFilteringImage:self.currentImage];
    [self loadPhoto:image];
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
