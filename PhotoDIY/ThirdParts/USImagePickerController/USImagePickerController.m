//
//  USImagePickerController.m
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USImagePickerController.h"
#import "USImagePickerController+Protect.h"
#import "USAssetGroupViewController.h"

@interface USImagePickerController ()

@property (nonatomic, strong, readonly) ALAssetsFilter *assetsFilter;

@end

@implementation USImagePickerController
@synthesize delegate;

- (instancetype)init
{
    USAssetGroupViewController *groupViewController = [[USAssetGroupViewController alloc] initWithNibName:@"USAssetGroupViewController" bundle:nil];
    if (self = [super initWithRootViewController:groupViewController]) {
        if (!PHPhotoLibraryClass) {
            _assetsFilter = [ALAssetsFilter allAssets];
        }
        _cropMaskAspectRatio = 1.f;
        _tintColor = RGBACOLOR(26,178,10,1); //模仿微信的绿色
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setSelectedOriginalImage:(BOOL)selectedOriginalImage
{
    _selectedOriginalImage = selectedOriginalImage;
}

#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static id library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void)dealloc
{
    USPickerLog(@"dealloc 释放类 %@",  NSStringFromClass([self class]));
}

@end
