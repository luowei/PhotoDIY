//
//  USAssetScrollView.m
//  USImagePickerController
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetScrollView.h"

#define USScreenSize (((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))?CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width):[UIScreen mainScreen].bounds.size)

@interface USAssetScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) id asset;
@property (nonatomic, assign) CGSize imageSize;

@end

@implementation USAssetScrollView

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.showsVerticalScrollIndicator   = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom                    = YES;
    self.backgroundColor                = [UIColor clearColor];
    self.decelerationRate               = UIScrollViewDecelerationRateFast;
    self.delegate                       = self;
    
    [self setupViews];
}

#pragma mark - Setup

- (void)setupViews
{
    UIImageView *imageView = [UIImageView new];
    imageView.isAccessibilityElement    = YES;
    imageView.accessibilityTraits       = UIAccessibilityTraitImage;
    [self addSubview:imageView];
    
    _imageView = imageView;
}

- (USTorusIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        USTorusIndicatorView *indicatorView = [[USTorusIndicatorView alloc] init];
        indicatorView.center = self.center;
        UIViewAutoresizing autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        indicatorView.autoresizingMask = autoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:indicatorView];
        
        _indicatorView = indicatorView;
    }
    return _indicatorView;
}

- (void)updateDisplayImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)initWithImage:(UIImage *)image
{
    if (!image || ![image isKindOfClass:[UIImage class]]) return;
    
    self.zoomScale = 1.0;
    
    _imageSize = image.size;
    
    [self initZoomingViewLayout];
    
    [self updateDisplayImage:image];
}

- (CGSize)imageSizeWithDimensions:(CGSize)dimensions maxPixelSize:(CGFloat)maxPixelSize
{
    CGSize imageSize = dimensions;
    if (dimensions.height > dimensions.width && dimensions.height > maxPixelSize) {
        imageSize.width = floorf(dimensions.width / dimensions.height * maxPixelSize);
        imageSize.height = floorf(dimensions.height / dimensions.width * imageSize.width);
    }
    else if (dimensions.height <= dimensions.width && dimensions.width > maxPixelSize) {
        imageSize.height = floorf(dimensions.height / dimensions.width * maxPixelSize);
        imageSize.width = floorf(dimensions.width / dimensions.height * imageSize.height);
    }
    
    return imageSize;
}

- (void)initWithALAsset:(ALAsset *)asset
{
    if (!asset || ![asset isKindOfClass:[ALAsset class]]) return;
    
    self.zoomScale = 1.0;
    
    if ([self.asset isEqual:asset]) {
        [self initZoomingViewLayout];
        
        return;
    }
    
    self.asset = asset;
    
    CGFloat maxPixelSize = MAX(USScreenSize.width, USScreenSize.height);
    
    _imageSize = [self imageSizeWithDimensions:asset.defaultRepresentation.dimensions
                                  maxPixelSize:maxPixelSize * [UIScreen mainScreen].scale];
    [self initZoomingViewLayout];
    
    [self updateDisplayImage:[UIImage imageWithCGImage:asset.aspectRatioThumbnail]];
    
    __weak USAssetScrollView *weak_self = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *fullImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fullImage) {
                [weak_self updateDisplayImage:fullImage];
            }
        });
    });
}

