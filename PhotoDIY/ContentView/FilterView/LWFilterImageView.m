//
//  LWFilterImageView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/27.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWFilterImageView.h"
#import "Categorys.h"
#import "LWDataManager.h"
#import "LWContentView.h"

@implementation LWFilterImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
    self.contentMode = UIViewContentModeScaleAspectFill;

    self.filterType = Default;
    [self.slider setThumbImage:[UIImage imageNamed:@"slider_circel"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"slider_circel_highlight"] forState:UIControlStateHighlighted];
}

- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [super rotationToInterfaceOrientation:orientation];
    [self reloadGPUImagePicture];
}

- (void)reloadGPUImagePicture {
    LWDataManager *dm = [LWDataManager sharedInstance];
    if (!dm.currentImage) {
        return;
    }
    self.contentMode = UIViewContentModeScaleAspectFill;

    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:dm.currentImage smoothlyScaleOutput:YES];
    [self.sourcePicture forceProcessingAtSize:dm.currentImage.size];
    [self.sourcePicture addTarget:self];
    [self.sourcePicture processImage];
}

//load 照片到 GPUImagePicture
- (void)loadImage2GPUImagePicture:(UIImage *)image {
    if (!image) {
        return;
    }
    self.contentMode = UIViewContentModeScaleAspectFill;

    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    [self.sourcePicture forceProcessingAtSize:image.size];
    [self.sourcePicture addTarget:self];
    [self.sourcePicture processImage];
}

- (void)renderWithFilter:(GPUImageOutput <GPUImageInput> *)filter {
    LWDataManager *dm = [LWDataManager sharedInstance];

    self.filter = filter;
    [self.filter forceProcessingAtSize:dm.currentImage.size];
    [self.sourcePicture removeAllTargets];
    [self.filter removeAllTargets];

    [self.sourcePicture addTarget:self.filter];
    [self.filter addTarget:self];

    [self.filter useNextFrameForImageCapture];
    [self.sourcePicture processImage];

    UIImage *image = [self.filter imageFromCurrentFramebuffer];

    //重新加载图片
    LWContentView *contentView = [self superViewWithClass:[LWContentView class]];
    [contentView reloadImage:image];
}

- (void)renderWithFilterKey:(NSString *)key {
    self.filterType = [self fileTypeWithKey:key];
    NSDictionary *filters = [[LWDataManager sharedInstance] filters];
    self.currentFilter = filters[key];
    [self renderWithFilter:self.currentFilter];
    [self setupSlider];
}

- (enum FilterType)fileTypeWithKey:(NSString *)key {
    if([@"Contrast" isEqualToString:key] || [@"对比度调节" isEqualToString:key]){
        return Contrast;
    }
    if([@"Levels" isEqualToString:key] || [@"色阶调节" isEqualToString:key]){
        return Levels;
    }
    if([@"RGB" isEqualToString:key] || [@"RGB调节" isEqualToString:key]){
        return RGB;
    }
    if([@"HUE" isEqualToString:key] || [@"HUE调节" isEqualToString:key]){
        return HUE;
    }
    if([@"WhiteBalance" isEqualToString:key] || [@"白平衡" isEqualToString:key]){
        return WhiteBalance;
    }
    if([@"Sharpen" isEqualToString:key] || [@"锐化" isEqualToString:key]){
        return Sharpen;
    }
    if([@"Gamma" isEqualToString:key] || [@"Gamma" isEqualToString:key]){
        return Gamma;
    }
    if([@"ToneCurve" isEqualToString:key] || [@"色调美化" isEqualToString:key]){
        return ToneCurve;
    }
    if([@"SepiaTone" isEqualToString:key] || [@"褐色调" isEqualToString:key]){
        return SepiaTone;
    }
    if([@"ColorInvert" isEqualToString:key] || [@"反转" isEqualToString:key]){
        return ColorInvert;
    }
    if([@"GrayScale" isEqualToString:key] || [@"灰度" isEqualToString:key]){
        return GrayScale;
    }
    if([@"SobelEdge" isEqualToString:key] || [@"边缘突显" isEqualToString:key]){
        return SobelEdge;
    }
    if([@"Sketch" isEqualToString:key] || [@"素描" isEqualToString:key]){
        return Sketch;
    }
    if([@"Emboss" isEqualToString:key] || [@"浮雕" isEqualToString:key]){
        return Emboss;
    }
    if([@"Vignette" isEqualToString:key] || [@"晕映" isEqualToString:key]){
        return Vignette;
    }
    if([@"GaussianBlur" isEqualToString:key] || [@"高斯模糊" isEqualToString:key]){
        return GaussianBlur;
    }
    if([@"HoleBlur" isEqualToString:key] || [@"虚化背影" isEqualToString:key]){
        return GaussianSelectiveBlur;
    }
    if([@"BoxBlur" isEqualToString:key] || [@"盒状模糊" isEqualToString:key]){
        return BoxBlur;
    }
    if([@"MotionBlur" isEqualToString:key] || [@"运动模糊" isEqualToString:key]){
        return MotionBlur;
    }
    if([@"Zoom" isEqualToString:key] || [@"变焦模糊" isEqualToString:key]){
        return ZoomBlur;
    }
    return Default;
}

