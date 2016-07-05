//
//  PDPhotoLibPicker.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "PDPhotoLibPicker.h"

static int count = 0;
static int idx = 0;

@implementation PDPhotoLibPicker


- (instancetype)initWithDelegate:(id <PDPhotoPickerProtocol>)delegate itemSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.itemSize = size;
        [self getAllPictures];
    }

    return self;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {

    float heightToWidthRatio = image.size.height / image.size.width;
    float scaleFactor = 1;
    if (heightToWidthRatio > 0) {
        scaleFactor = newSize.height / image.size.height;
    } else {
        scaleFactor = newSize.width / image.size.width;
    }

    CGSize newSize2 = newSize;
    newSize2.width = image.size.width * scaleFactor;
    newSize2.height = image.size.height * scaleFactor;

    UIGraphicsBeginImageContext(newSize2);
    [image drawInRect:CGRectMake(0, 0, newSize2.width, newSize2.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (void)getAllPictures {
    photoDict = @{}.mutableCopy;
    NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
    library = [[ALAssetsLibrary alloc] init];
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];

    __weak typeof(self) weakSelf = self;
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            return;
        }

        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *inStop) {
            if (result == nil || ![[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                return;
            }
            [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];

            NSURL *url = (NSURL *) [[result defaultRepresentation] url];
            [photoURLs addObject:url];

//            [library assetForURL:url resultBlock:^(ALAsset *asset) {
//                        @autoreleasepool {
//                            CGImageRef cgImage = [[asset defaultRepresentation] fullScreenImage];
//                            if (cgImage) {
//                                UIImage *image = [PDPhotoLibPicker imageWithImage:[UIImage imageWithCGImage:cgImage]
//                                                                     scaledToSize:weakSelf.itemSize];
//                                photoDict[url.absoluteString] = image;
//                            }
//                        }
//                    }
//                    failureBlock:^(NSError *error) {
//                        NSLog(@"operation was not successfull!");
//                    }];

        }];
        [assetGroups addObject:group];
        count = [group numberOfAssets];

    }                    failureBlock:^(NSError *error) {
        NSLog(@"There is an error");
    }];

    [photoURLs enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        [library assetForURL:url resultBlock:^(ALAsset *asset) {
                    @autoreleasepool {
                        CGImageRef cgImage = [[asset defaultRepresentation] fullScreenImage];
                        if (cgImage) {
                            UIImage *image = [PDPhotoLibPicker imageWithImage:[UIImage imageWithCGImage:cgImage]
                                                                 scaledToSize:weakSelf.itemSize];
                            photoDict[url.absoluteString] = image;
                        }
                    }
                }
                failureBlock:^(NSError *error) {
                    NSLog(@"operation was not successfull!");
                }];
    }];

    //最多加载200张图片
    if ([self.delegate respondsToSelector:@selector(allPhotosCollected:)]) {
        [self.delegate allPhotosCollected:photoDict];
    }
}

- (void)pictureWithURL:(NSURL *)url {
    __weak typeof(self) weakSelf = self;
    [library assetForURL:url resultBlock:^(ALAsset *asset) {
                CGImageRef cgImage = [[asset defaultRepresentation] fullScreenImage];
                if (cgImage) {
                    UIImage *image = [UIImage imageWithCGImage:cgImage];

                    if ([self.delegate respondsToSelector:@selector(getPhoto:)]) {
                        [self.delegate loadPhoto:image];
                    }
                }
            }
            failureBlock:^(NSError *error) {
                NSLog(@"operation was not successfull!");
            }];
}


@end
