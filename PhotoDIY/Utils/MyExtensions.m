//
// Created by luowei on 2016/10/25.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "MyExtensions.h"
#import "BezierUtils.h"


@implementation MyExtensions {

}

@end

@implementation UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            [NSException raise:@"Invalid color value" format:@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return (CGFloat) (hexComponent / 255.0);
}

- (UIColor *)inverseColor {
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:(CGFloat) (1.0 - r) green:(CGFloat) (1.0 - g) blue:(CGFloat) (1.0 - b) alpha:a];
}

- (BOOL)isLight {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000;
    return brightness >= 0.5;
}

@end


@implementation UIImage (Color)

//给指定的图片染色
- (UIImage *)imageWithOverlayColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);

    //    if (UIGraphicsBeginImageContextWithOptions) {
    CGFloat imageScale = 1.0f;
    if ([self respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
        imageScale = self.scale;
    UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
    //    }
    //    else {
    //        UIGraphicsBeginImageContext(self.size);
    //    }

    [self drawInRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor {
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor {
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode {
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);

    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

//根据颜色与矩形区生成一张图片
+ (UIImage *)imageFromColor:(UIColor *)color withRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end


@implementation UIImage (String)

//把字符串依据指定的字体属性及大小转换成图片
+ (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end


@implementation UIImage (Cut)

//根据指定矩形区,剪裁图片
- (UIImage *)cutImageWithRect:(CGRect)cutRect {
    CGImageRef cutImageRef = CGImageCreateWithImageInRect(self.CGImage, cutRect);
    UIImage *cutImage = [UIImage imageWithCGImage:cutImageRef];
    return cutImage;
}

//在指定大小的绘图区域内,将img2合成到img1上
+ (UIImage *)addImageToImage:(UIImage *)img withImage2:(UIImage *)img2
                     andRect:(CGRect)cropRect withImageSize:(CGSize)size {

    UIGraphicsBeginImageContext(size);

    CGPoint pointImg1 = CGPointMake(0, 0);
    [img drawAtPoint:pointImg1];

    CGPoint pointImg2 = cropRect.origin;
    [img2 drawAtPoint:pointImg2];

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;

}

//把一张图片缩放到指定大小
- (UIImage *)imageToscaledSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//把一张图片按长宽等比例缩放到适应指定大小
- (UIImage *)scaleToSizeKeepAspect:(CGSize)size {
    UIGraphicsBeginImageContext(size);

    CGFloat ws = size.width / self.size.width;
    CGFloat hs = size.height / self.size.height;

    if (ws > hs) {
        ws = hs / ws;
        hs = 1.0;
    } else {
        hs = ws / hs;
        ws = 1.0;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextDrawImage(context, CGRectMake(size.width / 2 - (size.width * ws) / 2,
            size.height / 2 - (size.height * hs) / 2, size.width * ws,
            size.height * hs), self.CGImage);

    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return scaledImage;
}

//把图片按指定比例缩放
- (UIImage *)imageToScale:(CGFloat)scale {
    UIGraphicsBeginImageContextWithOptions(self.size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end


@implementation NSString (UIImage)

- (UIImage *)image:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor clearColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    [self drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:(CGFloat) floor(size.width * 0.9)]}];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end


@implementation UIView (Rotate)

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    CGPoint oldOrigin = self.frame.origin;
    self.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = self.frame.origin;

    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    self.center = CGPointMake(self.center.x - transition.x, self.center.y - transition.y);
}

- (void)setDefaultAnchorPoint {
    [self setAnchorPoint:CGPointMake(0.5f, 0.5f)];
}

//旋转
- (void)rotateAngle:(CGFloat)angle {
    CGFloat radians = (CGFloat) (angle * M_PI / 180);
    CGAffineTransform transform = CGAffineTransformRotate(self.transform, radians);
    self.transform = transform;
}

@end


@implementation UIBezierPath(Rotate)

//旋转UIBzierPath
- (void)rotateDegree:(CGFloat)degree{
    CGRect bounds = CGPathGetBoundingBox(self.CGPath);
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    CGFloat radians = (CGFloat) (degree / 180.0f * M_PI);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, center.x, center.y);
    transform = CGAffineTransformRotate(transform, radians);
    transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
    [self applyTransform:transform];
}

//缩放UIBezierPath，宽度缩放比scaleW，高度缩放比scaleH
-(void)scaleWidth:(CGFloat)scaleW scaleHeight:(CGFloat)scaleH{
    CGRect bounds = CGPathGetBoundingBox(self.CGPath);
    CGPoint origin = CGPointMake(CGRectGetMinX(bounds),CGRectGetMinY(bounds));
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

//    CGAffineTransform transform = CGAffineTransformMakeScale(scaleW, scaleH);
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, center.x, center.y);
    //t = CGAffineTransformConcat(transform, t);
    t = CGAffineTransformScale(t,scaleW,scaleH);
    t = CGAffineTransformTranslate(t, -center.x, -center.y);
    [self applyTransform:t];

    //以origin为参照点进行拉伸
    MovePathToPoint(self,origin);
}

//按中心点移动缩放UIBezierPath
-(void)moveCenterToPoint:(CGPoint)destPoint{
    CGRect bounds = CGPathGetBoundingBox(self.CGPath);
    CGPoint p1 = bounds.origin;
    CGPoint p2 = destPoint;
    CGSize offset = CGSizeMake(p2.x - p1.x, p2.y - p1.y);
    offset.width -= bounds.size.width / 2.0f;
    offset.height -= bounds.size.height / 2.0f;

    CGPoint center = PathBoundingCenter(self);
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, center.x, center.y);
    t = CGAffineTransformTranslate(t,offset.width,offset.height);
    t = CGAffineTransformTranslate(t, -center.x, -center.y);
    [self applyTransform:t];
}

@end

//旋转point
CGPoint RotatePoint(CGPoint pointToRotate, CGFloat degree, CGPoint origin){
    float angleInRadians = (float) (degree * M_PI / 180);
    CGPoint distanceFromOrigin = CGPointMake(origin.x - pointToRotate.x, origin.y - pointToRotate.y);

    CGAffineTransform translateToOrigin = CGAffineTransformMakeTranslation(distanceFromOrigin.x, distanceFromOrigin.y);
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(angleInRadians);
    CGAffineTransform translateBackFromOrigin = CGAffineTransformInvert(translateToOrigin);

    CGAffineTransform totalTransform = CGAffineTransformConcat(translateToOrigin, rotationTransform);
    totalTransform = CGAffineTransformConcat(totalTransform, translateBackFromOrigin);

    CGPoint rotatedPoint = CGPointApplyAffineTransform(pointToRotate, totalTransform);
    return rotatedPoint;
}

//平移Point到原始位置
CGPoint BackOffsetPoint(CGPoint point, CGSize offset){
    CGPoint backOffsetedPoint = CGPointMake(point.x - offset.width,point.y - offset.height);
    return backOffsetedPoint;
}

//缩放Point到原始位置
CGPoint BackScalePoint(CGPoint point,CGPoint origin,CGFloat scaleX,CGFloat scaleY){
    CGSize offset = CGSizeMake(point.x - origin.x,point.y - origin.y);
    CGSize backScaleOffset = CGSizeMake(offset.width / scaleX,offset.height / scaleY);
    CGPoint backScaledPoint = CGPointMake(origin.x + backScaleOffset.width,origin.y + backScaleOffset.height);
    return backScaledPoint;
}