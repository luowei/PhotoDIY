//
//  PDDrawView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@interface PDDrawView : UIView

@property(nonatomic,strong) IBOutlet GPUImageView *gpuImageView;

@property(nonatomic,strong) GPUImagePicture *sourcePicture;
@property(nonatomic,strong) GPUImageOutput<GPUImageInput> *filter;

//加载照片
- (void)loadPhoto;

@end
