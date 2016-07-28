//
//  LWContentView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWContentView.h"
#import "Categorys.h"
#import "LWFilterCollectionView.h"
#import "LWPhotoCollectionView.h"
#import "MBProgressHUD.h"
#import "LWImageCropView.h"
#import "LWFilterImageView.h"
#import "LWDataManager.h"
#import "LWImageView.h"
#import "LWDrawView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation LWContentView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor blackColor];
    self.currentMode = ImageMode;
}

- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [super rotationToInterfaceOrientation:orientation];

    [self hiddenHandBoard];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //隐藏HandBoard
    [self hiddenHandBoard];
}

//初次启动,加载默认图片
- (void)loadDefaultImage {
    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
    [self loadPhoto:inputImage];
}

#pragma mark - PDPhotoPickerProtocol 实现

- (void)collectPhotoFailed {

}

- (void)loadPhoto:(UIImage *)image {
    if (!image) {
        return;
    }
    self.originImage = image;
    self.currentMode = ImageMode;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadImage:image];
    });
    
}


#pragma mark - 其他方法

- (void)showErrorHud {
    self.hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = NSLocalizedString(@"Error", nil);
}


//隐藏HandBoard
- (void)hiddenHandBoard {
    if (!self.filterCollectionView.hidden) {
        self.filterCollectionView.hidden = !self.filterCollectionView.hidden;
    }
    if (!self.photoCollectionView.hidden) {
        self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    }
    NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
    if (result == NSOrderedSame || result == NSOrderedDescending) {
        [self removeConstraint:self.paddingFiltersCollectionV];
        [self removeConstraint:self.paddingPhotosCollectionV];
        [self addConstraint:self.paddingBottomZero];
        [self setNeedsUpdateConstraints];
    }
}

//加载照片选择器
- (void)showPhotos {
    //处理handBoard
    if (!self.filterCollectionView.hidden) {
        self.filterCollectionView.hidden = !self.filterCollectionView.hidden;
    }

    self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    if (!self.photoCollectionView.hidden) {
        NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
        if (result == NSOrderedSame || result == NSOrderedDescending) {
            [self removeConstraint:self.paddingBottomZero];
            [self removeConstraint:self.paddingFiltersCollectionV];
            [self addConstraint:self.paddingPhotosCollectionV];
            [self setNeedsUpdateConstraints];
        }

        [self.photoCollectionView reloadPhotos];

    } else {
        NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
        if (result == NSOrderedSame || result == NSOrderedDescending) {
            [self removeConstraint:self.paddingFiltersCollectionV];
            [self removeConstraint:self.paddingPhotosCollectionV];
            [self addConstraint:self.paddingBottomZero];
            [self setNeedsUpdateConstraints];
        }
    }

    LWDataManager *dm = [LWDataManager sharedInstance];
    self.currentMode = ImageMode;
    [self reloadImage:dm.currentImage];

}


//加载滤镜
- (void)showFilters {

    //处理handBoard
    if (!self.photoCollectionView.hidden) {
        self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    }

    self.filterCollectionView.hidden = !self.filterCollectionView.hidden;
    if (!self.filterCollectionView.hidden) {
        NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
        if (result == NSOrderedSame || result == NSOrderedDescending) {
            [self removeConstraint:self.paddingBottomZero];
            [self removeConstraint:self.paddingPhotosCollectionV];
            [self addConstraint:self.paddingFiltersCollectionV];
            [self setNeedsUpdateConstraints];
        }

        [self.filterCollectionView reloadFilters];
        self.currentMode = FilterMode;
    } else {
        NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
        if (result == NSOrderedSame || result == NSOrderedDescending) {
            [self removeConstraint:self.paddingFiltersCollectionV];
            [self removeConstraint:self.paddingPhotosCollectionV];
            [self addConstraint:self.paddingBottomZero];
            [self setNeedsUpdateConstraints];
        }
        self.currentMode = ImageMode;
    }

    LWDataManager *dm = [LWDataManager sharedInstance];
    [self reloadImage:dm.currentImage];
}

