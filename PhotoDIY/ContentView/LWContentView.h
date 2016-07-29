//
//  LWContentView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "PDPhotoLibPicker.h"
#import "LWDataManager.h"

@class LWFilterCollectionView;
@class LWPhotoCollectionView;
@class MBProgressHUD;
@class LWImageCropView;
@class LWDrawView;
@class LWImageZoomView;
@class LWFilterImageView;

@interface LWContentView : UIView<PDPhotoPickerProtocol>

@property(nonatomic,weak) IBOutlet LWImageZoomView *zoomView;
@property(nonatomic,weak) IBOutlet LWFilterImageView *filterView;
@property(nonatomic,weak) IBOutlet LWImageCropView *cropView;
@property(nonatomic,weak) IBOutlet LWDrawView *drawView;

@property(nonatomic,weak) IBOutlet LWFilterCollectionView *filterCollectionView;
@property(nonatomic,weak) IBOutlet LWPhotoCollectionView *photoCollectionView;


@property(nonatomic,weak) IBOutlet NSLayoutConstraint *imageVPaddingZero;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *imageVPaddingPhotosBar;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *imageVPaddingFiltersBar;

@property(nonatomic,weak) IBOutlet NSLayoutConstraint *filterVPaddingZero;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *filterVPaddingPhotosBar;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *filterVPaddingFiltersBar;


@property(nonatomic, strong) MBProgressHUD *hud;

@property(nonatomic, strong) UIImage *originImage;

@property(nonatomic) enum DIYMode currentMode;

//加载默认图片
- (void)loadDefaultImage;

- (void)reloadImage:(UIImage *)image;

//加载照片
- (void)showPhotos;

//加载滤镜
-(void)showFilters;

- (void)saveImage;

- (void)recovery;

- (void)showOrHideCropView;

- (void)cropImageOk;

- (void)cancelCropImage;
@end
