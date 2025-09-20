//
//  Categorys.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Categorys : NSObject

@end


@interface UIView(Recursive)

-(id)superViewWithClass:(Class)clazz;

- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation;

-(void)didLayoutSubviews;

@end

@interface UIImage(ext)

- (UIImage *)imageWithOverlayColor:(UIColor *)color;

@end

@interface NSArray (Reverse)

- (NSArray *)reversedArray;

@end

@interface NSMutableArray (Reverse)

- (void)reverse;

@end


@interface NSString (Addtion)

-(BOOL)isBlank;

-(BOOL)isNotBlank;

-(BOOL)containsChineseCharacters;

- (NSString *)subStringWithRegex:(NSString *)regexText matchIndex:(NSUInteger)index;

- (NSArray<NSString *> *)matchStringWithRegex:(NSString *)regexText;

@end


@interface NSString(Match)

- (BOOL)isMatchString:(NSString *)pattern;

- (BOOL)isiTunesURL;

- (BOOL)isDomain;

- (BOOL)isHttpURL;

@end


@interface NSURL (Extension)


- (NSDictionary *)queryDictionary;
-(BOOL)urlIsImage;


@end


