//
//  USAssetsPreviewViewController.m
//  USImagePickerController
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

//想要使用代码隐藏状态栏需要在 info.plist 文件里设置 "View controller-based status bar appearance" 为 NO

#import "USAssetsPreviewViewController.h"
#import "USAssetsPageViewController.h"

@interface USAssetsPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *boxContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;
@property (weak, nonatomic) IBOutlet UILabel *boxFillLabel;
@property (weak, nonatomic) IBOutlet UILabel *boxDescLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *boxIndicatorView;

@property (nonatomic, assign) BOOL pageSelected;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) PHImageRequestID requestID;
@property (nonatomic, strong) NSMutableDictionary *lengthMapper;

@end

@implementation USAssetsPreviewViewController


- (instancetype)initWithAssets:(NSArray *)assets
{
    self = [super initWithNibName:@"USAssetsPreviewViewController" bundle:nil];
    if (self) {
        self.lengthMapper    = [NSMutableDictionary dictionary];
        self.dataSource      = [NSMutableArray arrayWithArray:assets];
        self.automaticallyAdjustsScrollViewInsets = NO;
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
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];//隐藏导航栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];  // 隐藏状态栏
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];//显示导航栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];  // 显示状态栏
}

- (USImagePickerController *)picker {
    return (USImagePickerController *)self.navigationController;
}

- (id)asset {
    return [_dataSource objectAtIndex:_pageIndex];
}

- (void)updateTitle:(NSInteger)index
{
    _pageIndex = index;
    
    self.title = [NSString stringWithFormat:@"%@ / %@", @(index+1), @(_dataSource.count)];
    
    _pageSelected = [_selectedAssets containsObject:_dataSource[index]];
    
    [self updateDisplay];
}

- (void)updateDisplay
{
    [self reloadCheckButtonBgColor];
    
    NSInteger count = self.selectedAssets.count;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",count];
    self.countLabel.hidden = count?NO:YES;
    self.sendButton.alpha = count?1:0.5;
    self.sendButton.userInteractionEnabled = count?YES:NO;
    
    if (self.picker.selectedOriginalImage) {
        self.boxFillLabel.hidden = NO;
        self.boxImageView.tintColor = RGBACOLOR(120, 120, 120, 1);
        self.boxDescLabel.textColor = [UIColor whiteColor];
        
        NSNumber *length = _lengthMapper[@(_pageIndex)];
        if (length) {
            NSString *space = [NSByteCountFormatter stringFromByteCount:length.longLongValue countStyle:NSByteCountFormatterCountStyleBinary];
            space = [space stringByReplacingOccurrencesOfString:@" " withString:@""];
            space = [space stringByReplacingOccurrencesOfString:@"B" withString:@""];
            
            self.boxDescLabel.text = [NSString stringWithFormat:@"原图(%@)",space];
            [self.boxIndicatorView stopAnimating];
        } else {
            self.boxDescLabel.text = @"原图";
            [self requestImageDataLength];
        }
    }
    else {
        [self.boxIndicatorView stopAnimating];
        self.boxFillLabel.hidden = YES;
        self.boxImageView.tintColor = RGBACOLOR(70, 70, 70, 1);
        self.boxDescLabel.textColor = self.boxImageView.tintColor;
        self.boxDescLabel.text = @"原图";
    }
}

- (void)handleSingleTap
{
    BOOL hidden = !(self.topBar.hidden && self.bottomBar.hidden);
    
    self.topBar.hidden = hidden;
    self.bottomBar.hidden = hidden;
}

#pragma mark - Setup

