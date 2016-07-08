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
#import "MBProgressHUD.h"
#import "LWImageCropView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation PDDrawView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor blackColor];
    self.gpuImageView.backgroundColor = [UIColor blackColor];
    self.gpuImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [super rotationToInterfaceOrientation:orientation];

    [self hiddenHandBoard];
    [self reloadGPUImagePicture];
}

- (void)reloadGPUImagePicture{
    if (!self.currentImage) {
        return;
    }
    self.gpuImageView.contentMode = UIViewContentModeScaleAspectFill;

    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:self.currentImage smoothlyScaleOutput:YES];
    [self.sourcePicture forceProcessingAtSize:self.currentImage.size];
    [self.sourcePicture addTarget:self.gpuImageView];
    [self.sourcePicture processImage];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //隐藏HandBoard
    [self hiddenHandBoard];
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
    if(result == NSOrderedSame || result == NSOrderedDescending){
        [self removeConstraint:self.gpuImgPaddingFiltersCollectionV];
        [self removeConstraint:self.gpuImgPaddingPhotosCollectionV];
        [self addConstraint:self.gpuImgPaddingBottomZero];
        [self setNeedsUpdateConstraints];
    }
}


//加载默认图片
- (void)loadDefaultImage {
    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
    [self loadPhoto:inputImage];
    //[self renderWithFilter:[GPUImageLookupFilter new]];
}

//加载照片选择器
- (void)showPhotos {
    //隐藏cropView
    if (!self.cropView.hidden) {
        self.cropView.hidden = !self.cropView.hidden;
    }
    self.gpuImageView.hidden = NO;

    if (!self.filterCollectionView.hidden) {
        self.filterCollectionView.hidden = !self.filterCollectionView.hidden;
    }

    self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    if (!self.photoCollectionView.hidden) {
        NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
        if(result == NSOrderedSame || result == NSOrderedDescending){
            [self removeConstraint:self.gpuImgPaddingBottomZero];
            [self removeConstraint:self.gpuImgPaddingFiltersCollectionV];
            [self addConstraint:self.gpuImgPaddingPhotosCollectionV];
            [self setNeedsUpdateConstraints];
        }

        [self.photoCollectionView reloadPhotos];

    } else {
        NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
        if(result == NSOrderedSame || result == NSOrderedDescending){
            [self removeConstraint:self.gpuImgPaddingFiltersCollectionV];
            [self removeConstraint:self.gpuImgPaddingPhotosCollectionV];
            [self addConstraint:self.gpuImgPaddingBottomZero];
            [self setNeedsUpdateConstraints];
        }
    }

}

//加载滤镜
- (void)showFilters {
    //隐藏cropView
    if (!self.cropView.hidden) {
        self.cropView.hidden = !self.cropView.hidden;
    }
    self.gpuImageView.hidden = NO;

    if (!self.photoCollectionView.hidden) {
        self.photoCollectionView.hidden = !self.photoCollectionView.hidden;
    }

    self.filterCollectionView.hidden = !self.filterCollectionView.hidden;
    if (!self.filterCollectionView.hidden) {
        NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
        if(result == NSOrderedSame || result == NSOrderedDescending){
            [self removeConstraint:self.gpuImgPaddingBottomZero];
            [self removeConstraint:self.gpuImgPaddingPhotosCollectionV];
            [self addConstraint:self.gpuImgPaddingFiltersCollectionV];
            [self setNeedsUpdateConstraints];
        }

        [self.filterCollectionView reloadFilters];
    } else {
        NSComparisonResult result = [[UIDevice currentDevice].systemVersion compare:@"8.0"];
        if(result == NSOrderedSame || result == NSOrderedDescending){
            [self removeConstraint:self.gpuImgPaddingFiltersCollectionV];
            [self removeConstraint:self.gpuImgPaddingPhotosCollectionV];
            [self addConstraint:self.gpuImgPaddingBottomZero];
            [self setNeedsUpdateConstraints];
        }
    }
}


#pragma mark - PDPhotoPickerProtocol 实现

- (void)collectPhotoFailed {

}

- (void)loadPhoto:(UIImage *)image {
    if (!image) {
        return;
    }
    self.originImage = image;
    [self loadImage2GPUImagePicture:image];
}

//load 照片到 GPUImagePicture
- (void)loadImage2GPUImagePicture:(UIImage *)image {
    if (!image) {
        return;
    }

    self.currentImage = image;
    self.gpuImageView.contentMode = UIViewContentModeScaleAspectFill;

    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    [self.sourcePicture forceProcessingAtSize:image.size];
    [self.sourcePicture addTarget:self.gpuImageView];
    [self.sourcePicture processImage];
}

- (void)renderWithFilter:(GPUImageOutput <GPUImageInput> *)filter {
    self.filter = filter;
    [self.filter forceProcessingAtSize:self.currentImage.size];
    [self.sourcePicture removeAllTargets];
    [self.filter removeAllTargets];

    [self.sourcePicture addTarget:self.filter];
    [self.filter addTarget:self.gpuImageView];

    [self.filter useNextFrameForImageCapture];
    [self.sourcePicture processImage];

    self.currentImage = [self.filter imageFromCurrentFramebuffer];
}

- (void)saveImage {
    [self.filter forceProcessingAtSize:self.currentImage.size];
    self.hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    [self.sourcePicture processImageUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage) {
        if (!processedImage) {
            UIImageWriteToSavedPhotosAlbum(self.currentImage, self, nil, nil);
        } else {
            UIImageWriteToSavedPhotosAlbum(processedImage, self, nil, nil);
        }
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = NSLocalizedString(@"Save Success", nil);
    }];
    [self.hud hide:YES afterDelay:1.0];
}

- (void)rotateWithRotateMode:(GPUImageRotationMode)rotateMode {
    UIImage *image = self.currentImage;
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
    [self loadImage2GPUImagePicture:image];

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

- (void)recovery {
    [self loadImage2GPUImagePicture:self.originImage];
    if(self.filterCollectionView){
        NSArray *selectedItems = self.filterCollectionView.indexPathsForSelectedItems;
        for(NSIndexPath *path in selectedItems){
            LWFilterCollectionCell *cell = (LWFilterCollectionCell *)[self.filterCollectionView cellForItemAtIndexPath:path];
            [self.filterCollectionView deselectItemAtIndexPath:path animated:NO];
            cell.selected = NO;
            cell.selectIcon.hidden = YES;
        }
        self.filterCollectionView.selectedIndexPath = nil;
        [self.filterCollectionView reloadItemsAtIndexPaths:selectedItems];
    }
}

- (void)showErrorHud {
    self.hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = NSLocalizedString(@"Error", nil);
}

- (void)showOrHideCropView {
    [self hiddenHandBoard];

    if (!self.currentImage) {
        [self showErrorHud];
    } else {
        [self.cropView setImage:self.currentImage];
        self.cropView.hidden = !self.cropView.hidden;
        self.gpuImageView.hidden = !self.cropView.hidden;
    }
}

- (void)cropImageOk {
    if (self.currentImage) {
        CGRect CropRect = self.cropView.cropAreaInImage;
        CGImageRef imageRef = CGImageCreateWithImageInRect([self.cropView.imageView.image CGImage], CropRect);
        UIImage *croppedImg = [UIImage imageWithCGImage:imageRef];

        [self loadImage2GPUImagePicture:croppedImg];
        [self showOrHideCropView];

        CGImageRelease(imageRef);
    } else {
        [self showErrorHud];
    }
}

- (void)cancelCropImage {
    [self showOrHideCropView];
}

@end