- (void)initWithPHAsset:(PHAsset *)asset
{
    if (!asset || ![asset isKindOfClass:[PHAsset class]]) return;
    
    self.zoomScale = 1.0;
    
    if ([self.asset isEqual:asset]) {
        [self initZoomingViewLayout];
        
        return;
    }
    
    self.asset = asset;
    
    __weak USAssetScrollView *weak_self = self;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    
    CGFloat maxPixelSize = 2400.f;
    
    //适配截屏拼接的图片
    CGFloat maxImgLength = MAX(asset.pixelWidth, asset.pixelHeight);
    CGFloat minImgLength = MIN(asset.pixelWidth, asset.pixelHeight);
    if (minImgLength <= 1080.f && maxImgLength/minImgLength > 2.f) {
        CGFloat minScreenLength = MIN(USScreenSize.width, USScreenSize.height) * [UIScreen mainScreen].scale;
        CGFloat lastImgMaxLength = 9000.f * 1080.f / minImgLength;
        CGFloat lastImgMinLength = minImgLength / maxImgLength * lastImgMaxLength;
        if (lastImgMinLength > minScreenLength) {
            lastImgMaxLength = minScreenLength / lastImgMinLength * lastImgMaxLength;
        }
        maxPixelSize = MAX(maxPixelSize, lastImgMaxLength);
    }
    
    _imageSize = [self imageSizeWithDimensions:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                                  maxPixelSize:maxPixelSize];
    [self initZoomingViewLayout];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:_imageSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                if (result) {
                                                    [weak_self updateDisplayImage:result];
                                                }
                                            }];
}

#pragma mark - 双击手势触发
- (void)doubleTapWithPoint:(CGPoint)point
{
    if (!self.userInteractionEnabled) return;
    
    if (self.zoomScale > 1) {
        [self setZoomScale:1 animated:YES];
    }
    else {
        CGFloat newScale = 2.4;
        CGFloat deviation = 20;
        
        if ((_imageView.frame.size.width+deviation) < USScreenSize.width) {
            newScale = USScreenSize.width/_imageView.frame.size.width;
            newScale -= 0.001; //完全贴合屏幕边缘时滑动切换图片会出现闪屏的现象，所以留一点点距离
        }
        else if (_imageView.frame.size.height+deviation < MIN(USScreenSize.width, USScreenSize.height)) {
            newScale = USScreenSize.height/_imageView.frame.size.height;
        }
        
        [self zoomToRect:[self zoomRectForScale:newScale withCenter:point] animated:YES];
    }
}

- (void)initZoomingViewLayout
{
    _imageView.bounds = [self zoomingViewBoundsForImageSize:_imageSize];
    _imageView.center = CGPointMake(USScreenSize.width/2, USScreenSize.height/2);
    
    [self setMaxAndMinZoomScales];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGFloat height = self.frame.size.height / scale;
    CGFloat width  = self.frame.size.width  / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    
    return CGRectMake(x, y, width, height);
}

- (void)setMaxAndMinZoomScales
{
    CGFloat screen_scale = [UIScreen mainScreen].scale;
    
    CGFloat iscale = _imageSize.width / (USScreenSize.width * screen_scale);
    CGFloat wscale = USScreenSize.width / _imageView.frame.size.width;
    CGFloat hscale = USScreenSize.height / _imageView.frame.size.height;
    
    self.maximumZoomScale = MAX(MAX(MAX(wscale, hscale), iscale), 3.0);
}

- (CGRect)zoomingViewBoundsForImageSize:(CGSize)imageSize
{
    CGSize viewSize = USScreenSize;
    
    CGSize finalSize = CGSizeZero;
    
    if (imageSize.width / imageSize.height < viewSize.width / viewSize.height) {
        finalSize.height = viewSize.height;
        finalSize.width = viewSize.height / imageSize.height * imageSize.width;
    }
    else {
        finalSize.width = viewSize.width;
        finalSize.height = viewSize.width / imageSize.width * imageSize.height;
    }
    return CGRectMake(0, 0, finalSize.width, finalSize.height);
}

#pragma mark UIScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIImageView *zoomView = _imageView;
    
    CGSize boundSize = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;
    
    CGFloat offsetX = (boundSize.width > contentSize.width)? (boundSize.width - contentSize.width)/2 : 0.0;
    CGFloat offsetY = (boundSize.height > contentSize.height)? (boundSize.height - contentSize.height)/2 : 0.0;
    
    zoomView.center = CGPointMake(contentSize.width/2 + offsetX, contentSize.height/2 + offsetY);
}

@end
