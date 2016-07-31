//
//  PDPhotoLibPicker.h
//  多选相册照片
//
//  Created by luowei on 16/7/5.
//  Copyright (c) 2016 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AssetsLibrary/AssetsLibrary.h>

@protocol PDPhotoPickerProtocol <NSObject>

- (void)collectPhotoFailed;

@optional
- (void)allPhotosCollected:(NSDictionary *)photoDict;

- (void)loadPhoto:(UIImage *)image;

- (void)allURLPicked:(NSArray *)imageURLs;


@end

@interface PDPhotoLibPicker : NSObject {
}

@property(nonatomic, weak) id <PDPhotoPickerProtocol> delegate;

@property(nonatomic) CGSize itemSize;

@property(nonatomic, strong) NSMutableDictionary *photoDict;

@property(nonatomic, strong) ALAssetsLibrary *library;

@property(nonatomic, strong) NSMutableArray *photoURLs;

@property(nonatomic, assign) int assetsCount;


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;


- (instancetype)initWithDelegate:(id <PDPhotoPickerProtocol>)delegate;

- (void)getAllPicturesWithItemSize:(CGSize)itemSize;

- (void)pictureWithURL:(NSURL *)url;

- (void)pictureWithURL:(NSURL *)url size:(CGSize)size;

@end
