//
//  ALAssetsLibrary+ImagePicker.m
//  USImagePickerController
//
//  Created by marujun on 16/8/16.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "ALAssetsLibrary+ImagePicker.h"
#import "USImagePickerController+Protect.h"

@implementation ALAssetsLibrary (ImagePicker)

+ (void)writeImage:(UIImage *)image toAlbum:(NSString *)toAlbum completionHandler:(ALLibraryCompletionHandler)completionHandler
{
    ALAssetsLibrary *library = [USImagePickerController defaultAssetsLibrary];
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL* assetURL, NSError* error) {
        if (error!=nil) {
            if(completionHandler) {
                completionHandler(nil, error);
            }
            
            return;
        }
        
        [self addAssetURL:assetURL toAlbum:toAlbum completionHandler:completionHandler];
    }];
}

+ (void)writeImage:(UIImage *)image metadata:(NSDictionary *)metadata toAlbum:(NSString *)toAlbum completionHandler:(ALLibraryCompletionHandler)completionHandler
{
    ALAssetsLibrary *library = [USImagePickerController defaultAssetsLibrary];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:metadata completionBlock:^(NSURL* assetURL, NSError* error) {
        if (error!=nil) {
            if(completionHandler) {
                completionHandler(nil, error);
            }
            
            return;
        }
        
        [self addAssetURL:assetURL toAlbum:toAlbum completionHandler:completionHandler];
    }];
}

+ (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)toAlbum completionHandler:(ALLibraryCompletionHandler)completionHandler
{
    __block BOOL albumWasFound = NO;
    
    ALAssetsLibrary *library = [USImagePickerController defaultAssetsLibrary];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               if ([toAlbum compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                   
                                   albumWasFound = YES;
                                   [library assetForURL:assetURL
                                            resultBlock:^(ALAsset *asset) {
                                                [group addAsset:asset];
                                                
                                                if(completionHandler) completionHandler(asset, nil);
                                                
                                            } failureBlock:^(NSError *error) {
                                                if(completionHandler) completionHandler(nil, error);
                                            }];
                                   
                                   return;
                               }
                               
                               if (group==nil && albumWasFound==NO) {
                                   
                                   __weak typeof(library) wlibrary = library;
                                   
                                   [library addAssetsGroupAlbumWithName:toAlbum
                                                            resultBlock:^(ALAssetsGroup *group) {
                                                                [wlibrary assetForURL: assetURL
                                                                          resultBlock:^(ALAsset *asset) {
                                                                              [group addAsset: asset];
                                                                              
                                                                              if(completionHandler) completionHandler(asset, nil);
                                                                              
                                                                          } failureBlock:^(NSError *error) {
                                                                              if(completionHandler) completionHandler(nil, error);
                                                                          }];
                                                            }
                                                           failureBlock:^(NSError *error) {
                                                               if(completionHandler) completionHandler(nil, error);
                                                           }];
                                   return;
                               }
                               
                           } failureBlock:^(NSError *error) {
                               if(completionHandler) completionHandler(nil, error);
                           }];
}

@end
