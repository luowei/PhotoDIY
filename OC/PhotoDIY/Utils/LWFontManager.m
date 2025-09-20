//
// Created by Luo Wei on 2017/10/27.
// Copyright (c) 2017 wodedata. All rights reserved.
//
// 此文件中fontName 都约定为字体的 PostScript名称

#import "LWFontManager.h"

@interface LWFontManager () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSString *fontDirectoryPath;
@property (nonatomic, strong) NSMutableDictionary <NSString *,NSString *>*appleFontPathDict;
@property(nonatomic, strong) NSMutableDictionary <NSString *,LWFontDownloadTask *>*fontTaskDict;
@property(nonatomic, strong) NSMutableDictionary <NSString *,LWFontDownloadTask *>*taskDict;

@property(nonatomic, strong) NSURLSessionDataTask *curretnDataTask;

@property(nonatomic, copy) void (^showProgressBlock)(); //显示进度条表示真实开始下截
@property(nonatomic, copy) void (^updateProgessBlock)(float);  //更新下载进度及进度条
@property(nonatomic, copy) void (^completeBlock)(); //完成下载

@end

#define Key_AppleFontPathData @"Key_AppleFontPathData"

@implementation LWFontManager {

}

static LWFontManager *_instance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];

        _instance.fontTaskDict = @{}.mutableCopy;
        _instance.taskDict = @{}.mutableCopy;

        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:Key_AppleFontPathData];
        if(!data){
            _instance.appleFontPathDict = @{}.mutableCopy;
        }else{
            NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if(dict){
                _instance.appleFontPathDict = [dict mutableCopy];
            }else{
                _instance.appleFontPathDict = @{}.mutableCopy;
            }
        }
    });
    return _instance;
}

- (NSString *)fontDirectoryPath {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    _fontDirectoryPath = [documentsDirectory stringByAppendingPathComponent:@"fonts"];

    [LWFontManager createDirectoryIfNotExsitPath:_fontDirectoryPath];   //创建目录

    NSLog(@"======fontDirectoryPath:%@",_fontDirectoryPath);
    NSLog(@"======App Bundle Path:%@",[[NSBundle mainBundle] bundlePath]);
    NSLog(@"======Home Path:%@",NSHomeDirectory());

    return _fontDirectoryPath;
}

//判断字体是否可用
+ (BOOL)isAvaliableFont:(NSString *)fontName {
    UIFont *aFont = [UIFont fontWithName:fontName size:12.f];
    return aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame);
}

//删除指定目录的文件
+ (BOOL)removeFileWithFilePath:(NSString *)filePath {
    //把文件删除
    NSError *err = nil;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
    if(err){
        NSLog(@"Error! %@", err);
    }
    return result;
}

//写入数据到指定路径
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath {
    BOOL result = [data writeToFile:filePath atomically:YES];  //写入到文件
    NSLog(@"=======font writeToFile:%@",(result ? @"YES" : @"NO"));

//            NSError *error = nil;
//            BOOL success = [fontTask.dataToDownload writeToFile:fontPath options:0 error:&error];
//            if (!success) {
//                NSLog(@"writeToFile failed with error %@", error);
//            }
    return result;
}

//创建目录
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path {
    BOOL success = YES;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){  //如果则创建文件夹
        NSError * error = nil;
        success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success || error) {
            NSLog(@"Error! %@", error);
        } else {
            NSLog(@"Create fonts directory Success!");
        }
    }
    return success;
}


//是否存在fontFileName
+ (BOOL)exsitCustomFontFileWithFontName:(NSString *)fontName {
    LWFontManager *sef = [LWFontManager shareInstance];
    NSString *fontPath = [sef.fontDirectoryPath stringByAppendingPathComponent:fontName];
    BOOL exsit = [[NSFileManager defaultManager] fileExistsAtPath:fontPath];
    return exsit;
}

