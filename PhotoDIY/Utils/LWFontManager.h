//
// Created by Luo Wei on 2017/10/27.
// Copyright (c) 2017 wodedata. All rights reserved.
//
// 此文件中fontName 都约定为字体的 PostScript 名称

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "AppDelegate.h"

@class LWFontDownloadTask;

@interface LWFontManager : NSObject

//判断字体是否可用
+ (BOOL)isAvaliableFont:(NSString *)fontName;

//删除指定目录的文件
+ (BOOL)removeFileWithFilePath:(NSString *)filePath;

//写入数据到指定路径
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath;

//创建目录
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path;

//注册所有自定义的本地字体
+ (void)registerAllCustomLocalFonts;

//依fontName构建font
+ (UIFont *)fontWithFontName:(NSString *)fontName size:(CGFloat)size;

//使用字体
+ (void)useFontName:(NSString *)fontName size:(CGFloat)size useBlock:(void (^)(UIFont *font))useBlock;

//下载自定义的字体
+ (void)downloadCustomFontWithFontName:(NSString *)fontName URLString:(NSString *)urlString
                     showProgressBlock:(void (^)())showProgressBlock
                   updateProgressBlock:(void (^)(float progress))progressBlock
                         completeBlock:(void (^)())completeBlock;

//下载苹果提供的字体
+ (void)downloadAppleFontWithFontName:(NSString *)fontName
                    showProgressBlock:(void (^)())showProgressBlock
                  updateProgressBlock:(void (^)(float progress))progressBlock
                        completeBlock:(void (^)())completeBlock;

@end


@interface LWFontDownloadTask : NSObject

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic) NSUInteger taskIdentifier;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property(nonatomic) float progress;
@property(nonatomic) long long int downloadSize;
@property(nonatomic, strong) NSMutableData *dataToDownload;


+ (LWFontDownloadTask *)taskWithIdentifier:(NSUInteger)identifier
                                  fontName:(NSString *)fontName
                                  dataTask:(NSURLSessionDataTask *)task;

@end

#pragma mark - AppDelegate LoadFonts

@interface AppDelegate (LoadFonts)

@end

@interface UIFont (Swizzling)

@end

#pragma mark - Swizzling

@interface NSObject (LWSwizzling)

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel ;

+ (BOOL)swizzleClassMethod:(SEL)origSel withMethod:(SEL)altSel;

@end