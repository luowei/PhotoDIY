//
// Created by luowei on 2018/1/24.
// Copyright (c) 2018 wodedata. All rights reserved.
//

#import "ShareCategories.h"

@implementation NSData (Ext)


/*
video files mimetype
Video Type	Extension	MIME Type
Flash	.flv	video/x-flv
MPEG-4	.mp4	video/mp4
iPhone Index	.m3u8	application/x-mpegURL
iPhone Segment	.ts	video/MP2T
3GP Mobile	.3gp	video/3gpp
QuickTime	.mov	video/quicktime
A/V Interleave	.avi	video/x-msvideo
Windows Media	.wmv	video/x-ms-wmv


//---------------------------------------

[4 byte offset]
66 74 79 70 33 67 70	 	[4 byte offset]
ftyp3gp
3GG, 3GP, 3G2	 	3rd Generation Partnership Project 3GPP multimedia files

[4 byte offset]
66 74 79 70 4D 34 41 20	 	[4 byte offset]
ftypM4A
M4A	 	Apple Lossless Audio Codec file

[4 byte offset]
66 74 79 70 4D 34 56 20	 	[4 byte offset]
ftypM4V
FLV, M4V	 	ISO Media, MPEG v4 system, or iTunes AVC-LC file.

[4 byte offset]
66 74 79 70 4D 53 4E 56	 	[4 byte offset]
ftypMSNV
MP4	 	MPEG-4 video file

[4 byte offset]
66 74 79 70 69 73 6F 6D	 	[4 byte offset]
ftypisom
MP4	 	ISO Base Media file (MPEG-4) v1

[4 byte offset]
66 74 79 70 6D 70 34 32	 	[4 byte offset]
ftypmp42
M4V	 	MPEG-4 video|QuickTime file

[4 byte offset]
66 74 79 70 71 74 20 20	 	[4 byte offset]
ftypqt
MOV	 	QuickTime movie file

 */

- (NSString *)mimeType {

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
    return nil;
}



-(NSString *)suffix {

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


@implementation NSString (Addtion)

-(BOOL)isBlank{
    if([self length] == 0) { //string is empty or nil
        return YES;
    }
    return ![[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
}

-(BOOL)isNotBlank{
    NSString *trimStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [trimStr length] > 0;
}

-(BOOL)containsChineseCharacters{
    NSRange range = [self rangeOfString:@"\\p{Han}" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}

- (NSString *)subStringWithRegex:(NSString *)regexText matchIndex:(NSUInteger)index{
    __block NSString *text = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexText options:NSRegularExpressionCaseInsensitive error:nil];
    [regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, [self length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        if(match && match.range.length >= index){
            text = [self substringWithRange:[match rangeAtIndex:index]];
        }
    }];
    return text;
}

- (NSArray<NSString *> *)matchStringWithRegex:(NSString *)regexText{
    __block NSMutableArray *matchArr = @[].mutableCopy;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^&?]*?=[^&?]*)" options:NSRegularExpressionCaseInsensitive error:nil];
    [regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, [self length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        if(match && match.range.length > 0){
            NSString *text = [self substringWithRange:[match rangeAtIndex:0]];
            [matchArr addObject:text];
        }
    }];
    return matchArr;
}


@end

@implementation NSString (Base64)

-(NSString *)base64Encode{
    NSData *encodeData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return base64String;
}

-(NSString *)base64Decode{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

@end


@implementation UIResponder (Extension)

//获得指class类型的父视图
- (id)superViewWithClass:(Class)clazz {
    UIResponder *responder = self;
    while (![responder isKindOfClass:clazz]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return responder;
}


//打开指定url
- (void)openURLWithUrl:(NSURL *)url {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(openURL:)]) {
            [responder performSelector:@selector(openURL:) withObject:url];
        }
    }
}

//打开指定urlString
- (void)openURLWithString:(NSString *)urlString {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(openURL:)]) {
            [responder performSelector:@selector(openURL:) withObject:url];
        }
    }
}

