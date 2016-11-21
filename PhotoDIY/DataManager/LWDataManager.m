//
//  LWDataManager.m
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWDataManager.h"
#import "GPUImageFilter.h"
#import "GPUImageBeautifyFilter.h"

@implementation LWDataManager

+ (LWDataManager *)sharedInstance {
    static LWDataManager *sharedInstance = nil;
    if (sharedInstance == nil) {
        sharedInstance = [[LWDataManager alloc] init];
    }
    return sharedInstance;
}

-(NSDictionary *)filters{
    GPUImageOutput *contrast = [GPUImageContrastFilter new];
    [((GPUImageContrastFilter *)contrast) setContrast:2.0];

    GPUImageOutput *levels = [GPUImageLevelsFilter new];
    [(GPUImageLevelsFilter *)levels setRedMin:0.2 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
    [(GPUImageLevelsFilter *)levels setGreenMin:0.2 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];
    [(GPUImageLevelsFilter *)levels setBlueMin:0.2 gamma:1.0 max:1.0 minOut:0.0 maxOut:1.0];

    GPUImageOutput *rgb = [GPUImageRGBFilter new];
    [((GPUImageRGBFilter *)rgb) setGreen:1.25];

    GPUImageOutput *hue = [GPUImageHueFilter new];

    GPUImageOutput *whiteBalance = [GPUImageWhiteBalanceFilter new];
    [(GPUImageWhiteBalanceFilter *)whiteBalance setTemperature:2500.0];

    GPUImageBeautifyFilter *beautify = [[GPUImageBeautifyFilter alloc] init];

    GPUImageOutput *sharpen = [GPUImageSharpenFilter new];
    [(GPUImageSharpenFilter *)sharpen setSharpness:4.0];

    GPUImageOutput *gamma = [GPUImageGammaFilter new];
    [(GPUImageGammaFilter *)gamma setGamma:1.5];

    GPUImageOutput *toneCurve = [GPUImageToneCurveFilter new];
    [(GPUImageToneCurveFilter *) toneCurve setBlueControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
            [NSValue valueWithCGPoint:CGPointMake(0.5, 0.75)],
            [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)]]];

    GPUImageOutput *sepiaTone = [GPUImageSepiaFilter new];

    GPUImageOutput *colorInvert = [GPUImageColorInvertFilter new];
    GPUImageOutput *grayScale = [GPUImageGrayscaleFilter new];
    GPUImageOutput *sobelEdge = [GPUImageSobelEdgeDetectionFilter new];

    GPUImageOutput *sketch = [GPUImageSketchFilter new];
    GPUImageOutput *emboss = [GPUImageEmbossFilter new];
    GPUImageOutput *vignette = [GPUImageVignetteFilter new];

    GPUImageOutput *gaussianBlur = [GPUImageGaussianBlurFilter new];
    [(GPUImageGaussianBlurFilter *)gaussianBlur setBlurRadiusInPixels:10.0];

    GPUImageOutput *gaussianSelectiveBlur = [GPUImageGaussianSelectiveBlurFilter new];

    GPUImageOutput *boxBlur = [GPUImageBoxBlurFilter new];
    [(GPUImageBoxBlurFilter *)boxBlur setBlurRadiusInPixels:20];

    GPUImageOutput *motionBlur = [GPUImageMotionBlurFilter new];
    [(GPUImageMotionBlurFilter *)motionBlur setBlurAngle:90];

    GPUImageOutput *zoomBlur = [GPUImageZoomBlurFilter new];

    return @{NSLocalizedString(@"contrast",nil):contrast,NSLocalizedString(@"levels",nil):levels,
            NSLocalizedString(@"rgb",nil):rgb,NSLocalizedString(@"hue",nil):hue,NSLocalizedString(@"whiteBalance",nil):whiteBalance,
            NSLocalizedString(@"beautify",nil):beautify,NSLocalizedString(@"sharpen",nil):sharpen,
            NSLocalizedString(@"gamma",nil):gamma,NSLocalizedString(@"toneCurve",nil):toneCurve,
            NSLocalizedString(@"sepiaTone",nil):sepiaTone,NSLocalizedString(@"colorInvert",nil):colorInvert,
            NSLocalizedString(@"grayScale",nil):grayScale,NSLocalizedString(@"sobelEdge",nil):sobelEdge,
            NSLocalizedString(@"sketch",nil):sketch,NSLocalizedString(@"emboss",nil):emboss,
            NSLocalizedString(@"vignette",nil):vignette,NSLocalizedString(@"gaussianBlur",nil):gaussianBlur,
            NSLocalizedString(@"gaussianSelectiveBlur",nil):gaussianSelectiveBlur,NSLocalizedString(@"boxBlur",nil):boxBlur,
            NSLocalizedString(@"motionBlur",nil):motionBlur,NSLocalizedString(@"zoomBlur",nil):zoomBlur};
}

-(NSDictionary *)filterImageName{
    return @{NSLocalizedString(@"contrast",nil):@"对比度调节",NSLocalizedString(@"levels",nil):@"色阶调节",
            NSLocalizedString(@"rgb",nil):@"RGB调节",NSLocalizedString(@"hue",nil):@"HUE调节",NSLocalizedString(@"whiteBalance",nil):@"白平衡",
            NSLocalizedString(@"beautify",nil):@"美白",NSLocalizedString(@"sharpen",nil):@"锐化",
            NSLocalizedString(@"gamma",nil):@"Gamma",NSLocalizedString(@"toneCurve",nil):@"色调美化",
            NSLocalizedString(@"sepiaTone",nil):@"褐色调",NSLocalizedString(@"colorInvert",nil):@"反转",
            NSLocalizedString(@"grayScale",nil):@"灰度",NSLocalizedString(@"sobelEdge",nil):@"边缘勾勒",
            NSLocalizedString(@"sketch",nil):@"素描",NSLocalizedString(@"emboss",nil):@"浮雕",
            NSLocalizedString(@"vignette",nil):@"晕映",NSLocalizedString(@"gaussianBlur",nil):@"高斯模糊",
            NSLocalizedString(@"gaussianSelectiveBlur",nil):@"虚化背影",NSLocalizedString(@"boxBlur",nil):@"盒状模糊",
            NSLocalizedString(@"motionBlur",nil):@"运动模糊",NSLocalizedString(@"zoomBlur",nil):@"变焦模糊"};
}



@end
