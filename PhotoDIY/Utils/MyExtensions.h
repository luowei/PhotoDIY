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

@end

@interface NSString(UIImage)

-(UIImage *)image:(CGSize)size;

@end

