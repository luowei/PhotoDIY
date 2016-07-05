//
//  LWFilterManager.m
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWFilterManager.h"
#import "GPUImageFilter.h"

@implementation LWFilterManager

+(NSDictionary *)filters{
    GPUImageOutput *contrast = [GPUImageContrastFilter new];
    GPUImageOutput *levels = [GPUImageLevelsFilter new];
    GPUImageOutput *rgb = [GPUImageRGBFilter new];
    GPUImageOutput *hue = [GPUImageHueFilter new];
    GPUImageOutput *whiteBalance = [GPUImageWhiteBalanceFilter new];

    GPUImageOutput *sharpen = [GPUImageSharpenFilter new];
    GPUImageOutput *gamma = [GPUImageGammaFilter new];
    GPUImageOutput *toneCurve = [GPUImageToneCurveFilter new];
    GPUImageOutput *sepiaTone = [GPUImageSepiaFilter new];
    GPUImageOutput *amatorka = [GPUImageAmatorkaFilter new];

    GPUImageOutput *missEtikate = [GPUImageMissEtikateFilter new];
    GPUImageOutput *softElegance = [GPUImageSoftEleganceFilter new];
    GPUImageOutput *colorInvert = [GPUImageColorInvertFilter new];
    GPUImageOutput *grayScale = [GPUImageGrayscaleFilter new];
    GPUImageOutput *sobelEdge = [GPUImageSobelEdgeDetectionFilter new];

    GPUImageOutput *sketch = [GPUImageSketchFilter new];
    GPUImageOutput *emboss = [GPUImageEmbossFilter new];
    GPUImageOutput *vignette = [GPUImageVignetteFilter new];
    GPUImageOutput *gaussianBlur = [GPUImageGaussianBlurFilter new];
    GPUImageOutput *gaussianSelectiveBlur = [GPUImageGaussianSelectiveBlurFilter new];

    GPUImageOutput *boxBlur = [GPUImageBoxBlurFilter new];
    GPUImageOutput *motionBlur = [GPUImageMotionBlurFilter new];
    GPUImageOutput *zoomBlur = [GPUImageZoomBlurFilter new];

    return @{@"contrast":contrast,@"levels":levels,@"rgb":rgb,@"hue":hue,@"whiteBalance":whiteBalance,@"sharpen":sharpen,
            @"gamma":gamma,@"toneCurve":toneCurve,@"sepiaTone":sepiaTone,@"amatorka":amatorka,@"missEtikate":missEtikate,
            @"softElegance":softElegance,@"colorInvert":colorInvert,@"grayScale":grayScale,@"sobelEdge":sobelEdge,
            @"sketch":sketch,@"emboss":emboss,@"vignette":vignette,@"gaussianBlur":gaussianBlur,@"gaussianSelectiveBlur":gaussianSelectiveBlur,
            @"boxBlur":boxBlur,@"motionBlur":motionBlur,@"zoomBlur":zoomBlur};
}



@end
