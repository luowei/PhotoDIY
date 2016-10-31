//
// Created by luowei on 2016/10/25.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyExtensions : NSObject
@end

@interface UIColor(HexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end

@interface UIImage(Color)

/**
 * 给指定的图片染色
 */
- (UIImage *)imageWithOverlayColor:(UIColor *)color;

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

//根据颜色与矩形区生成一张图片
+ (UIImage *)imageFromColor:(UIColor *)color withRect:(CGRect)rect;

@end

@interface UIImage(String)

//把字符串依据指定的字体属性及大小转换成图片
+ (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size;

@end

@interface UIImage(Cut)

//根据指定矩形区,剪裁图片
- (UIImage *)cutImageWithRect:(CGRect)cutRect;

//在指定大小的绘图区域内,将img2合成到img1上
+ (UIImage *) addImageToImage:(UIImage *)img withImage2:(UIImage *)img2
                      andRect:(CGRect)cropRect withImageSize:(CGSize)size;

//把一张图片缩放到指定大小
- (UIImage *)imageToscaledSize:(CGSize)newSize;

//把一张图片按比例缩放到指定大小
- (UIImage*)scaleToSizeKeepAspect:(CGSize)size;

//把图片按指定比例缩放
- (UIImage *)imageToScale:(CGFloat)scale;

@end

@interface NSString(UIImage)

-(UIImage *)image:(CGSize)size;

@end

