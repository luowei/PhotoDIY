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
    dm.currentImage = dm.originImage;

    //重新加载初始图片再渲染
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:dm.currentImage smoothlyScaleOutput:YES];

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
    self.filter = filters[key];
    [self renderWithFilter:self.filter];
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
//    LWContentView *contentView = [self superViewWithClass:[LWContentView class]];
//    UISlider *slider = contentView.filterBar.slider;

    switch (self.filterType) {
        case Contrast: {
            [(GPUImageContrastFilter *) self.filter setContrast:slider.value];
            break;
        }
        case Levels: {
            float value = [slider value];
            [(GPUImageLevelsFilter *) self.filter setRedMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            [(GPUImageLevelsFilter *) self.filter setGreenMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            [(GPUImageLevelsFilter *) self.filter setBlueMin:value gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
            break;
        }
        case RGB: {
            [(GPUImageRGBFilter *) self.filter setGreen:[slider value]];
            break;
        }
        case HUE: {
            [(GPUImageHueFilter *) self.filter setHue:slider.value];
            break;
        }
        case WhiteBalance: {
            [(GPUImageWhiteBalanceFilter *) self.filter setTemperature:[slider value]];
            break;
        }
        case Sharpen: {
            [(GPUImageSharpenFilter *) self.filter setSharpness:[slider value]];
            break;
        }
        case Gamma: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:3.0];
            [slider setValue:1.5];

            [(GPUImageGammaFilter *) self.filter setGamma:[slider value]];
            break;
        }
        case ToneCurve: {
            [(GPUImageToneCurveFilter *) self.filter setBlueControlPoints:@[
                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                    [NSValue valueWithCGPoint:CGPointMake(0.5, slider.value)],
                    [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)]]];
            break;
        }
        case SepiaTone: {
            [(GPUImageSepiaFilter *) self.filter setIntensity:[slider value]];
            break;
        }
        case ColorInvert: {
            slider.hidden = YES;
            break;
        }
        case GrayScale: {
            slider.hidden = YES;
            break;
        }
        case SobelEdge: {
            [(GPUImageSobelEdgeDetectionFilter *) self.filter setEdgeStrength:[slider value]];
            break;
        }
        case Sketch: {
            [(GPUImageSketchFilter *) self.filter setEdgeStrength:[slider value]];
            break;
        }
        case Emboss: {
            [(GPUImageEmbossFilter *) self.filter setIntensity:[slider value]];
            break;
        }
        case Vignette: {
            [(GPUImageVignetteFilter *) self.filter setVignetteEnd:[slider value]];
            break;
        }
        case GaussianBlur: {
            [(GPUImageGaussianBlurFilter *) self.filter setBlurRadiusInPixels:[slider value]];
            break;
        }
        case GaussianSelectiveBlur: {
            [(GPUImageGaussianSelectiveBlurFilter *) self.filter setExcludeCircleRadius:[slider value]];
            break;
        }
        case BoxBlur: {
            [(GPUImageBoxBlurFilter *) self.filter setBlurRadiusInPixels:[slider value]];
            break;
        }
        case MotionBlur: {
            [(GPUImageMotionBlurFilter *) self.filter setBlurAngle:[slider value]];
            break;
        }
        case ZoomBlur: {
            [(GPUImageZoomBlurFilter *) self.filter setBlurSize:[slider value]];
            break;
        }
        default:
            break;
    }
//    LWDataManager *dm = [LWDataManager sharedInstance];
//
//    [self.filter forceProcessingAtSize:dm.currentImage.size];
//    [self.sourcePicture removeAllTargets];
//    [self.filter removeAllTargets];
//
//    [self.sourcePicture addTarget:self.filter];
//    [self.filter addTarget:self];
//
//    [self.filter useNextFrameForImageCapture];
//    [self.sourcePicture processImage];
//
//    NSLog(@"================= valueChanged");

    [self renderWithFilter:self.filter];
}

- (void)setupSlider {
    LWContentView *contentView = [self superViewWithClass:[LWContentView class]];
    UISlider *slider = contentView.filterBar.slider;

    switch (self.filterType) {
        case Contrast: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:4.0];
            [slider setValue:2.0];
            break;
        }
        case Levels: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:1.0];
            [slider setValue:0.2];
            break;
        }
        case RGB: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:2.0];
            [slider setValue:1.25];
            break;
        }
        case HUE: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:360.0];
            [slider setValue:90.0];
            break;
        }
        case WhiteBalance: {
            slider.hidden = NO;
            [slider setMinimumValue:2500.0];
            [slider setMaximumValue:7500.0];
            [slider setValue:5000.0];
            break;
        }
        case Sharpen: {
            slider.hidden = NO;
            [slider setMinimumValue:-1.0];
            [slider setMaximumValue:4.0];
            [slider setValue:4.0];
            break;
        }
        case Gamma: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:3.0];
            [slider setValue:1.5];
            break;
        }
        case ToneCurve: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:1.0];
            [slider setValue:0.75];
        }
        case SepiaTone: {
            slider.hidden = NO;
            [slider setValue:1.0];
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:1.0];
            break;
        }
        case ColorInvert: {
            slider.hidden = YES;
            break;
        }
        case GrayScale: {
            slider.hidden = YES;
            break;
        }
        case SobelEdge: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:1.0];
            [slider setValue:0.25];
            break;
        }
        case Sketch: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:1.0];
            [slider setValue:0.25];
            break;
        }
        case Emboss: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:5.0];
            [slider setValue:1.0];
            break;
        }
        case Vignette: {
            slider.hidden = NO;
            [slider setMinimumValue:0.5];
            [slider setMaximumValue:0.9];
            [slider setValue:0.75];
            break;
        }
        case GaussianBlur: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:24.0];
            [slider setValue:10.0];
            break;
        }
        case GaussianSelectiveBlur: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:.75f];
            [slider setValue:40.0 / 320.0];
            break;
        }
        case BoxBlur: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:30.0];
            [slider setValue:20.0];
            break;
        }
        case MotionBlur: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:180.0f];
            [slider setValue:0.0];
            break;
        }
        case ZoomBlur: {
            slider.hidden = NO;
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:2.5f];
            [slider setValue:1.0];
            break;
        }
        default:
            slider.hidden = YES;
            break;

    }
}


@end
