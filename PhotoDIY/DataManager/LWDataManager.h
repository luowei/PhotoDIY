//
//  LWDataManager.h
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright (c) 2016 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>

typedef NS_ENUM(NSInteger, DIYMode) {
    ImageMode    =   0,
    FilterMode   =   1,
    CropMode     =   1 << 1,
    DrawMode     =   1 << 2,
};


typedef NS_ENUM(NSInteger,FilterType){
    Default,
    Contrast,
    Levels,
    RGB,
    HUE,
    WhiteBalance,
    Sharpen,
    Beautify,
    Gamma,
    ToneCurve,
    SepiaTone,
    ColorInvert,
    GrayScale,
    SobelEdge,
    Sketch,
    Emboss,
    Vignette,
    GaussianBlur,
    GaussianSelectiveBlur,
    BoxBlur,
    MotionBlur,
    ZoomBlur,
};

#define FilterTypeDict @{                   \
    @"contrast" 			 : @(Contrast),    \
    @"levels" 				 : @(Levels),    \
    @"rgb" 					 : @(RGB),    \
    @"hue" 					 : @(HUE),    \
    @"whiteBalance" 		 : @(WhiteBalance),    \
    @"sharpen" 				 : @(Sharpen),    \
    @"gamma" 				 : @(Gamma),    \
    @"toneCurve" 			 : @(ToneCurve),    \
    @"sepiaTone" 			 : @(SepiaTone),    \
    @"colorInvert" 			 : @(ColorInvert),    \
    @"grayScale" 			 : @(GrayScale),    \
    @"sobelEdge" 			 : @(SobelEdge),    \
    @"sketch" 				 : @(Sketch),    \
    @"emboss" 				 : @(Emboss),    \
    @"vignette" 			 : @(Vignette),    \
    @"gaussianBlur" 		 : @(GaussianBlur),    \
    @"gaussianSelectiveBlur" : @(GaussianSelectiveBlur),    \
    @"boxBlur" 				 : @(BoxBlur),    \
    @"motionBlur" 			 : @(MotionBlur),    \
    @"zoomBlur" 			 : @(ZoomBlur)    \
}


@interface LWDataManager : NSObject{

}

@property(nonatomic, strong) UIImage *currentImage;

@property(nonatomic, strong) UIImage *originImage;

+ (LWDataManager *)sharedInstance;

-(NSDictionary *)filters;

-(NSDictionary *)filterImageName;


@end
