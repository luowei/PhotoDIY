//
//  PHAsset+ImagePicker.h
//  USImagePickerController
//
//  Created by marujun on 16/7/5.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (ImagePicker)

/** 尺寸 */
- (CGSize)dimensions;

/** 最后编辑时间 */
- (NSDate *)modifiedDate;

/** 原始文件名 */
- (NSString *)originalFilename;

/** 全屏图 */
- (UIImage *)fullScreenImage;

/** 原始比例的缩略图 */
- (UIImage *)aspectRatioThumbnailImage;

/** 原始比例的高清图 */
- (UIImage *)aspectRatioHDImage;

/** 原始照片数据，谨慎使用！注意：RAW格式的照片【UIImage】无法识别 */
- (NSData *)originalImageData;

/** 通过指定宽高的最大像素值来获取对应的缩略图 */
- (UIImage *)thumbnailImageWithMaxPixelSize:(CGFloat)maxPixelSize;

/**
 *  通过照片的localIdentifier获取对应的PHAsset实例
 *
 *  @param identifier 照片的localIdentifier，例如：DBA1FCE0-39BE-40FE-9A34-292A19835469/L0/001
 *
 *  @return PHAsset实例
 */
+ (instancetype)fetchAssetWithIdentifier:(NSString *)identifier;

/**
 *  Get metadata dictionary of an asset (the kind with {Exif}, {GPS}, etc...
 *
 *  @param completionHandler This block is passed a dictionary of metadata properties. See ImageIO framework for parsing/reading these. This parameter may be nil.
 */
- (void)requestMetadataWithCompletionHandler:(void(^)(NSDictionary *metadata))completionHandler;

@end
