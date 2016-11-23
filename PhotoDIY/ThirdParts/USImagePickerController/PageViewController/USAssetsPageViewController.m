//
//  USAssetsPageViewController.m
//  USImagePickerController
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetsPageViewController.h"
#import "USAssetItemViewController.h"

@interface USAssetsPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, CAAnimationDelegate>

@property (nonatomic, copy) NSArray *assets;

@end

@implementation USAssetsPageViewController

- (instancetype)initWithAssets:(NSArray *)assets
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:@{UIPageViewControllerOptionInterPageSpacingKey:@30.f}];
    
    if (self) {
        self.assets          = assets;
        self.dataSource      = self;
        self.delegate        = self;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //添加单双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delaysTouchesBegan = YES;
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    if(self.pageIndex == NSNotFound) self.pageIndex = 0;
}

#pragma mark - 单双击手势触发
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:tap.view];
    
    [self.currentAssetItemViewController.scrollView doubleTapWithPoint:touchPoint];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap
{
    if (_singleTapHandler) {
        _singleTapHandler(self.pageIndex);
        return;
    }
    
    if (self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];//显示导航栏
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];  // 显示状态栏
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];//隐藏导航栏
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];  // 隐藏状态栏
    }
}

#pragma mark - Accessors

- (NSInteger)pageIndex
{
    return [self.assets indexOfObject:self.currentAssetItemViewController.asset];
}

- (CGRect)imageRect
{
    USAssetScrollView *scrollView = self.currentAssetItemViewController.scrollView;
    
    return [scrollView convertRect:scrollView.imageView.frame toView:self.view];
}

- (void)setPageIndex:(NSInteger)pageIndex
{
    NSInteger count = self.assets.count;
    
    if (pageIndex >= 0 && pageIndex < count)
    {
        PHAsset *asset = self.assets[pageIndex];
        
        USAssetItemViewController *page = [USAssetItemViewController viewControllerForAsset:asset];
        page.reloadItemHandler = self.reloadItemHandler;
        
        [self setViewControllers:@[page]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
        
        [self updateTitle:pageIndex];
    }
}

- (USAssetItemViewController *)currentAssetItemViewController
{
    return [self.viewControllers firstObject];
}

#pragma mark - Update title

- (void)updateTitle:(NSInteger)index
{
    self.title      = [NSString stringWithFormat:@"%@ / %@", @(index+1), @(self.assets.count)];
    
    if (_indexChangedHandler) _indexChangedHandler(index);
}

#pragma mark - Page view controller data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    id asset = ((USAssetItemViewController *)viewController).asset;
    NSInteger index = [self.assets indexOfObject:asset];
    
    if (index > 0) {
        PHAsset *beforeAsset = self.assets[(index - 1)];
        USAssetItemViewController *page = [USAssetItemViewController viewControllerForAsset:beforeAsset];
        page.reloadItemHandler = self.reloadItemHandler;
        
        return page;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    id asset = ((USAssetItemViewController *)viewController).asset;
    NSInteger index = [self.assets indexOfObject:asset];
    NSInteger count = self.assets.count;
    
    if (index < count - 1) {
        PHAsset *afterAsset = self.assets[(index + 1)];
        USAssetItemViewController *page = [USAssetItemViewController viewControllerForAsset:afterAsset];
        page.reloadItemHandler = self.reloadItemHandler;
        
        return page;
    }
    
    return nil;
}


#pragma mark - Page view controller delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        USAssetItemViewController *vc = (id)pageViewController.viewControllers[0];
        NSInteger index = [self.assets indexOfObject:vc.asset];
        
        [self updateTitle:index];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)dealloc
{
    _singleTapHandler = nil;
    _indexChangedHandler = nil;
}

@end