- (void)setupViews
{
    USAssetsPageViewController *_pageViewController = [[USAssetsPageViewController alloc] initWithAssets:_dataSource];
    _pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    __weak typeof(self) weak_self = self;
    [_pageViewController setIndexChangedHandler:^(NSInteger index) {
        [weak_self updateTitle:index];
    }];
    [_pageViewController setSingleTapHandler:^(NSInteger index) {
        [weak_self handleSingleTap];
    }];
    _pageViewController.pageIndex = _pageIndex;
    
    [self.view insertSubview:_pageViewController.view atIndex:0];
    [self addChildViewController:_pageViewController];
    
    NSDictionary *views = @{@"view":_pageViewController.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:views]];
    
    self.countLabel.backgroundColor = self.picker.tintColor;
    self.countLabel.layer.cornerRadius = CGRectGetHeight(self.countLabel.frame)/2.f;
    self.countLabel.layer.masksToBounds = YES;
    [self.sendButton setTitleColor:self.picker.tintColor forState:UIControlStateNormal];
    
    self.checkImageView.tintColor = [UIColor whiteColor];
    self.checkImageView.layer.cornerRadius = CGRectGetHeight(self.checkImageView.frame) / 2.0;
    [self.checkImageView setImage:[[UIImage imageNamed:@"USPicker-Checkmark-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self reloadCheckButtonBgColor];
    
    self.boxFillLabel.backgroundColor = self.picker.tintColor;
    self.boxFillLabel.layer.cornerRadius = CGRectGetHeight(self.boxFillLabel.frame)/2.f;
    self.boxFillLabel.layer.masksToBounds = YES;
    [self.boxImageView setImage:[[UIImage imageNamed:@"USPicker-Checkbox"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    if (self.picker.hideOriginalImageCheckbox) {
        self.boxContainerView.hidden = YES;
    }
    
    if (self.picker.returnKey) {
        [self.sendButton setTitle:self.picker.returnKey forState:UIControlStateNormal];
    }
}

- (void)reloadCheckButtonBgColor
{
    self.checkImageView.backgroundColor = _pageSelected ? self.picker.tintColor : [UIColor clearColor];
}

/** 右上角按钮的点击事件 */
- (IBAction)checkButtonAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewViewController:canSelect:)]) {
        if (![self.delegate previewViewController:self canSelect:!_pageSelected]) return;
    }
    
    BOOL selected = !_pageSelected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewViewController:didSelect:)]) {
        [self.delegate previewViewController:self didSelect:selected];
    }
    
    [self updateTitle:_pageIndex];
    
    [self reloadCheckButtonBgColor];
}

/** 原图按钮的点击事件 */
- (IBAction)boxButtonAction:(UIButton *)sender
{
    BOOL allows = !self.picker.selectedOriginalImage;
    
    self.picker.selectedOriginalImage = allows;
    
    if (!_pageSelected && allows) {
        [self checkButtonAction:nil];
    }
    
    [self updateDisplay];
}

- (void)requestImageDataLength
{
    if (PHPhotoLibraryClass) {
        [self.boxIndicatorView startAnimating];
        
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        
        __weak typeof(self) weak_self = self;
        
        // get photo info from this asset
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.networkAccessAllowed = YES;
        imageRequestOptions.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
            USPickerLog(@"download image data from iCloud: %.1f%%", 100*progress);
        };
        self.requestID = [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            [weak_self.lengthMapper setObject:@(imageData.length) forKey:@(weak_self.pageIndex)];
            [weak_self updateDisplay];
        }];
    }
    else {
        [_lengthMapper setObject:@([self.asset defaultRepresentation].size) forKey:@(_pageIndex)];
        [self updateDisplay];
    }
}

/** 返回按钮的点击事件 */
- (IBAction)leftNavButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/** 发送按钮的点击事件 */
- (IBAction)sendButtonAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendButtonClickedInPreviewViewController:)]) {
        [self.delegate sendButtonClickedInPreviewViewController:self];
    }
}

#pragma mark - 监控横竖屏切换

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [UIView animateWithDuration:duration animations:^{
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            _topHeightConstraint.constant = 44;
        } else {
            _topHeightConstraint.constant = 64;
        }
        [self.topBar layoutIfNeeded];
    }];
}

- (void)dealloc
{
    USPickerLog(@"dealloc 释放类 %@",  NSStringFromClass([self class]));
}

@end
