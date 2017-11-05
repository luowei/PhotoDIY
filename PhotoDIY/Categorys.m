//
//  Categorys.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "Categorys.h"

@implementation Categorys

@end


@implementation UIView(Recursive)

//获得指class类型的父视图
-(id)superViewWithClass:(Class)clazz{
    UIResponder *responder = self;
    while (![responder isKindOfClass:clazz]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return responder;
}

//递归的向子视图发送屏幕发生旋转了的消息
- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    for (UIView *v in self.subviews) {
        [v rotationToInterfaceOrientation:orientation];
    }
}

//VC的viewDidLayoutSubviews递归地往下调
-(void)didLayoutSubviews{

    for(UIView *v in self.subviews){
        [v didLayoutSubviews];
    }

}

@end


@implementation UIImage(ext)

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

@end


@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] <= 1)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];

        i++;
        j--;
    }
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


@implementation NSString (Match)


- (BOOL)isMatchString:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error) {
        return NO;
    }
    NSTextCheckingResult *res = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return res != nil;
}

- (BOOL)isiTunesURL {
    return [self isMatchString:@"\\/\\/itunes\\.apple\\.com\\/"];
}

//是否是域名
- (BOOL)isDomain {
    return [self isMatchString:@"^([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,6}$"]
            || [self isMatchString:@"^(www.|[a-zA-Z].)[a-zA-Z0-9\\-\\.]+\\.(com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk)(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\;\\?\\'\\\\\\+&amp;%\\$#\\=~_\\-]+))*$"];
}

//是否是网址
- (BOOL)isHttpURL {
    return [self isMatchString:@"(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"]
            || [self isMatchString:@"^(http|https|ftp)\\://([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)?((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.[a-zA-Z]{2,4})(\\:[0-9]+)?(/[^/][a-zA-Z0-9\\.\\,\\?\\'\\\\/\\+&amp;%\\$#\\=~_\\-@]*)*$"]
            || [self isMatchString:@"^(http|https|ftp)\\://([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\?\\'\\\\\\+&amp;%\\$#\\=~_\\-]+))*$"];
}

@end


@implementation NSURL (Extension)

- (NSDictionary *)queryDictionary {
    NSMutableDictionary *queryStrings = @{}.mutableCopy;
    for (NSString *qs in [self.query componentsSeparatedByString:@"&"]) {
        // Get the parameter name
        NSString *key = [qs componentsSeparatedByString:@"="][0];
        // Get the parameter value
        NSString *value = [qs componentsSeparatedByString:@"="][1];
        //value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        queryStrings[key] = value;
    }
    return queryStrings;
}

-(BOOL)urlIsImage {
    NSMutableURLRequest *request = [[NSURLRequest requestWithURL:self] mutableCopy];
    NSURLResponse *response = nil;
    NSError *error = nil;
    [request setValue:@"HEAD" forKey:@"HTTPMethod"];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *mimeType = [response MIMEType];
    if(!mimeType){
        return false;
    }
    NSRange range = [mimeType rangeOfString:@"image"];
    return (range.location != NSNotFound);
}

@end






