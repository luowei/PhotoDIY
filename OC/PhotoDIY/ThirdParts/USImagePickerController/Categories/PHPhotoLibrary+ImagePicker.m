//
//  PHPhotoLibrary+ImagePicker.m
//  USImagePickerController
//
//  Created by marujun on 16/8/16.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "PHPhotoLibrary+ImagePicker.h"

@implementation PHPhotoLibrary (ImagePicker)

+ (void)topLevelUserCollectionWithTitle:(NSString *)title completionHandler:(void(^)(PHAssetCollection *collection, NSError *error))completionHandler
{
    PHAssetCollection *collection = [self existingTopLevelUserCollectionWithTitle:title];
    if (collection) {
        if (completionHandler) completionHandler(collection, nil);
    }
    else {
        //使用输入名称创建一个新的相册
        __block NSString *localIdentifier;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
            
            localIdentifier = [collectonRequest placeholderForCreatedAssetCollection].localIdentifier;
            
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
                    if (completionHandler) completionHandler(nil, error);
                }
                else {
                    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[localIdentifier] options:nil];
                    
                    if (completionHandler) completionHandler([fetchResult firstObject], nil);
                }
            });
        }];
    }
}

+ (PHAssetCollection *)existingTopLevelUserCollectionWithTitle:(NSString *)title;
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"localizedTitle == %@", title];
    
    PHFetchResult *fetchResult = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:options];
    if (fetchResult.count) {
        return fetchResult.firstObject;
    }
    return nil;
}

+ (void)writeImage:(UIImage *)image toAlbum:(NSString *)toAlbum completionHandler:(PHLibraryCompletionHandler)completionHandler
{
    [self writeImageWithObject:image metadata:nil toAlbum:toAlbum completionHandler:completionHandler];
}

+ (void)writeImage:(UIImage *)image metadata:(NSDictionary *)metadata toAlbum:(NSString *)toAlbum completionHandler:(PHLibraryCompletionHandler)completionHandler
{
    //把图片保存到临时路径
    NSString *tempPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    tempPath = [tempPath stringByAppendingFormat:@"/camera_%f.jpg",[[NSDate date] timeIntervalSince1970]];
    
    NSData *dest_data = [self dataWithImage:image metadata:metadata];
    [dest_data writeToFile:tempPath atomically:YES];
    
    [self writeImageWithObject:tempPath metadata:metadata toAlbum:toAlbum completionHandler:^(PHAsset *asset, NSError *error) {
        if (completionHandler) completionHandler(asset, error);
        
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    }];
}

+ (void)writeImageFromFilePath:(NSString *)filePath toAlbum:(NSString *)toAlbum completionHandler:(PHLibraryCompletionHandler)completionHandler
{
    [self writeImageWithObject:filePath metadata:nil toAlbum:toAlbum completionHandler:completionHandler];
}

+ (void)writeImageWithObject:(id)object metadata:(NSDictionary *)metadata toAlbum:(NSString *)toAlbum completionHandler:(PHLibraryCompletionHandler)completionHandler
{
    [self topLevelUserCollectionWithTitle:toAlbum completionHandler:^(PHAssetCollection *collection, NSError *error) {
        if (error) {
            if (completionHandler) completionHandler(nil, error);
            return ;
        }
        
        //把照片写入相册
        __block NSString *localIdentifier;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //请求创建一个Asset
            PHAssetChangeRequest *assetRequest = nil;
            if ([object isKindOfClass:[UIImage class]]) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:object];
            }
            else if ([object isKindOfClass:[NSString class]]) {
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:object]];
            }
            
            if (!metadata) {
                assetRequest.creationDate = [NSDate date];
            }
            
            //不提供AssetCollection则默认放到CameraRoll中
            if(collection){
                //请求编辑相册
                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                //为Asset创建一个占位符，放到相册编辑请求中
                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                //相册中添加照片
                [collectonRequest addAssets:@[placeHolder]];
            }
            
            localIdentifier = [[assetRequest placeholderForCreatedAsset] localIdentifier];
            
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
                    if (completionHandler) completionHandler(nil, error);
                }
                else {
                    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
                    
                    if (completionHandler) completionHandler([fetchResult firstObject], nil);
                }
            });
        }];
    }];
}

+ (NSMutableData *)dataWithImage:(UIImage *)image metadata:(NSDictionary *)metadata
{
    NSData *jpgData = UIImageJPEGRepresentation(image, 1.0);
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)jpgData, NULL);
    CFStringRef UTI = CGImageSourceGetType(source);
    
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data, UTI, 1, NULL);
    
    if(!destination) {
        dest_data = [jpgData mutableCopy];
    }
    else {
        CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef) metadata);
        BOOL success = CGImageDestinationFinalize(destination);
        if(!success) {
            dest_data = [jpgData mutableCopy];
        }
    }
    
    if(destination) {
        CFRelease(destination);
    }
    CFRelease(source);
    
    return dest_data;
}

@end