//依fontName构建font
+ (UIFont *)fontWithFontName:(NSString *)fontName size:(CGFloat)size{
    if ([LWFontManager isAvaliableFont:fontName]) {
        return [UIFont fontWithName:fontName size:size];
    }
    return nil;
}

//使用字体
+ (void)useFontName:(NSString *)fontName size:(CGFloat)size useBlock:(void (^)(UIFont *font))useBlock{
    UIFont *font = [LWFontManager fontWithFontName:fontName size:size];
    if(!font){
        [LWFontManager userApppleFontWithFontName:fontName size:size
                                 matchedFontBlock:^(UIFont *fnt) {
                                     if(fnt && useBlock){
                                         useBlock(fnt);
                                     }else{
                                         useBlock(nil);
                                     }
                                 }];
    }else{
        useBlock(font);
    }
}



//下载自定义的字体
+ (void)downloadCustomFontWithFontName:(NSString *)fontName URLString:(NSString *)urlString
                     showProgressBlock:(void (^)())showProgressBlock
                   updateProgressBlock:(void (^)(float progress))progressBlock
                         completeBlock:(void (^)())completeBlock {
    LWFontManager *sef = [LWFontManager shareInstance];

    sef.showProgressBlock = showProgressBlock;
    sef.updateProgessBlock = progressBlock;
    sef.completeBlock = completeBlock;
    [LWFontManager downloadCustomFontWithFontName:fontName URLString:urlString];
}

//下载自定义的字体
+ (void)downloadCustomFontWithFontName:(NSString *)fontName URLString:(NSString *)urlString {
    LWFontManager *sef = [LWFontManager shareInstance];
    if ([LWFontManager isAvaliableFont:fontName]) {   //字体可用
        //更新UI
        if(sef.updateProgessBlock){
            sef.updateProgessBlock(1.0f);
        }
        if(sef.completeBlock){
            sef.completeBlock();
        }
        return;
    }

    BOOL exsit = [LWFontManager exsitCustomFontFileWithFontName:fontName];
    if (exsit) {  //如果已经下载过了
        if (![LWFontManager isAvaliableFont:fontName]) {   //检查字体是否可用
            NSString *fontPath = [sef.fontDirectoryPath stringByAppendingPathComponent:fontName];
            [LWFontManager registerFont:fontPath];
        }
        //更新UI
        if(sef.updateProgessBlock){
            sef.updateProgessBlock(1.0f);
        }
        if(sef.completeBlock){
            sef.completeBlock();
        }
        return;
    }

    //构造NSURLSession
    //urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"http://app.wodedata.com" forHTTPHeaderField:@"Referer"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:sef
                                                            delegateQueue:[NSOperationQueue mainQueue]];

    if(sef.curretnDataTask && sef.curretnDataTask.state == NSURLSessionTaskStateRunning){   //取消原来的任务
        [sef.curretnDataTask cancel];
    }
    sef.curretnDataTask = [defaultSession dataTaskWithRequest:request];
    [sef.curretnDataTask resume];

    LWFontDownloadTask *fontTask = [LWFontDownloadTask taskWithIdentifier:sef.curretnDataTask.taskIdentifier fontName:fontName dataTask:sef.curretnDataTask];
    sef.fontTaskDict[fontName] = fontTask;
    sef.taskDict[[@(sef.curretnDataTask.taskIdentifier) stringValue]] = fontTask;
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"--------%d:%s \n", __LINE__, __func__);
    completionHandler(NSURLSessionResponseAllow);

    LWFontDownloadTask *fontTask = self.taskDict[[@(dataTask.taskIdentifier) stringValue]];
    fontTask.progress = 0.0f;
    fontTask.downloadSize = [response expectedContentLength];
    fontTask.dataToDownload = [[NSMutableData alloc] init];

    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.showProgressBlock){ //显示下载进度提示,开始显示下载进度
            self.showProgressBlock();
        }
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"--------%d:%s \n", __LINE__, __func__);
    LWFontDownloadTask *fontTask = self.taskDict[[@(dataTask.taskIdentifier) stringValue]];
    if(!fontTask){
        return;
    }

    [fontTask.dataToDownload appendData:data];
    fontTask.progress = (float) [fontTask.dataToDownload length] / fontTask.downloadSize;
    NSLog(@"=======progress:%.4f, dataToDownload:%lli, downloadSize:%lli", fontTask.progress, (long long int) fontTask.dataToDownload.length, fontTask.downloadSize);

    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.updateProgessBlock){
            self.updateProgessBlock(fontTask.progress >=1 ? 1 : fontTask.progress);
        }

        if (fontTask.progress >= 1) { //下载完成
            self.updateProgessBlock(1);

            NSString *fontPath = [self.fontDirectoryPath stringByAppendingPathComponent:fontTask.fontName];

            [LWFontManager writeData:fontTask.dataToDownload toFilePath:fontPath];

            [LWFontManager registerFont:fontPath];  //注册字体文件
            //更新UI
            if (self.completeBlock) {
                if([LWFontManager isAvaliableFont:fontTask.fontName]){
                    self.completeBlock();
                }else{
                    NSLog(@"=====font %@ is Unavaliable",fontTask.fontName);
                }
            }
        }
    });
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"--------%d:%s \n", __LINE__, __func__);
    NSLog(@"=====completed; error: %@", error);
}


