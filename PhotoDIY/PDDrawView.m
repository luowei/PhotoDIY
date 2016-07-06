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

//加载照片
-(void)loadImageWithURL:(NSURL *)url{
    PDPhotoLibPicker *photoPicker = [[PDPhotoLibPicker alloc] initWithDelegate:self];
    photoPicker.delegate = self;
    [photoPicker pictureWithURL:url];
}

//加载照片选择器
- (void)loadPhotos {

    self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    if(!self.photoCollectionView.hidden){
        [self.photoCollectionView reloadPhotos];
    }

}

//加载滤镜
-(void)loadFilter{
    self.filterCollectionView.hidden = !self.filterCollectionView.hidden;
    if(!self.filterCollectionView.hidden){
        [self.filterCollectionView reloadData];
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
    [self.sourcePicture processImage];
    [self.sourcePicture addTarget: self.gpuImageView];
}


@end
