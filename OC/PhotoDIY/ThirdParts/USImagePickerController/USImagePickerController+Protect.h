//
//  USImagePickerController+Protect.h
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USImagePickerController.h"
#import "USImagePickerController+Macro.h"

#define USFullScreenImageMaxPixelSize       2400.f
#define USAspectRatioHDImageMaxPixelSize    4000.f

NS_ASSUME_NONNULL_BEGIN

@interface USImagePickerController (USImagePickerControllerProtectedMethods)

@property (nonatomic, strong, readonly) ALAssetsFilter *assetsFilter;

- (void)setSelectedOriginalImage:(BOOL)allowsOriginalImage;

/**
 *  返回单例对象ALAssetsLibrary
 */
+ (ALAssetsLibrary *)defaultAssetsLibrary NS_DEPRECATED_IOS(4_0, 8_0, "Use PHImageManager instead");

@end


@interface ALAsset (USImagePickerControllerProtectedMethods)

@end

@interface PHAsset (USImagePickerControllerProtectedMethods)

/**
 *  通过照片的实际尺寸获取原比例缩略图的尺寸
 */
+ (CGSize)thumbnailAspectRatioSize:(CGSize)dimensions;

/**
 *  "project target"设置的是"iPhone mode"，但是在iPad设备上使用的情况下：iPadAir,iPadAir2,iPadPro，iPadMini 无法获取缩略图
 *  在iOS 9.3以上系统获取图片时设置短边大于500可以解决这个问题，但是9.3以下的系统只能通过使用ALAsset来解决
 */
+ (BOOL)targetSizeNeedsSupportiPad;

/*
 * fix on iPads in iPhone mode for iOS 9.3+ targetSize don't work if the dimensions on targetSize are less than about 500.
 * https://github.com/chiunam/CTAssetsPickerController/issues/217
 */
+ (CGSize)targetSizeByCompatibleiPad:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
