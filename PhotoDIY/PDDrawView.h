//
//  PDDrawView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "PDPhotoLibPicker.h"

@class LWFilterCollectionView;
@class LWPhotoCollectionView;
@class MBProgressHUD;
@class LWImageCropView;

@interface PDDrawView : UIView<PDPhotoPickerProtocol>

@property(nonatomic,weak) IBOutlet GPUImageView *gpuImageView;
@property(nonatomic,weak) IBOutlet LWFilterCollectionView *filterCollectionView;
@property(nonatomic,weak) IBOutlet LWPhotoCollectionView *photoCollectionView;

@property(nonatomic,weak) IBOutlet LWImageCropView *cropView;


@property(nonatomic,weak) IBOutlet NSLayoutConstraint *gpuImgPaddingBottomZero;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *gpuImgPaddingPhotosCollectionV;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *gpuImgPaddingFiltersCollectionV;


@property(nonatomic,strong) GPUImagePicture *sourcePicture;
@property(nonatomic,strong) GPUImageOutput<GPUImageInput> *filter;

@property(nonatomic, strong) UIImage *currentImage;

@property(nonatomic, strong) MBProgressHUD *hud;

@property(nonatomic, strong) UIImage *originImage;

//加载默认图片
- (void)loadDefaultImage;

//加载照片
- (void)showPhotos;

//加载滤镜
-(void)showFilters;

- (void)renderWithFilter:(GPUImageOutput<GPUImageInput> *)output;

- (void)saveImage;

- (void)rotateRight;

- (void)rotateLeft;

- (void)flipHorizonal;

- (void)showOrHideCropView;

- (void)cropImageOk;

- (void)cancelCropImage;
@end
