//
//  USAssetsPreviewViewController.h
//  USImagePickerController
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAssetsViewController.h"

@protocol USAssetsPreviewViewControllerDelegate;

@interface USAssetsPreviewViewController : UIViewController

@property (nonatomic, assign, readonly) id asset;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) NSMutableSet *selectedAssets;

@property (nonatomic, weak) id <USAssetsPreviewViewControllerDelegate> delegate;

- (instancetype)initWithAssets:(NSArray *)assets;

@end


@protocol USAssetsPreviewViewControllerDelegate <NSObject>

@required

- (void)sendButtonClickedInPreviewViewController:(USAssetsPreviewViewController *)vc;

@optional

- (BOOL)previewViewController:(USAssetsPreviewViewController *)vc canSelect:(BOOL)selected;

- (void)previewViewController:(USAssetsPreviewViewController *)vc didSelect:(BOOL)selected;

@end