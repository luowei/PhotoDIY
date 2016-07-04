//
//  PDDrawView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "PDDrawView.h"
#import "Categorys.h"

@implementation PDDrawView

- (void)awakeFromNib {
    [super awakeFromNib];


}

//加载照片
- (void)loadPhoto {
    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    self.filter = [[GPUImageTiltShiftFilter alloc] init];

    [self.filter forceProcessingAtSize:self.gpuImageView.sizeInPixels];

    [self.sourcePicture addTarget:self.filter];
    [self.filter addTarget:self.gpuImageView];

    [self.sourcePicture processImage];
}


@end