- (IBAction)slideUpdate:(UISlider *)slider {
    switch (self.filterType) {
        case Contrast: {
            [(GPUImageContrastFilter *) _currentFilter setContrast:self.slider.value];
            break;
        }
        case Levels: {
            float value = [self.slider value];
            [(GPUImageLevelsFilter *) _currentFilter setRedMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            [(GPUImageLevelsFilter *) _currentFilter setGreenMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            [(GPUImageLevelsFilter *) _currentFilter setBlueMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            break;
        }
        case RGB: {
            [(GPUImageRGBFilter *) _currentFilter setGreen:[self.slider value]];
            break;
        }
        case HUE: {
            [(GPUImageHueFilter *) _currentFilter setHue:self.slider.value];
            break;
        }
        case WhiteBalance: {
            [(GPUImageWhiteBalanceFilter *) _currentFilter setTemperature:[self.slider value]];
            break;
        }
        case Sharpen: {
            [(GPUImageSharpenFilter *) _currentFilter setSharpness:[self.slider value]];
            break;
        }
        case Gamma: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:3.0];
            [self.slider setValue:1.5];

            [(GPUImageGammaFilter *) _currentFilter setGamma:[self.slider value]];
            break;
        }
        case ToneCurve: {
            [(GPUImageToneCurveFilter *) _currentFilter setBlueControlPoints:@[
                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                    [NSValue valueWithCGPoint:CGPointMake(0.5, self.slider.value)],
                    [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)]]];
            break;
        }
        case SepiaTone: {
            [(GPUImageSepiaFilter *) _currentFilter setIntensity:[self.slider value]];
            break;
        }
        case ColorInvert: {
            self.slider.hidden = YES;
            break;
        }
        case GrayScale: {
            self.slider.hidden = YES;
            break;
        }
        case SobelEdge: {
            [(GPUImageSobelEdgeDetectionFilter *) _currentFilter setEdgeStrength:[self.slider value]];
            break;
        }
        case Sketch: {
            [(GPUImageSketchFilter *) _currentFilter setEdgeStrength:[self.slider value]];
            break;
        }
        case Emboss: {
            [(GPUImageEmbossFilter *) _currentFilter setIntensity:[self.slider value]];
            break;
        }
        case Vignette: {
            [(GPUImageVignetteFilter *) _currentFilter setVignetteEnd:[self.slider value]];
            break;
        }
        case GaussianBlur: {
            [(GPUImageGaussianBlurFilter *) _currentFilter setBlurRadiusInPixels:[self.slider value]];
            break;
        }
        case GaussianSelectiveBlur: {
            [(GPUImageGaussianSelectiveBlurFilter *) _currentFilter setExcludeCircleRadius:[self.slider value]];
            break;
        }
        case BoxBlur: {
            [(GPUImageBoxBlurFilter *) _currentFilter setBlurRadiusInPixels:[self.slider value]];
            break;
        }
        case MotionBlur: {
            [(GPUImageMotionBlurFilter *) _currentFilter setBlurAngle:[self.slider value]];
            break;
        }
        case ZoomBlur: {
            [(GPUImageZoomBlurFilter *) _currentFilter setBlurSize:[self.slider value]];
            break;
        }
        default:
            break;
    }
    [self renderWithFilter:self.currentFilter];
}

- (void)setupSlider {
    switch (self.filterType) {
        case Contrast: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:4.0];
            [self.slider setValue:2.0];
            break;
        }
        case Levels: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:1.0];
            [self.slider setValue:0.2];
            break;
        }
        case RGB: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:2.0];
            [self.slider setValue:1.25];
            break;
        }
        case HUE: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:360.0];
            [self.slider setValue:90.0];
            break;
        }
        case WhiteBalance: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:2500.0];
            [self.slider setMaximumValue:7500.0];
            [self.slider setValue:5000.0];
            break;
        }
        case Sharpen: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:-1.0];
            [self.slider setMaximumValue:4.0];
            [self.slider setValue:4.0];
            break;
        }
        case Gamma: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:3.0];
            [self.slider setValue:1.5];
            break;
        }
        case ToneCurve: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:1.0];
            [self.slider setValue:0.75];
        }
        case SepiaTone: {
            self.slider.hidden = NO;
            [self.slider setValue:1.0];
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:1.0];
            break;
        }
        case ColorInvert: {
            self.slider.hidden = YES;
            break;
        }
        case GrayScale: {
            self.slider.hidden = YES;
            break;
        }
        case SobelEdge: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:1.0];
            [self.slider setValue:0.25];
            break;
        }
        case Sketch: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:1.0];
            [self.slider setValue:0.25];
            break;
        }
        case Emboss: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:5.0];
            [self.slider setValue:1.0];
            break;
        }
        case Vignette: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.5];
            [self.slider setMaximumValue:0.9];
            [self.slider setValue:0.75];
            break;
        }
        case GaussianBlur: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:24.0];
            [self.slider setValue:10.0];
            break;
        }
        case GaussianSelectiveBlur: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:.75f];
            [self.slider setValue:40.0 / 320.0];
            break;
        }
        case BoxBlur: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:30.0];
            [self.slider setValue:20.0];
            break;
        }
        case MotionBlur: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:180.0f];
            [self.slider setValue:0.0];
            break;
        }
        case ZoomBlur: {
            self.slider.hidden = NO;
            [self.slider setMinimumValue:0.0];
            [self.slider setMaximumValue:2.5f];
            [self.slider setValue:1.0];
            break;
        }
        default:
            self.slider.hidden = YES;
            break;

    }
}


@end
