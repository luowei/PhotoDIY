//
//  PDPhotoLibPicker.m
//  多选相册照片
//
//  Created by luowei on 16/7/5.
//  Copyright (c) 2016 wodedata. All rights reserved.
//

#import "PDPhotoLibPicker.h"


@implementation PDPhotoLibPicker {
}

- (instancetype)initWithDelegate:(id <PDPhotoPickerProtocol>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;

        self.assetsCount = 0;
        self.photoDict = @{}.mutableCopy;
        self.photoURLs = @[].mutableCopy;
        self.library = [[ALAssetsLibrary alloc] init];
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

- (void)getAllPicturesWithItemSize:(CGSize)itemSize {
    self.itemSize = itemSize;
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];

    typedef enum {
        completed = 0,
        running = 1
    } ThreadState;

    //NSConditionLock *condition = [[NSConditionLock alloc] initWithCondition:running];

    __weak typeof(self) weakSelf = self;

    __block int count = 0;
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            [assetGroups addObject:group];
            count = count + (int) (group.numberOfAssets);
        } else {
            NSLog(@"========groups count:%lu", (unsigned long) assetGroups.count);

            //如果数量发生变化
            if (count != self.assetsCount) {
                [self loadAllAssetGroup];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    if ([weakSelf.delegate respondsToSelector:@selector(allPhotosCollected:)]) {
                        [weakSelf.delegate allPhotosCollected:weakSelf.photoDict];
                    }
                });
            }
        }

    }                         failureBlock:^(NSError *error) {
        NSLog(@"getAllPictures There is an error");
        dispatch_async(dispatch_get_main_queue(), ^() {
            if ([weakSelf.delegate respondsToSelector:@selector(collectPhotoFailed)]) {
                [weakSelf.delegate collectPhotoFailed];
            }
        });
    }];

}

//加载所有AssetGroup
- (void)loadAllAssetGroup {
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];

    __weak typeof(self) weakSelf = self;
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            [weakSelf enumerateAssetGroup:group];
            [assetGroups addObject:group];
            self.assetsCount = self.assetsCount + (int) (group.numberOfAssets);
        } else {
            NSLog(@"========groups count:%lu", (unsigned long) assetGroups.count);
            dispatch_async(dispatch_get_main_queue(), ^() {
                if ([weakSelf.delegate respondsToSelector:@selector(allPhotosCollected:)]) {
                    [weakSelf.delegate allPhotosCollected:weakSelf.photoDict];
                }
            });
        }

    }                         failureBlock:^(NSError *error) {
        NSLog(@"loadAllAssetGroup There is an error");
    }];
}

//遍历 AssertGroup
- (void)enumerateAssetGroup:(ALAssetsGroup *)group {

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __weak typeof(self) weakSelf = self;
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *inStop) {
        if (result == nil || ![[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            return;
        }
        NSURL *url = (NSURL *) [[result defaultRepresentation] url];
        [weakSelf.photoURLs addObject:url];

        //使用信号量解决 assetForURL 同步问题
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf.library assetForURL:url resultBlock:^(ALAsset *asset) {
                        @autoreleasepool {
                            CGImageRef cgImage = [[asset defaultRepresentation] fullScreenImage];
                            if (cgImage) {
                                UIImage *image = [PDPhotoLibPicker imageWithImage:[UIImage imageWithCGImage:cgImage]
                                                                     scaledToSize:weakSelf.itemSize];
//                                dispatch_async(dispatch_get_main_queue(), ^() {
                                weakSelf.photoDict[url.absoluteString] = image;
//                                });
                            }
                        }
                        dispatch_semaphore_signal(sema);
                    }
                             failureBlock:^(NSError *error) {
                                 dispatch_semaphore_signal(sema);
                                 NSLog(@"operation was not successfull!");
                             }];
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }];

}

- (void)pictureWithURL:(NSURL *)url {
    if (!url) {
        return;
    }
    __weak typeof(self) weakSelf = self;

    //使用信号量解决 assetForURL 同步问题
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
            CGImageRef cgImage = [[asset defaultRepresentation] fullScreenImage];
            if (cgImage) {
                UIImage *image = [UIImage imageWithCGImage:cgImage];
                if ([weakSelf.delegate respondsToSelector:@selector(loadPhoto:)]) {
                    [weakSelf.delegate loadPhoto:image];
                }
            }
            dispatch_semaphore_signal(sema);
        }            failureBlock:^(NSError *error) {
            NSLog(@"operation was not successfull!");
            dispatch_semaphore_signal(sema);
        }];
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

- (void)pictureWithURL:(NSURL *)url size:(CGSize)size {
    if (!url) {
        return;
    }
    __weak typeof(self) weakSelf = self;

    //使用信号量解决 assetForURL 同步问题
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
            CGImageRef cgImage = [[asset defaultRepresentation] fullScreenImage];
            if (cgImage) {
                UIImage *image = [PDPhotoLibPicker imageWithImage:[UIImage imageWithCGImage:cgImage]
                                                     scaledToSize:size];

                //在主线程执行delegate的调用
                if ([weakSelf.delegate respondsToSelector:@selector(loadPhoto:)]) {
                    [weakSelf.delegate loadPhoto:image];
                }
            }
            dispatch_semaphore_signal(sema);
        }            failureBlock:^(NSError *error) {
            NSLog(@"operation was not successfull!");
            dispatch_semaphore_signal(sema);
        }];
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

@end
