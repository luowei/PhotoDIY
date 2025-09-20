//
//  USAssetItemViewController.h
//  USImagePickerController
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAssetScrollView.h"

typedef void (^USAssetsItemReloadHandler)(USAssetScrollView *weak_view, id weak_asset);

@interface USAssetItemViewController : UIViewController

@property (nonatomic, strong, readonly) id asset;

@property (nonatomic, strong, readonly) USAssetScrollView *scrollView;

@property (nonatomic, copy) USAssetsItemReloadHandler reloadItemHandler;

+ (instancetype)viewControllerForAsset:(id)asset;

@end