//注册指定路径下的字体文件
+ (void)registerFont:(NSString *)fontPath {
    NSData *dynamicFontData = [NSData dataWithContentsOfFile:fontPath];
    if (!dynamicFontData) {
        return;
    }
    CFErrorRef error;
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef) dynamicFontData);
    CGFontRef font = CGFontCreateWithDataProvider(providerRef);
    if(!font){
        [LWFontManager removeFileWithFilePath:fontPath]; //删除文件
        CFRelease(providerRef);
        return;
    }
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        //注册失败
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(providerRef);
}

/*
 经测试注册过的字体在应用关闭后下次开启应用，
 判断字体是否加载时返回为NO，为了保证正常
 使用需要每次启动应用的时候先遍历一遍字体
 文件夹将里面的字体文件都再次注册一遍即可
 * */
+ (void)registerAllCustomLocalFonts {
    LWFontManager *sef = [LWFontManager shareInstance];

    //注册fonts目录下面的所有字体文件
    NSArray *fontFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sef.fontDirectoryPath error:nil];
    for (NSString *fontFileName in fontFiles) {
        NSString *fontPath = [sef.fontDirectoryPath stringByAppendingPathComponent:fontFileName];
        [LWFontManager registerFont:fontPath];
    }

//    //注册苹果的字体(这里苹果的字体不在沙盒目录，无法注册)
//    for(NSString *fontPath in sef.appleFontPathes){
//        [LWFontManager registerFont:fontPath];
//    }
}


#pragma mark - 动态下载苹果提供的字体

/*
 参考：http://blog.devzeng.com/blog/using-custom-font-in-ios.html
 官方提供的示例代码：https://developer.apple.com/library/ios/samplecode/DownloadFont/Introduction/Intro.html
 */


//使用苹果字体
+(void)userApppleFontWithFontName:(NSString *)fontName size:(CGFloat)size
                 matchedFontBlock:(void (^)(UIFont *font))matchedFontBlock {
    LWFontManager *sef = [LWFontManager shareInstance];

    //如果没有下载过
    if (sef.appleFontPathDict[fontName] == nil) {
        if(matchedFontBlock){
            matchedFontBlock(nil);
        }
        return;
    }

    // 用字体的 PostScript 名字创建一个 Dictionary
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName, kCTFontNameAttribute, nil];
    // 创建一个字体描述对象 CTFontDescriptorRef
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef) attrs);
    // 将字体描述对象放到一个 NSMutableArray 中
    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id) desc];
    CFRelease(desc);
    __block BOOL errorDuringDownload = NO;


    //匹配字体
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef) descs, NULL,
            ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef _Nonnull progressParameter) {

                if (state == kCTFontDescriptorMatchingDidFinish) {//匹配字体
                    if (!errorDuringDownload) {

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(matchedFontBlock){
                                UIFont *font = [UIFont fontWithName:fontName size:size];
                                matchedFontBlock(font ?: nil);
                            }
                        });

                    }
                }
                return (BOOL) YES;
            });
}

