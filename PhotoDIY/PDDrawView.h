//
//  PDDrawView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@class LWFilterCollectionView;
@class LWPhotoCollectionView;

@interface PDDrawView : UIView

@property(nonatomic,strong) IBOutlet GPUImageView *gpuImageView;
@property(nonatomic,strong) IBOutlet LWFilterCollectionView *filterCollectionView;
@property(nonatomic,strong) IBOutlet LWPhotoCollectionView *photoCollectionView;

@property(nonatomic,strong) IBOutlet NSLayoutConstraint *gpuImageHeight;



@property(nonatomic,strong) GPUImagePicture *sourcePicture;
@property(nonatomic,strong) GPUImageOutput<GPUImageInput> *filter;

//加载照片
- (void)loadPhoto;

//加载滤镜
-(void)loadFilter;

@end
