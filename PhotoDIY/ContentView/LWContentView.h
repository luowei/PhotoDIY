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
@class LWPhotosBar;
@class LWFilterBar;

@interface LWContentView : UIView<PDPhotoPickerProtocol>

@property(nonatomic,weak) IBOutlet LWImageZoomView *zoomView;
@property(nonatomic,weak) IBOutlet LWFilterImageView *filterView;
@property(nonatomic,weak) IBOutlet LWImageCropView *cropView;
@property(nonatomic,weak) IBOutlet LWDrawView *drawView;

@property(nonatomic,weak) IBOutlet LWFilterBar *filterBar;
@property(nonatomic,weak) IBOutlet LWFilterCollectionView *filterCollectionView;

@property(nonatomic,weak) IBOutlet LWPhotosBar *photosBar;
@property(nonatomic,weak) IBOutlet LWPhotoCollectionView *photoCollectionView;


@property(nonatomic,weak) IBOutlet NSLayoutConstraint *filterVPaddingZero;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *filterVPaddingPhotosBar;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *filterVPaddingFiltersBar;


@property(nonatomic, strong) MBProgressHUD *hud;

@property(nonatomic) enum DIYMode currentMode;

@property(nonatomic, strong) NSArray *imageURLs;

//加载默认图片
- (void)loadDefaultImage;

- (void)reloadImage:(UIImage *)image;

//加载照片
- (void)showPhotos;

//加载滤镜
-(void)showFilters;

- (void)saveImage;

//获取同步的图片
-(UIImage *)getSyncImage;

- (void)recovery;

- (void)showOrHideCropView;

- (void)cropImageOk;

- (void)cancelCropImage;

- (void)showDrawView;
@end



@interface LWPhotosBar:UIView

@property(nonatomic,weak) IBOutlet UIButton *flipBtn;
@property(nonatomic,weak) IBOutlet UIButton *recovationBtn;
@property(nonatomic,weak) IBOutlet UIButton *leftRotateBtn;
@property(nonatomic,weak) IBOutlet UIButton *rightRotateBtn;

@end

@interface LWFilterBar:UIView

@property(nonatomic,weak) IBOutlet UISlider *slider;

@end