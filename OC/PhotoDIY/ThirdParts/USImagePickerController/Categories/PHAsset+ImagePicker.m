//
//  PHAsset+ImagePicker.m
//  USImagePickerController
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "PHAsset+ImagePicker.h"
#import "USImagePickerController+Protect.h"
#import "USImagePickerController+Macro.h"

@implementation PHAsset (ImagePicker)

- (CGSize)dimensions
{
    return CGSizeMake(self.pixelWidth, self.pixelHeight);
}

- (NSDate *)modifiedDate
{
    return [self creationDate];
}

- (NSString *)originalFilename
{
    NSString *fname = nil;
    
    if (NSClassFromString(@"PHAssetResource")) {
        NSArray *resources = [PHAssetResource assetResourcesForAsset:self];
        fname = [(PHAssetResource *)[resources firstObject] originalFilename];
    }
    
    if (!fname) {
        fname = [self valueForKey:@"filename"];
    }
    return fname;
}

- (UIImage *)fullScreenImage
{
    return [self thumbnailImageWithMaxPixelSize:USFullScreenImageMaxPixelSize];
}

- (UIImage *)aspectRatioThumbnailImage
{
    CGSize imageSize = [[self class] thumbnailAspectRatioSize:CGSizeMake(self.pixelWidth, self.pixelHeight)];
    
    return [self imageAspectFitWithSize:imageSize];
}

- (UIImage *)aspectRatioHDImage
{
    return [self thumbnailImageWithMaxPixelSize:USAspectRatioHDImageMaxPixelSize];
}

- (NSData *)originalImageData
{
    __block NSData *data;
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = YES;
    
    imageRequestOptions.networkAccessAllowed = YES;
    imageRequestOptions.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        USPickerLog(@"download image data from iCloud: %.1f%%", 100*progress);
    };
    
    [[PHImageManager defaultManager] requestImageDataForAsset:self
                                                      options:imageRequestOptions
                                                resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                                                    @autoreleasepool {
                                                        data = imageData;
                                                    }
                                                }];
    return data;
}

- (UIImage *)thumbnailImageWithMaxPixelSize:(CGFloat)maxPixelSize
{
    UIImage *image;
    if (self.dimensions.height > self.dimensions.width) {
        if (self.dimensions.height > maxPixelSize) {
            image = [self imageAspectFitWithSize:CGSizeMake(self.dimensions.width / self.dimensions.height * maxPixelSize, maxPixelSize)];
        } else {
            image = [UIImage imageWithData:[self originalImageData]];
            
            if(!image) image = [self imageAspectFitWithSize:self.dimensions];
        }
    }
    else {
        if (self.dimensions.width > maxPixelSize) {
            image = [self imageAspectFitWithSize:CGSizeMake(maxPixelSize, self.dimensions.height / self.dimensions.width * maxPixelSize)];
        } else {
            image = [UIImage imageWithData:[self originalImageData]];
            
            if(!image) image = [self imageAspectFitWithSize:self.dimensions];
        }
    }
    
    return image;
}

- (UIImage *)imageAspectFitWithSize:(CGSize)size
{
    __block UIImage *image = nil;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous  = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        USPickerLog(@"download image data from iCloud: %.1f%%", 100*progress);
    };
    
    [[PHImageManager defaultManager] requestImageForAsset:self
                                               targetSize:[[self class] targetSizeByCompatibleiPad:size]
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                @autoreleasepool {
                                                    image = result;
                                                }
                                            }];
    return image;
}

+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier
{
    if (!identifier) return nil;
    
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
}

- (void)requestMetadataWithCompletionHandler:(void(^)(NSDictionary *metadata))completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc]init];
        editOptions.networkAccessAllowed = YES;
        
        [self requestContentEditingInputWithOptions:editOptions completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            CIImage *image = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(image.properties);
            });
        }];
    });
}

+ (CGSize)thumbnailAspectRatioSize:(CGSize)dimensions
{
    CGFloat minPixelSize = 256.f;
    CGFloat maxPixelSize = 1280.f;
    
    CGSize imageSize = CGSizeZero;
    
    if (dimensions.height > dimensions.width) {
        if (dimensions.height / dimensions.width > maxPixelSize / minPixelSize) {
            imageSize = CGSizeMake(floorf(maxPixelSize * dimensions.width / dimensions.height), maxPixelSize);
        } else {
            imageSize = CGSizeMake(minPixelSize, ceilf(minPixelSize * dimensions.height / dimensions.width));
        }
    } else {
        if (dimensions.width / dimensions.height > maxPixelSize / minPixelSize) {
            imageSize = CGSizeMake(maxPixelSize, floorf(maxPixelSize * dimensions.height / dimensions.width));
        } else {
            imageSize = CGSizeMake(ceilf(minPixelSize * dimensions.width / dimensions.height), minPixelSize);
        }
    }
    return imageSize;
}

+ (BOOL)targetSizeNeedsSupportiPad
{
    return [[UIDevice currentDevice].model hasPrefix:@"iPad"] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad == NO;
}

+ (CGSize)targetSizeByCompatibleiPad:(CGSize)targetSize
{
    if ([self targetSizeNeedsSupportiPad]) {
        CGFloat minPixelSize = 500;
        
        if (MAX(targetSize.width, targetSize.height) <= 0) return targetSize;
        if (MIN(targetSize.width, targetSize.height) >= minPixelSize) return targetSize;
        
        CGFloat width, height;
        if (targetSize.width < targetSize.height) {
            width = minPixelSize;
            height = targetSize.height / targetSize.width * width;
        }
        else {
            height = minPixelSize;
            width = targetSize.width / targetSize.height * height;
        }
        return CGSizeMake(width, height);
    }
    return targetSize;
}

@end
