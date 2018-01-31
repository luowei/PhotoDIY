//
// Created by luowei on 2016/10/25.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "MyExtensions.h"
#import "BezierUtils.h"
#import <CommonCrypto/CommonDigest.h>


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
    CGImageRelease(cutImageRef);
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

@implementation UIView (UIImage)

- (UIImage *)snapshot {
    UIImage *snapShot = nil;
//    UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        snapShot = UIGraphicsGetImageFromCurrentImageContext();

    }

    UIGraphicsEndImageContext();
    return snapShot;

}

@end


@implementation UIBezierPath (Rotate)

//旋转UIBzierPath
- (void)rotateDegree:(CGFloat)degree {
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
- (void)scaleWidth:(CGFloat)scaleW scaleHeight:(CGFloat)scaleH {
    CGRect bounds = CGPathGetBoundingBox(self.CGPath);
    CGPoint origin = CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

//    CGAffineTransform transform = CGAffineTransformMakeScale(scaleW, scaleH);
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, center.x, center.y);
    //t = CGAffineTransformConcat(transform, t);
    t = CGAffineTransformScale(t, scaleW, scaleH);
    t = CGAffineTransformTranslate(t, -center.x, -center.y);
    [self applyTransform:t];

    //以origin为参照点进行拉伸
    MovePathToPoint(self, origin);
}

//按中心点移动缩放UIBezierPath
- (void)moveCenterToPoint:(CGPoint)destPoint {
    CGRect bounds = CGPathGetBoundingBox(self.CGPath);
    CGPoint p1 = bounds.origin;
    CGPoint p2 = destPoint;
    CGSize offset = CGSizeMake(p2.x - p1.x, p2.y - p1.y);
    offset.width -= bounds.size.width / 2.0f;
    offset.height -= bounds.size.height / 2.0f;

    CGPoint center = PathBoundingCenter(self);
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, center.x, center.y);
    t = CGAffineTransformTranslate(t, offset.width, offset.height);
    t = CGAffineTransformTranslate(t, -center.x, -center.y);
    [self applyTransform:t];
}

@end

@implementation UIView (APIFix)

