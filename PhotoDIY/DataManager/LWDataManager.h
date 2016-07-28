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

@interface LWDataManager : NSObject{

}

@property(nonatomic, strong) UIImage *currentImage;

+ (LWDataManager *)sharedInstance;

-(NSDictionary *)filters;


@end
