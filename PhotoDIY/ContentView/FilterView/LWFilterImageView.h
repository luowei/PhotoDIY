//
//  LWFilterImageView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/27.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "LWDataManager.h"

@interface LWFilterImageView : GPUImageView

@property(nonatomic,weak) IBOutlet UISlider *slider;

@property(nonatomic,strong) GPUImageOutput<GPUImageInput> *filter;
@property(nonatomic,strong) GPUImagePicture *sourcePicture;

@property(nonatomic) enum FilterType filterType;

- (void)reloadGPUImagePicture;

//load 照片到 GPUImagePicture
- (void)loadImage2GPUImagePicture:(UIImage *)image;

- (void)renderWithFilter:(GPUImageOutput<GPUImageInput> *)output;

- (void)renderWithFilterKey:(NSString *)key;

@end
