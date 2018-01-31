//
// Created by luowei on 2016/10/25.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

//CGPoint (^CGRectGetCenter)(CGRect) = ^(CGRect rect) {
//    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
//};


@interface MyExtensions : NSObject
@end

@interface UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length;

- (UIColor *)inverseColor;

- (BOOL)isLight;

@end

@interface UIImage (Color)

/**
 * 给指定的图片染色
 */
- (UIImage *)imageWithOverlayColor:(UIColor *)color;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;

- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

//根据颜色与矩形区生成一张图片
+ (UIImage *)imageFromColor:(UIColor *)color withRect:(CGRect)rect;

@end

@interface UIImage (String)

//把字符串依据指定的字体属性及大小转换成图片
+ (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size;

@end

@interface UIImage (Cut)

//根据指定矩形区,剪裁图片
- (UIImage *)cutImageWithRect:(CGRect)cutRect;

//在指定大小的绘图区域内,将img2合成到img1上
+ (UIImage *)addImageToImage:(UIImage *)img withImage2:(UIImage *)img2
                     andRect:(CGRect)cropRect withImageSize:(CGSize)size;

//把一张图片缩放到指定大小
- (UIImage *)imageToscaledSize:(CGSize)newSize;

//把一张图片按比例缩放到指定大小
- (UIImage *)scaleToSizeKeepAspect:(CGSize)size;

//把图片按指定比例缩放
- (UIImage *)imageToScale:(CGFloat)scale;

@end

@interface NSString (UIImage)

- (UIImage *)image:(CGSize)size;

@end

@interface UIView (Rotate)

//设置锚点
- (void)setAnchorPoint:(CGPoint)anchorPoint;

- (void)setDefaultAnchorPoint;

//旋转
- (void)rotateAngle:(CGFloat)angle;

@end

@interface UIView (UIImage)

- (UIImage *)snapshot;

@end


@interface UIView (APIFix)
- (UIViewController *)viewController;
@end



@interface UIWindow (PazLabs)

- (UIViewController *) visibleViewController;

@end



@interface UIBezierPath(Rotate)

//旋转UIBzierPath
- (void)rotateDegree:(CGFloat)degree;

//缩放UIBezierPath，宽度缩放比scaleW，高度缩放比scaleH
-(void)scaleWidth:(CGFloat)scaleW scaleHeight:(CGFloat)scaleH;

//按中心点移动缩放UIBezierPath
-(void)moveCenterToPoint:(CGPoint)destPoint;

@end


CGPoint RotatePoint(CGPoint point, CGFloat degree, CGPoint origin);

//平移Point到原始位置
CGPoint BackOffsetPoint(CGPoint point, CGSize offset);

//缩放Point到原始位置
CGPoint BackScalePoint(CGPoint point,CGPoint origin,CGFloat scaleX,CGFloat scaleY);


@interface NSString (Encode)

- (NSString *)md5;
- (NSString*) mk_urlEncodedString;

@end



@interface NSData (DataMimeType)

//媒体类型
- (NSString *)dataMimeType;

//后缀
-(NSString *)dataSuffix;

@end


