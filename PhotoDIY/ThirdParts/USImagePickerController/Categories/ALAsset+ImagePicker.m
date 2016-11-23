//
//  ALAsset+ImagePicker.m
//  USImagePickerController
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "ALAsset+ImagePicker.h"
#import "USImagePickerController.h"
#import "USImagePickerController+Protect.h"

@implementation ALAsset (ImagePicker)

- (CGSize)dimensions
{
    return self.defaultRepresentation.dimensions;
}

- (NSDate *)modifiedDate
{
    return [self valueForProperty:ALAssetPropertyDate];;
}

- (NSString *)originalFilename
{
    return self.defaultRepresentation.filename;
}

- (NSString *)localIdentifier
{
    return self.defaultRepresentation.url.absoluteString;
}

- (UIImage *)fullScreenImage
{
    UIImage *fullImage = [UIImage imageWithCGImage:self.defaultRepresentation.fullScreenImage];
    if (!fullImage) {
        fullImage = [self thumbnailImageWithMaxPixelSize:USFullScreenImageMaxPixelSize];
    }
    return fullImage;
}

- (UIImage *)aspectRatioThumbnailImage
{
    UIImage *thumbImage = [UIImage imageWithCGImage:self.aspectRatioThumbnail];
    if (!thumbImage && NSClassFromString(@"PHAsset")) {
        CGSize thumbSize = [PHAsset thumbnailAspectRatioSize:self.dimensions];
        thumbImage = [self thumbnailImageWithMaxPixelSize:MAX(thumbSize.width, thumbSize.height)];
    }
    return thumbImage;
}

- (UIImage *)aspectRatioHDImage
{
    return [self thumbnailImageWithMaxPixelSize:USAspectRatioHDImageMaxPixelSize];
}

- (NSData *)originalImageData
{
    NSData *data = nil;
    @autoreleasepool {
        ALAssetRepresentation *representation = self.defaultRepresentation;
        Byte *buffer = (Byte*)malloc((size_t)representation.size);
        
        NSError *error;
        NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:(NSUInteger)representation.size error:&error];
        data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    }
    return data;
}

static size_t GetAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        USPickerLog(@"thumbnail for asset got an error: %@", error);
    }
    return countRead;
}

static void ReleaseAssetCallback(void *info) {
    CFRelease(info);
}

- (UIImage *)thumbnailImageWithMaxPixelSize:(CGFloat)maxPixelSize
{
    UIImage *lastImage = nil;
    
    if (MAX(self.dimensions.width, self.dimensions.height) > maxPixelSize) {
        ALAssetRepresentation *rep = [self defaultRepresentation];
        
        CGDataProviderDirectCallbacks callbacks = {
            .version = 0,
            .getBytePointer = NULL,
            .releaseBytePointer = NULL,
            .getBytesAtPosition = GetAssetBytesCallback,
            .releaseInfo = ReleaseAssetCallback,
        };
        
        CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
        CGImageSourceRef src = CGImageSourceCreateWithDataProvider(provider, NULL);
        
        if (src != NULL) {
            NSDictionary *options =  @{
                                       (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                       (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                       (id) kCGImageSourceThumbnailMaxPixelSize : @(maxPixelSize)
                                       };
            CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, (__bridge CFDictionaryRef)options);
            CFRelease(src);
            
            if (thumbnail) {
                lastImage = [UIImage imageWithCGImage:thumbnail];
                CGImageRelease(thumbnail);
            }
        }
        CFRelease(provider);
    }
    
    if (!lastImage) {
        lastImage = [self fullScreenImage];
    }
    return lastImage;
}

+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier
{
    if (!identifier) return nil;
    
    __block ALAsset *imageAsset = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[USImagePickerController defaultAssetsLibrary] assetForURL:[NSURL URLWithString:identifier]
                                                        resultBlock:^(ALAsset *asset) {
                                                            @autoreleasepool {
                                                                imageAsset = asset;
                                                            }
                                                            
                                                            dispatch_semaphore_signal(sema);
                                                        }
                                                       failureBlock:^(NSError *error) {
                                                           dispatch_semaphore_signal(sema);
                                                       }];
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    return imageAsset;
}

- (void)requestMetadataWithCompletionHandler:(void(^)(NSDictionary *metadata))completionHandler
{
    if (completionHandler) completionHandler(self.defaultRepresentation.metadata);
}

@end