//下载苹果提供的字体
+ (void)downloadAppleFontWithFontName:(NSString *)fontName
                    showProgressBlock:(void (^)())showProgressBlock
                  updateProgressBlock:(void (^)(float progress))progressBlock
                        completeBlock:(void (^)())completeBlock {
    LWFontManager *sef = [LWFontManager shareInstance];

    sef.showProgressBlock = showProgressBlock;
    sef.updateProgessBlock = progressBlock;
    sef.completeBlock = completeBlock;
    [LWFontManager downloadAppleFontWithFontName:fontName];
}

//下载苹果提供的字体
+ (void)downloadAppleFontWithFontName:(NSString *)fontName {
    LWFontManager *sef = [LWFontManager shareInstance];

    if ([LWFontManager isAvaliableFont:fontName]) {   //字体可用
        //更新UI
        if(sef.updateProgessBlock){
            sef.updateProgessBlock(1.0f);
        }
        if(sef.completeBlock){
            sef.completeBlock();
        }
        return;
    }

    //使用字体的PostScript名称构建一个字典
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName, kCTFontNameAttribute, nil];
    //根据上面的字典创建一个字体描述对象
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef) attrs);
    //将字体描述对象放到一个数组中
    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id) desc];
    CFRelease(desc);

    //下载字体文件
    __block BOOL errorDuringDownload = NO;
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef) descs, NULL, ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        //下载的进度
        double progressValue = [((__bridge NSDictionary *) progressParameter)[(id) kCTFontDescriptorMatchingPercentage] doubleValue];
        switch (state){
            case kCTFontDescriptorMatchingDidBegin:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //开始匹配
                    NSLog(@"Begin Matching");
                });
                break;
            }
            case kCTFontDescriptorMatchingDidFinish:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!errorDuringDownload) {
                        //字体下载完成
                        NSLog(@"%@ MatchingDidFinish", fontName);
                        if(sef.updateProgessBlock){
                            sef.updateProgessBlock(1.0f);
                        }
                        if(sef.completeBlock){ //修改UI控件的字体样式
                            if([LWFontManager isAvaliableFont:fontName]){
                                //注册苹果字体并保存路径(苹果的字体不在沙盒目录，无法注册)
                                [self saveAppleFontPathWithFontName:fontName];

                                sef.completeBlock();
                            }else{
                                NSLog(@"=====font %@ is Unavaliable",fontName);
                            }
                        }

                    }
                });
                break;
            }
            case kCTFontDescriptorMatchingWillBeginDownloading:{
                //开始下载
                NSLog(@"Begin Downloading");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(sef.showProgressBlock){ //显示下载进度提示,开始显示下载进度
                        sef.showProgressBlock();
                    }
                });
                break;
            }
            case kCTFontDescriptorMatchingDidFinishDownloading:{
                //下载完成
                NSLog(@"Finish downloading");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(sef.updateProgessBlock){
                        sef.updateProgessBlock(1.0f);
                    }
                    if(sef.completeBlock){ //修改UI控件的字体样式
                        if([LWFontManager isAvaliableFont:fontName]){
                            sef.completeBlock();
                        }else{
                            NSLog(@"=====font %@ is Unavaliable",fontName);
                        }

                    }
                });
                break;
            }
            case kCTFontDescriptorMatchingDownloading:{
                //正在下载
                NSLog(@"Downloading %.0f%% complete", progressValue);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(sef.updateProgessBlock){  //修改下载进度条的数值
                        sef.updateProgessBlock((float) (progressValue/100));
                    }
                });
                break;
            }
            case kCTFontDescriptorMatchingDidFailWithError:{
                //下载遇到错误，获取错误信息
                NSError *error = ((__bridge NSDictionary *) progressParameter)[(id) kCTFontDescriptorMatchingError];
                NSLog(@"%@", [error localizedDescription]);
                //设置下载错误标志
                errorDuringDownload = YES;
                break;
            }
            default:{
                break;
            }
        }
        return (bool) YES;
    });
}