- (UIViewController *)viewController {
    UIResponder *responder = self;
    while (![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    //返回
    if([responder isKindOfClass:[UIViewController class]]){
        return (UIViewController *)responder;
    }else{
        return nil;
    }

}
@end

@implementation UIWindow (PazLabs)

- (UIViewController *)visibleViewController {
    UIViewController *rootViewController = self.rootViewController;
    return [UIWindow getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [UIWindow getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

@end



//旋转point
CGPoint RotatePoint(CGPoint pointToRotate, CGFloat degree, CGPoint origin) {
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
CGPoint BackOffsetPoint(CGPoint point, CGSize offset) {
    CGPoint backOffsetedPoint = CGPointMake(point.x - offset.width, point.y - offset.height);
    return backOffsetedPoint;
}

//缩放Point到原始位置
CGPoint BackScalePoint(CGPoint point, CGPoint origin, CGFloat scaleX, CGFloat scaleY) {
    CGSize offset = CGSizeMake(point.x - origin.x, point.y - origin.y);
    CGSize backScaleOffset = CGSizeMake(offset.width / scaleX, offset.height / scaleY);
    CGPoint backScaledPoint = CGPointMake(origin.x + backScaleOffset.width, origin.y + backScaleOffset.height);
    return backScaledPoint;
}

@implementation NSString (Encode)

//md5 32位 加密 （小写）
- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}
- (NSString*) mk_urlEncodedString { // mk_ prefix prevents a clash with a private api

    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            (__bridge CFStringRef) self,
            nil,
            CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
            kCFStringEncodingUTF8);

    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];

    if(!encodedString)
        encodedString = @"";

    return encodedString;
}
@end


@implementation NSData(DataMimeType)

//媒体类型
- (NSString *)dataMimeType {

    if(self.length > 12){
        unsigned char bytes[12];  // <=>
        [self getBytes:&bytes length:12];


        NSMutableString *sbuf = @"".mutableCopy;
        NSInteger i;
        for (i=0; i<12; ++i) {
            [sbuf appendFormat:@"%02X", (NSUInteger)bytes[i]];
        }
        NSLog(@"=======bytes:%@",sbuf);

        if(bytes[8] == 0x33 && bytes[9] == 0x67 && bytes[10] == 0x70){
            return @"video/3gpp";
        }
        if(bytes[8] == 0x4d && bytes[9] == 0x34 && bytes[10] == 0x56 && bytes[11] == 0x20){
            //return @"video/x-flv;video/m4v";
            return @"video/x-flv";
        }
        if(bytes[8] == 0x4d && bytes[9] == 0x53 && bytes[10] == 0x4e && bytes[11] == 0x56){
            return @"video/mp4";
        }
        if(bytes[8] == 0x69 && bytes[9] == 0x73 && bytes[10] == 0x6f && bytes[11] == 0x6d){
            return @"video/mp4";
        }
        if(bytes[8] == 0x6D && bytes[9] == 0x70 && bytes[10] == 0x34 && bytes[11] == 0x32){
            return @"video/m4v";
        }
        if(bytes[8] == 0x71 && bytes[9] == 0x74 && bytes[10] == 0x20 && bytes[11] == 0x20){
            return @"video/quicktime";
        }
    }


    uint8_t c;
    [self getBytes:&c length:1];

    //文件头签名列表：https://en.wikipedia.org/wiki/List_of_file_signatures
    //mime type:https://www.sitepoint.com/mime-types-complete-list/
    switch (c) {
        case 0xFF:{
            uint16_t s;
            [self getBytes:&s length:1];
            if(s == 0xFFFB){
                return @"audio/mpeg3";
            }
            return @"image/jpeg";
        }
        case 0x89:{
            return @"image/png";
        }
        case 0x47:{
            return @"image/gif";
        }
        case 0x49:
        case 0x4D:{
            uint16_t s;
            [self getBytes:&s length:1];
            if(s == 0x4944){
                return @"audio/mpeg3";
            }
            return @"image/tiff";
        }
        case 0x25:{
            return @"application/pdf";
        }
        case 0xD0:{
            return @"application/vnd";
        }
        case 0x23:
        case 0x7b:  //rtf
        case 0x81:  //WordPerfect text file
        case 0x46:{
            return @"text/plain";
        }
        case 0x50:{  //zip,jar,odt,ods,odp,docx,xlsx,pptx,vsdx,apk,aar
            return @"application/zip";
        }
        case 0x52:{ //avi,wav
            return @"video/avi";
        }
        default:{
            return @"application/octet-stream";
        }

    }
    return @"application/octet-stream";
}

//后缀
-(NSString *)dataSuffix {

    if(self.length > 12){
        unsigned char bytes[12];  // <=>
        [self getBytes:&bytes length:12];


        NSMutableString *sbuf = @"".mutableCopy;
        NSInteger i;
        for (i=0; i<12; ++i) {
            [sbuf appendFormat:@"%02X", (NSUInteger)bytes[i]];
        }
        NSLog(@"=======bytes:%@",sbuf);

        if(bytes[8] == 0x33 && bytes[9] == 0x67 && bytes[10] == 0x70){
            return @"3gp";
        }
        if(bytes[8] == 0x4d && bytes[9] == 0x34 && bytes[10] == 0x56 && bytes[11] == 0x20){
            return @"flv";
        }
        if(bytes[8] == 0x4d && bytes[9] == 0x53 && bytes[10] == 0x4e && bytes[11] == 0x56){
            return @"mp4";
        }
        if(bytes[8] == 0x69 && bytes[9] == 0x73 && bytes[10] == 0x6f && bytes[11] == 0x6d){
            return @"mp4";
        }
        if(bytes[8] == 0x6D && bytes[9] == 0x70 && bytes[10] == 0x34 && bytes[11] == 0x32){
            return @"m4v";
        }
        if(bytes[8] == 0x71 && bytes[9] == 0x74 && bytes[10] == 0x20 && bytes[11] == 0x20){
            return @"mov";
        }
    }


    uint8_t c;
    [self getBytes:&c length:1];

    switch (c) {
        case 0xFF:{
            uint16_t s;
            [self getBytes:&s length:1];
            if(s == 0xFFFB){
                return @"mp3";
            }
            return @"jpg";
        }
        case 0x89:{
            return @"png";
        }
        case 0x47:{
            return @"gif";
        }
        case 0x49:
        case 0x4D:{
            uint16_t s;
            [self getBytes:&s length:1];
            if(s == 0x4944){
                return @"mp3";
            }
            return @"tiff";
        }
        case 0x25:{
            return @"pdf";
        }
        case 0xD0:{
            return @"vnd";
        }
        case 0x23:
        case 0x7b:{  //rtf
            return @"rtf";
        }
        case 0x81:  //WordPerfect text file
        case 0x46:{ //text file
            return @"";//@"txt";
        }
        case 0x50:{  //zip,jar,odt,ods,odp,docx,xlsx,pptx,vsdx,apk,aar
            return @"zip";
        }
        case 0x52:{ //avi,wav
            return @"avi";
        }
        default:{
            return @"";
        }

    }
    return @"";
}


@end