//检查是否能打开指定urlString
- (BOOL)canOpenURLWithString:(NSString *)urlString {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(canOpenURL:)]) {
            NSNumber *result = [responder performSelector:@selector(canOpenURL:) withObject:url];
            return result.boolValue;
        }
    }
    return NO;
}

@end


@implementation UIColor (HexValue)

+ (UIColor *)colorWithRGBAString:(NSString *)RGBAString {
    UIColor *color = nil;

    NSArray *rgbaComponents = [RGBAString componentsSeparatedByString:@","];
    float RED = 0.0f;
    float GREEN = 0.0f;
    float BLUE = 0.0f;
    float ALPHA = 0.0f;

    //string like : 127,127,127
    if ([rgbaComponents count] == 3) {
        RED = [(NSString *) rgbaComponents[0] floatValue] / 255;
        GREEN = [(NSString *) rgbaComponents[1] floatValue] / 255;
        BLUE = [(NSString *) rgbaComponents[2] floatValue] / 255;

        color = [UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:1.0f];

        //string like : 127,127,127,255
    } else if ([rgbaComponents count] == 4) {
        RED = [(NSString *) rgbaComponents[0] floatValue] / 255;
        GREEN = [(NSString *) rgbaComponents[1] floatValue] / 255;
        BLUE = [(NSString *) rgbaComponents[2] floatValue] / 255;
        ALPHA = [(NSString *) rgbaComponents[3] floatValue] / 255;

        color = [UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:ALPHA];
    }

    return color;
}

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


+ (NSString *)hexValuesFromUIColor:(UIColor *)color {

    if (!color) {
        return nil;
    }

    if (color == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        return @"ffffff";
    }

    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;

    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    int redDec = (int) (red * 255);
    int greenDec = (int) (green * 255);
    int blueDec = (int) (blue * 255);

    NSString *returnString = [NSString stringWithFormat:@"%02x%02x%02x", (unsigned int) redDec, (unsigned int) greenDec, (unsigned int) blueDec];

    return returnString;

}

//从UIColor得到RGBA字符串
+ (NSString *)rgbaStringFromUIColor:(UIColor *)color {

    if (!color) {
        return nil;
    }

    if (color == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        return @"255,255,255,255";
    }

    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;

    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    int redDec = (int) (red * 255);
    int greenDec = (int) (green * 255);
    int blueDec = (int) (blue * 255);
    int alphaDec = (int) (alpha * 255);

    NSString *returnString = [NSString stringWithFormat:@"%d,%d,%d,%d", (unsigned int) redDec, (unsigned int) greenDec, (unsigned int) blueDec, (unsigned int) alphaDec];

    return returnString;

}

+ (UIColor *)colorWithHex:(uint)hex alpha:(CGFloat)alpha {
    int red, green, blue;

    blue = hex & 0x0000FF;
    green = ((hex & 0x00FF00) >> 8);
    red = ((hex & 0xFF0000) >> 16);

    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha];
}

- (NSString *)rgbHexString{
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);

    CGFloat r, g, b, a;

    if (colorSpace == kCGColorSpaceModelMonochrome) {
        r = components[0];
        g = components[0];
        b = components[0];
    }
    else if (colorSpace == kCGColorSpaceModelRGB) {
        r = components[0];
        g = components[1];
        b = components[2];
    }

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
                                      lroundf(r * 255),
                                      lroundf(g * 255),
                                      lroundf(b * 255)];
}

- (NSString *)rgbaHexString{
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);

    CGFloat r, g, b, a;

    if (colorSpace == kCGColorSpaceModelMonochrome) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[1];
    }
    else if (colorSpace == kCGColorSpaceModelRGB) {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
                                      lroundf(r * 255),
                                      lroundf(g * 255),
                                      lroundf(b * 255),
                                      lroundf(a * 255)];
}


@end


