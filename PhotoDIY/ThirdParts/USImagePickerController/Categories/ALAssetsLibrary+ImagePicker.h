//
//  ALAssetsLibrary+ImagePicker.h
//  USImagePickerController
//
//  Created by marujun on 16/8/16.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^ALLibraryCompletionHandler)(ALAsset *asset, NSError *error);

@interface ALAssetsLibrary (ImagePicker)

/** 把图片保存到相册，如果相册不存在则新建一个相册 */
+ (void)writeImage:(UIImage *)image toAlbum:(NSString *)toAlbum completionHandler:(ALLibraryCompletionHandler)completionHandler;

/** 把图片(包含元数据)保存到相册，如果相册不存在则新建一个相册 */
+ (void)writeImage:(UIImage *)image metadata:(NSDictionary *)metadata toAlbum:(NSString *)toAlbum completionHandler:(ALLibraryCompletionHandler)completionHandler;

/** 把A相册中的图片添加到B相册中，如果相册不存在则新建一个相册 */
+ (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)toAlbum completionHandler:(ALLibraryCompletionHandler)completionHandler;

@end
