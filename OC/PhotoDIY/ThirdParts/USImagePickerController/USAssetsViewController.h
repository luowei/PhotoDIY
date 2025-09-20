//
//  USAssetsViewController.h
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAssetGroupViewController.h"

@interface USAssetsViewController : UIViewController

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) NSMutableSet *selectedAssets;

@end
