//
//  USAssetGroupTableCell.m
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetGroupTableCell.h"

@interface USAssetGroupTableCell ()

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) PHCollection *phCollection;
@property (nonatomic, assign) PHImageRequestID requestID;


@end

@implementation USAssetGroupTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:17];
        self.textLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:13];
        self.detailTextLabel.textColor = [UIColor blackColor];
        
        self.imageView.tintColor = RGBACOLOR(151, 151, 151, 1);
        self.imageView.backgroundColor = RGBACOLOR(230, 230, 230, 1);
        
        self.imageView.clipsToBounds = YES;
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(100, 26, 200, 19);
    self.detailTextLabel.frame = CGRectMake(100, 55, 200, 15);
    self.imageView.frame = CGRectMake(15, 10, kThumbnailLength, kThumbnailLength);
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundColor = RGBACOLOR(225,225,225,1);
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setHighlighted:selected animated:animated];
}

- (void)bind:(id)assetsGroup
{
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([assetsGroup isKindOfClass:[PHCollection class]]) {
        self.phCollection = assetsGroup;
        
        self.textLabel.text     = self.phCollection.localizedTitle;
        
        PHAssetCollection *assetCollection = (PHAssetCollection *)self.phCollection;
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
        
        //统计数量不需要排序
        NSUInteger count = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options].count;
        self.detailTextLabel.text  = [NSString stringWithFormat:@"%@", @(count)];
        
        //获取预览图需要按时间排序
        //options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
        PHFetchResult *fetchResult = [PHAsset fetchKeyAssetsInAssetCollection:assetCollection options:options];
        
        NSInteger tag = self.tag + 1;
        self.tag = tag;
        
        if (!fetchResult.count) {
            self.imageView.contentMode = UIViewContentModeCenter;
            self.imageView.image = [[UIImage imageNamed:@"USPicker-Empty-Album"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            return;
        }
        
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        
        NSInteger retinaMultiplier  = [UIScreen mainScreen].scale;
        CGSize retinaSquare = CGSizeMake(kThumbnailLength * retinaMultiplier, kThumbnailLength * retinaMultiplier);
        
        [[PHImageManager defaultManager] cancelImageRequest:_requestID];
        
        _requestID = [[PHImageManager defaultManager] requestImageForAsset:fetchResult.firstObject
                                                                targetSize:[PHAsset targetSizeByCompatibleiPad:retinaSquare]
                                                               contentMode:PHImageContentModeAspectFill
                                                                   options:requestOptions
                                                             resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                 if (self.tag == tag && result) {
                                                                     CGImageRef posterImage = result.CGImage;
                                                                     
                                                                     size_t height          = CGImageGetHeight(posterImage);
                                                                     float scale            = height / kThumbnailLength;
                                                                     self.imageView.image   = [UIImage imageWithCGImage:posterImage
                                                                                                                  scale:scale
                                                                                                            orientation:UIImageOrientationUp];
                                                                     self.imageView.contentMode = UIViewContentModeScaleAspectFill;
                                                                 }
                                                             }];
        return;
    }
    
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = self.assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / kThumbnailLength;
    
    if (!posterImage) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.image = [[UIImage imageNamed:@"USPicker-Empty-Album"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else {
        self.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)[assetsGroup numberOfAssets]];
}

@end