#pragma mark -

- (void)reloadImage:(UIImage *)image {

    LWDataManager *dm = [LWDataManager sharedInstance];
    dm.currentImage = image;

    switch (self.currentMode) {
        case FilterMode: {
            self.imageView.hidden = YES;
            self.filterView.hidden = NO;
            self.cropView.hidden = YES;
            self.drawView.hidden = YES;
            [self.filterView loadImage2GPUImagePicture:image];
            break;
        }
        case CropMode: {
            self.imageView.hidden = YES;
            self.filterView.hidden = YES;
            self.cropView.hidden = NO;
            self.drawView.hidden = YES;
            [self.cropView setImage:image];
            break;
        }
        case DrawMode: {
            self.imageView.hidden = YES;
            self.filterView.hidden = YES;
            self.cropView.hidden = YES;
            self.drawView.hidden = NO;
            [self.drawView setImage:image];
            break;
        }
        case ImageMode:
        default: {
            self.imageView.hidden = NO;
            self.filterView.hidden = YES;
            self.cropView.hidden = YES;
            self.drawView.hidden = YES;
            self.imageView.image = image;
            break;
        }
    }
}


- (void)saveImage {
    LWDataManager *dm = [LWDataManager sharedInstance];

    [self.filterView.filter forceProcessingAtSize:dm.currentImage.size];
    self.hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    [self.filterView.sourcePicture processImageUpToFilter:self.filterView.filter
                                      withCompletionHandler:^(UIImage *processedImage) {
                                          if (!processedImage) {
                                              UIImageWriteToSavedPhotosAlbum(dm.currentImage, self, nil, nil);
                                          } else {
                                              UIImageWriteToSavedPhotosAlbum(processedImage, self, nil, nil);
                                          }
                                          self.hud.mode = MBProgressHUDModeText;
                                          self.hud.labelText = NSLocalizedString(@"Save Success", nil);
                                      }];
    [self.hud hide:YES afterDelay:1.0];
}


- (void)recovery {
    [self reloadImage:self.originImage];

    if (self.filterCollectionView) {
        NSArray *selectedItems = self.filterCollectionView.indexPathsForSelectedItems;
        for (NSIndexPath *path in selectedItems) {
            LWFilterCollectionCell *cell = (LWFilterCollectionCell *) [self.filterCollectionView cellForItemAtIndexPath:path];
            [self.filterCollectionView deselectItemAtIndexPath:path animated:NO];
            cell.selected = NO;
            cell.selectIcon.hidden = YES;
        }
        self.filterCollectionView.selectedIndexPath = nil;
        [self.filterCollectionView reloadItemsAtIndexPaths:selectedItems];
    }
}


- (void)showOrHideCropView {
    [self hiddenHandBoard];
    LWDataManager *dm = [LWDataManager sharedInstance];

    self.cropView.hidden = !self.cropView.hidden;
    self.currentMode = self.cropView.hidden ? ImageMode : CropMode;
    [self reloadImage:dm.currentImage];
}

- (void)cropImageOk {
    LWDataManager *dm = [LWDataManager sharedInstance];
    if (dm.currentImage) {
        CGRect CropRect = self.cropView.cropAreaInImage;
        CGImageRef imageRef = CGImageCreateWithImageInRect([self.cropView.imageView.image CGImage], CropRect);
        UIImage *croppedImg = [UIImage imageWithCGImage:imageRef];

        self.currentMode = ImageMode;
        [self reloadImage:croppedImg];

        CGImageRelease(imageRef);
    } else {
        [self showErrorHud];
    }
}

- (void)cancelCropImage {
    LWDataManager *dm = [LWDataManager sharedInstance];
    self.currentMode = ImageMode;
    [self reloadImage:dm.currentImage];
}

@end
