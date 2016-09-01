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


