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


//从一个代理初始化
- (instancetype)initWithDelegate:(id <PDPhotoPickerProtocol>)delegate;

//缩放图片大小
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;


#pragma mark - 获取照片

//获得所有照片按指定大小
- (void)getAllPicturesWithItemSize:(CGSize)itemSize;

//加载所有AssetGroup
- (void)loadAllAssetGroup;

//遍历 AssertGroup
- (void)enumerateAssetGroup:(ALAssetsGroup *)group;

#pragma mark - Load Photos URL

//获得所有照片URL
- (void)getAllPicturesURL;

//加载所有AssetGroup
- (void)loadAllAssetGroupURL;

//遍历出所有的URL
- (void)enumerateAssetGroupURL:(ALAssetsGroup *)group;

#pragma mark - 根据URL获得照片

- (void)pictureWithURL:(NSURL *)url;

- (void)pictureWithURL:(NSURL *)url size:(CGSize)size;

- (void)pictureWithURL:(NSURL *)url size:(CGSize)size imageBlock:(void (^)(UIImage *))block;
@end