//注册苹果字体并保存路径(这里苹果的字体不在沙盒目录，无法注册)
+ (void)saveAppleFontPathWithFontName:(NSString *)fontName{
    LWFontManager *sef = [LWFontManager shareInstance];

    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0., NULL);
    CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
    NSURL *fontPathURL = (__bridge NSURL*)(fontURL);
    NSLog(@"====Apple Font URL:%@", fontPathURL.path);

    //把苹果的字体路径保存起来
    sef.appleFontPathDict[fontName] = fontPathURL.path;
//    [LWFontManager registerFont:fontPathURL.path];  //注册字体

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sef.appleFontPathDict];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:Key_AppleFontPathData];
    [[NSUserDefaults standardUserDefaults] synchronize];

    CFRelease(fontURL);
    CFRelease(fontRef);
}


@end


@implementation LWFontDownloadTask

+ (LWFontDownloadTask *)taskWithIdentifier:(NSUInteger)identifier
                                  fontName:(NSString *)fontName
                                  dataTask:(NSURLSessionDataTask *)dataTask {
    LWFontDownloadTask *task = [LWFontDownloadTask new];
    task.taskIdentifier = identifier;
    task.fontName = fontName;
    task.dataTask = dataTask;

    return task;
}


@end


#pragma mark - AppDelegate LoadFonts

@implementation AppDelegate (LoadFonts)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(application: didFinishLaunchingWithOptions:) withMethod:@selector(myApplication: didFinishLaunchingWithOptions:)];
    });
}

- (BOOL)myApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

    BOOL result = YES;
    if(application){
        result = [self myApplication:application didFinishLaunchingWithOptions:launchOptions];
        //注册所有本地字体
        [LWFontManager registerAllCustomLocalFonts];
    }
    return result;
}

@end

@implementation UIFont (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIFont swizzleClassMethod:@selector(fontWithName: size:) withMethod:@selector(myFontWithName: size:)];
    });
}

+ (UIFont *)myFontWithName:(NSString *)fontName size:(CGFloat)fontSize{
    UIFont *font = nil;
    if(fontSize > 0){
        UIFont *aFont = [UIFont myFontWithName:fontName size:12.f];
        BOOL isAvaliable = aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame);

        if(fontName && isAvaliable){
            font = [UIFont myFontWithName:fontName size:fontSize];
        }else{
            font = [UIFont myFontWithName:@"Helvetica" size:fontSize];
        }
    }
    return font;
}

@end

#pragma mark - Swizzling

#import <objc/runtime.h>

@implementation NSObject (LWSwizzling)

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel {
    Method origMethod = class_getInstanceMethod(self, origSel);
    Method altMethod = class_getInstanceMethod(self, altSel);
    if (!origMethod || !altMethod) {
        return NO;
    }
    class_addMethod(self,origSel,class_getMethodImplementation(self, origSel),method_getTypeEncoding(origMethod));
    class_addMethod(self,altSel,class_getMethodImplementation(self, altSel),method_getTypeEncoding(altMethod));
    method_exchangeImplementations(class_getInstanceMethod(self, origSel),class_getInstanceMethod(self, altSel));
    return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)origSel withMethod:(SEL)altSel {
    return [object_getClass((id)self) swizzleMethod:origSel withMethod:altSel];
}

@end
