//
//  USAssetItemViewController.m
//  USImagePickerController
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetItemViewController.h"
#import "USAssetScrollView.h"

@interface USAssetItemViewController ()

@property (nonatomic, assign) BOOL displaying;

@end

@implementation USAssetItemViewController

+ (instancetype)viewControllerForAsset:(id)asset
{
    return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(id)asset
{
    if (self = [super init]) {
        _asset = asset;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_displaying) return;
    
    [self reloadAssetScrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _displaying = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _displaying = NO;
}

#pragma mark - Setup

- (void)setupViews
{
    _scrollView = [[USAssetScrollView alloc] init];
    [self.view addSubview:_scrollView];
    
    _scrollView.frame = self.view.bounds;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //TODO: iOS7系统BUG，所以 UIPageViewController 的所有子view都不能使用 AutoLayout
    //http://stackoverflow.com/questions/17729336/uipageviewcontroller-auto-layout-rotation-issue
//    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
//    NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_scrollView]-0-|" options:0 metrics:nil views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_scrollView]-0-|" options:0 metrics:nil views:views]];
//    [self.view layoutIfNeeded];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)reloadAssetScrollView
{
    if(self.reloadItemHandler) {
        __weak typeof(self) weak_self = self;
        
        self.reloadItemHandler(weak_self.scrollView, weak_self.asset);
        
        return;
    }
    
    if ([_asset isKindOfClass:[ALAsset class]]) {
        [self.scrollView initWithALAsset:_asset];
    }
    else if ([_asset isKindOfClass:[UIImage class]]) {
        [self.scrollView initWithImage:_asset];
    }
    else if ([_asset isKindOfClass:[NSString class]]) {
        //需要从网络下载图片 建议实现reloadItemHandler
    }
    else if ([_asset isKindOfClass:[PHAsset class]]) {
        [self.scrollView initWithPHAsset:_asset];
    }
}

#pragma mark - 监控横竖屏切换

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [UIView animateWithDuration:duration animations:^{
        [self reloadAssetScrollView];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
