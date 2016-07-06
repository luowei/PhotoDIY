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
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    [self.sourcePicture addTarget:self.gpuImageView];
    [self.sourcePicture processImage];
}

//加载照片选择器
- (void)showPhotos {

    self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    if(!self.photoCollectionView.hidden){
        [self removeConstraint:self.gpuImgPaddingBottomZero];
        [self.gpuImageView removeConstraint:self.gpuImgPaddingFiltersCollectionV];
        [self addConstraint:self.gpuImgPaddingPhotosCollectionV];
        [self setNeedsUpdateConstraints];

        [self.photoCollectionView reloadPhotos];
    }else{
        [self.gpuImageView removeConstraint:self.gpuImgPaddingFiltersCollectionV];
        [self removeConstraint:self.gpuImgPaddingPhotosCollectionV];
        [self addConstraint:self.gpuImgPaddingBottomZero];
        [self setNeedsUpdateConstraints];
    }

}

//加载滤镜
-(void)showFilters{
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

    //加载滤镜图
//    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
//    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
//    self.filter = [[GPUImageTiltShiftFilter alloc] init];
//
//    [self.filter forceProcessingAtSize:self.gpuImageView.sizeInPixels];
//
//    [self.sourcePicture addTarget:self.filter];
//    [self.filter addTarget:self.gpuImageView];
//
//    [self.sourcePicture processImage];
}


#pragma mark - PDPhotoPickerProtocol 实现

- (void)collectPhotoFailed {

}

- (void)loadPhoto:(UIImage *)image{
    if(!image){
        return;
    }
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    [self.sourcePicture addTarget: self.gpuImageView];
    [self.sourcePicture processImage];
}


@end
