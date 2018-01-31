//
//  ShareNavigationViewController.m
//  LWShareExtension
//
//  Created by Luo Wei on 2018/2/1.
//  Copyright © 2018年 wodedata. All rights reserved.
//

#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <PhotosUI/PhotosUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShareNavigationViewController.h"
#import "FLAnimatedImageView.h"
#import "Masonry.h"
#import "ShareDefines.h"
#import "LWMyUtils.h"
#import "FLAnimatedImage.h"
#import "ShareCategories.h"

@interface ShareNavigationViewController ()

@end

@implementation ShareNavigationViewController


- (instancetype)init {
    LWShareViewController *vc = [LWShareViewController new];
    self = [super initWithRootViewController:vc];
    if (self) {

    }

    return self;
}

@end



@implementation LWShareViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    Log(@"=============收到内存使用超限警告");
}


- (void)viewDidLoad {
    [super viewDidLoad];

//    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//            initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];

    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor darkTextColor]};

    //设置NavigationBar为透明，自定义返回按钮
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.tintColor = [UIColor darkTextColor];

    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    //修改箭头图案
    UIImage *backBtnImage = [UIImage imageNamed:@"TitleIcon_Left"];
    [self.navigationController.navigationBar setBackIndicatorImage:backBtnImage];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:backBtnImage];


    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.leading.equalTo(self.view.mas_leading).offset(20);
        make.trailing.equalTo(self.view.mas_trailing).offset(-20);
        make.height.mas_equalTo(240);
    }];
    self.containerView.layer.cornerRadius = 3.0f;
    self.containerView.clipsToBounds = YES;
    self.containerView.backgroundColor = [UIColor whiteColor];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.containerView addSubview:self.titleLabel];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = NSLocalizedString(@"Import PhotoDIY", nil);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#7C7C7C"];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(20);
        make.centerX.equalTo(self.containerView);
    }];

    self.topLine = [[UIView alloc] initWithFrame:CGRectZero];
    [self.containerView addSubview:self.topLine];
    self.topLine.backgroundColor = [[UIColor colorWithHexString:@"#7C7C7C"] colorWithAlphaComponent:0.5];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.containerView);
        make.top.equalTo(self.containerView).offset(48.5);
        make.height.mas_equalTo(0.5);
    }];

    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [self.containerView addSubview:self.textView];
    self.textView.editable = NO;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.textColor = [UIColor colorWithHexString:@"#7C7C7C"];
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.contentInset = UIEdgeInsetsMake(6, 10, 6, 10);
    self.textView.contentSize = CGSizeMake(self.textView.frame.size.height - 20, self.textView.contentSize.height);
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView).with.insets(UIEdgeInsetsMake(50, 0, 50, 0));
    }];
    self.textView.text = @"";
    self.textView.hidden = YES;

    self.imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectZero];
    [self.containerView addSubview:self.imageView];
    self.imageView.layer.cornerRadius = 5;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView).with.insets(UIEdgeInsetsMake(50, 0, 50, 0));
    }];

    //LiveView视图
    self.liveView = [[PHLivePhotoView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.liveView];

    [self.liveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView).with.insets(UIEdgeInsetsMake(50, 0, 50, 0));
    }];
    self.liveView.hidden = YES;

    self.livePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.containerView addSubview:self.livePhotoBtn];
    self.livePhotoBtn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    self.livePhotoBtn.layer.cornerRadius = 5;
    [self.livePhotoBtn setImage:[UIImage imageNamed:@"livephoto"] forState:UIControlStateNormal];
    [self.livePhotoBtn addTarget:self action:@selector(livePhotoBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.livePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.imageView.mas_left).offset(4);
        make.top.equalTo(self.imageView.mas_top).offset(4);
    }];
    self.livePhotoBtn.hidden = YES;

    self.bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
    [self.containerView addSubview:self.bottomLine];
    self.bottomLine.backgroundColor = [[UIColor colorWithHexString:@"#7C7C7C"] colorWithAlphaComponent:0.5];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView).offset(-50);
        make.height.mas_equalTo(0.5);
    }];

    self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.containerView addSubview:self.okButton];
    [self.okButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.okButton addTarget:self action:@selector(okButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.okButton setTitleColor:[UIColor colorWithHexString:@"#4DC7FE"] forState:UIControlStateNormal];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.containerView);
        make.top.equalTo(self.bottomLine.mas_bottom).offset(1);
    }];


    //获取数据及内容

    for (NSExtensionItem *eItem in self.extensionContext.inputItems) {

        for (NSItemProvider *itemProvider in eItem.attachments) {

            if (itemProvider) {
                NSArray *registeredTypeIdentifiers = itemProvider.registeredTypeIdentifiers;
                NSLog(@"====registeredTypeIdentifiers: %@ \n first typeIdentifier:%@", registeredTypeIdentifiers, registeredTypeIdentifiers.firstObject);
            }

            //word,pages,numbers,excel等文档
            void (^wordCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item) {
                if ([(NSObject *) item isKindOfClass:[NSURL class]]) {
                    self.liveView.hidden = YES;
                    self.imageView.hidden = YES;
                    self.textView.hidden = NO;

                    NSURL *wordFileUrl = (NSURL *) item;
                    NSString *absolutePath = wordFileUrl.path;
                    NSString *fileName = [absolutePath subStringWithRegex:@".*/([^/]*)$" matchIndex:1];
                    self.textView.text = fileName;

                    UIWebView *theWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
                    NSURLRequest *request = [NSURLRequest requestWithURL:wordFileUrl];
                    [theWebView loadRequest:request];
                    theWebView.delegate = self;
                    [self.view addSubview:theWebView];

                    self.okButton.enabled = NO;
                    [self.okButton setTitle:@"Loading..." forState:UIControlStateNormal];
                }
            };
            NSArray *wordIdentifers = @[
                    @"public.html",
                    @"com.apple.iwork.pages.sffpages",
                    @"org.openxmlformats.wordprocessingml.document",
                    @"com.microsoft.word.doc",
                    @"public.rtf",
                    @"com.apple.iwork.numbers.sffnumbers",
                    @"org.openxmlformats.spreadsheetml.sheet",
                    @"com.microsoft.excel.xls",
                    @"public.comma-separated-values-text",
                    @"com.apple.iwork.keynote.sffkey",
                    @"org.openxmlformats.presentationml.presentation",
                    @"com.microsoft.powerpoint.ppt"];
            if([self loadItemProvider:itemProvider withIdentifier:wordIdentifers completionBlock:wordCompletionBlock]){
                return;
            }


            //文件 public.file-url
            void (^fileCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){
                self.liveView.hidden = YES;
                self.imageView.hidden = YES;
                self.textView.hidden = NO;

                if ([(NSObject *) item isKindOfClass:[NSURL class]]) {
                    NSString *absolutePath = ((NSURL *) item).path;
                    NSString *fileName = [absolutePath subStringWithRegex:@".*/([^/]*)$" matchIndex:1];
                    self.textView.text = fileName;

                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:absolutePath];
                    NSString *mimeType = [data mimeType];

                    if ([mimeType isEqualToString:@"text/plain"]) {  //文本
                        //[[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"public.plain-text "];
                        NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        self.textView.text = [fileName stringByAppendingFormat:@"\n%@", contents];

                    } else if ([mimeType hasPrefix:@"image"]) {
                        [self expandContainerViewFrameWithVerticelPadding:150];    //扩大ContainerView
                        [self.textView removeFromSuperview];
                        self.liveView.hidden = YES;
                        self.imageView.hidden = NO;
                        if ([mimeType isEqualToString:@"image/gif"]) {
                            self.imageView.image = nil;
                            self.imageView.animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
                        } else {
                            self.imageView.image = [UIImage imageWithData:data];
                        }

                    } else {
                        self.textView.text = NSLocalizedString(@"Share Data", nil);
                    }
                }
            };
            NSArray *fileIdentifers = @[@"public.file-url"];    //kUTTypeFileURL
            if([self loadItemProvider:itemProvider withIdentifier:fileIdentifers completionBlock:fileCompletionBlock]){
                return;
            }


            //链接
            void (^urlCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){
                self.liveView.hidden = YES;
                self.imageView.hidden = YES;
                self.textView.hidden = NO;
                if ([(NSObject *) item isKindOfClass:[NSURL class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.textView.text = ((NSURL *) item).absoluteString;
                    });
                } else {
                    self.textView.text = NSLocalizedString(@"Share Data", nil);
                }
            };
            NSArray *urlIdentifers = @[@"public.url"];  //kUTTypeURL
            if([self loadItemProvider:itemProvider withIdentifier:urlIdentifers completionBlock:urlCompletionBlock]){
                return;
            }


            //文本public.text
            void (^textCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){
                [self.liveView removeFromSuperview];
                [self.imageView removeFromSuperview];
                self.textView.hidden = NO;
                if ([(NSObject *) item isKindOfClass:[NSString class]]) {
                    NSString *text = (NSString *) item;
                    if (text.length > 5000) {
                        text = [[text substringToIndex:5000] stringByAppendingString:@"..."];
                    }
                    self.textView.text = text;
                } else if ([(NSObject *) item isKindOfClass:[NSData class]]) {
                    NSData *data = (NSData *) item;
                    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if (text.length > 5000) {
                        text = [[text substringToIndex:5000] stringByAppendingString:@"..."];
                    }
                    self.textView.text = text;
                } else {
                    self.textView.text = NSLocalizedString(@"Share Data", nil);
                }
            };
            NSArray *textIdentifers = @[@"public.text"];    //kUTTypeText
            if([self loadItemProvider:itemProvider withIdentifier:textIdentifers completionBlock:textCompletionBlock]){
                return;
            }


            //图片
            void (^imageCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){
                [self expandContainerViewFrameWithVerticelPadding:150];    //扩大ContainerView
                [self.textView removeFromSuperview];
                self.liveView.hidden = YES;
                self.imageView.hidden = NO;
                NSData *data = nil;
                if ([(NSObject *) item isKindOfClass:[UIImage class]]) {
                    data = UIImagePNGRepresentation(item);
                } else if ([(NSObject *) item isKindOfClass:[NSData class]]) {
                    data = (NSData *) item;
                } else if ([(NSObject *) item isKindOfClass:[NSURL class]]) {   //路径
                    data = [NSData dataWithContentsOfURL:(NSURL *) item];
                }
                NSString *mimeType = [data mimeType];

                if ([mimeType isEqualToString:@"image/gif"]) {  //kUTTypeGIF
                    self.imageView.image = nil;
                    self.imageView.animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
                } else {
                    self.imageView.image = [UIImage imageWithData:data];
                }

            };
            NSArray *imageIdentifers = @[@"public.image"];  //kUTTypeImage
            if([self loadItemProvider:itemProvider withIdentifier:imageIdentifers completionBlock:imageCompletionBlock]){
                return;
            }


            //其他 data & content
            void (^otherCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){
                [self.liveView removeFromSuperview];
                self.imageView.hidden = YES;
                self.textView.hidden = NO;
                NSString *fileName = [((NSURL *) item).path subStringWithRegex:@".*/([^/]*)$" matchIndex:1];
                self.textView.text = fileName ?: NSLocalizedString(@"Share Data", nil);
            };
            NSArray *otherIdentifers = @[@"public.data",@"public.content",@"public.item"@"public.database",
                    @"public.calendar-event",@"public.message",@"public.contact",@"public.archive"];
            if([self loadItemProvider:itemProvider withIdentifier:otherIdentifers completionBlock:otherCompletionBlock]){
                return;
            }

        }//第二层for
    }//第一层for

}

//点击了livephoto按钮
- (void)livePhotoBtnAction {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    //@[(NSString *) kUTTypeLivePhoto,(NSString *)kUTTypeGIF];
    imagePicker.mediaTypes = @[@"public.image",@"com.apple.live-photo"];
    [self presentViewController:imagePicker animated:YES completion:nil];
    return;
}


- (void)okButtonAction {

    if(self.isPickerImage){
        [self handleData:self.imageData eItem:nil]; //处理NSData
        //执行分享内容处理
        [self.extensionContext completeRequestReturningItems:@[self.imageData] completionHandler:nil];
        return;
    }

    for (NSExtensionItem *eItem in self.extensionContext.inputItems) {

        for (NSItemProvider *itemProvider in eItem.attachments) {

            if (@available(iOS 9.1, *)) {   //如果是livePhoto,处理livePhoto
                if ([itemProvider hasItemConformingToTypeIdentifier:@"com.apple.live-photo"] && self.isLivePhoto){
                    [self handleLivePhoto:self.liveView.livePhoto];
                    //执行分享内容处理
                    [self.extensionContext completeRequestReturningItems:@[eItem] completionHandler:nil];
                    return;
                }
            }

            //文件 public.file-url
            void (^fileCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){
                if ([(NSObject *) item isKindOfClass:[NSURL class]]) {
                    NSString *absolutePath = ((NSURL *) item).path;

                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:absolutePath];
                    NSURL *groupPathURL = [LWMyUtils URLWithGroupName:Share_Group];
                    NSString *fileName = [absolutePath subStringWithRegex:@".*/([^/]*)$" matchIndex:1];
                    NSURL *groupFileURL = [groupPathURL URLByAppendingPathComponent:fileName];

                    BOOL isSuccess = [data writeToURL:groupFileURL atomically:YES];

                    //打开宿主App
                    NSString *subURLText = [groupFileURL.path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    NSString *urlString = [NSString stringWithFormat:@"%@://share.file?from=native&url=%@", Share_Scheme, subURLText];
                    [self openURLWithString:urlString];

                    //执行分享内容处理
                    [self.extensionContext completeRequestReturningItems:@[eItem] completionHandler:nil];
                }
            };
            NSArray *fileIdentifers = @[@"public.file-url"];
            if([self loadItemProvider:itemProvider withIdentifier:fileIdentifers completionBlock:fileCompletionBlock]){
                return;
            }


            //链接
            void (^urlCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item) {
                if ([(NSObject *) item isKindOfClass:[NSURL class]]) {
                    NSURL *url = ((NSURL *) item);
                    //NSCharacterSet *cSet = [NSCharacterSet characterSetWithCharactersInString:@"'();:@&=+$,/?%#[]"];
                    NSString *subURLText = [url.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    NSString *urlString = [NSString stringWithFormat:@"%@://share.http?from=native&url=%@", Share_Scheme, subURLText];
                    [self openURLWithString:urlString];

                    //执行分享内容处理
                    [self.extensionContext completeRequestReturningItems:@[eItem] completionHandler:nil];
                }
            };
            NSArray *urlIdentifers = @[@"public.url"];
            if([self loadItemProvider:itemProvider withIdentifier:urlIdentifers completionBlock:urlCompletionBlock]){
                return;
            }


            //文本public.text
            void (^textCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){
                //执行分享内容处理
                [self.extensionContext completeRequestReturningItems:@[eItem] completionHandler:nil];
            };
            NSArray *textIdentifers = @[@"public.text"];
            if([self loadItemProvider:itemProvider withIdentifier:textIdentifers completionBlock:textCompletionBlock]){
                return;
            }


            //图片
            void (^imageCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){

                NSData *data = nil;
                if ([(NSObject *) item isKindOfClass:[UIImage class]]) {
                    data = UIImagePNGRepresentation(item);
                } else if ([(NSObject *) item isKindOfClass:[NSData class]]) {
                    data = (NSData *) item;
                } else if ([(NSObject *) item isKindOfClass:[NSURL class]]) {   //路径
                    data = [NSData dataWithContentsOfURL:(NSURL *) item];
                }

                [self handleData:data eItem:eItem]; //处理NSData

                //执行分享内容处理
                [self.extensionContext completeRequestReturningItems:@[eItem] completionHandler:nil];
            };
            NSArray *imageIdentifers = @[@"public.image"];
            if([self loadItemProvider:itemProvider withIdentifier:imageIdentifers completionBlock:imageCompletionBlock]){
                return;
            }


            //其他 data & content
            void (^otherCompletionBlock)(id <NSSecureCoding>) = ^(id <NSSecureCoding> item){
                NSData *data = nil;
                if ([(NSObject *) item isKindOfClass:[NSData class]]) {
                    data = (NSData *) item;
                } else if ([(NSObject *) item isKindOfClass:[NSURL class]]) {   //路径
                    data = [NSData dataWithContentsOfURL:(NSURL *) item];
                }

                [self handleData:data eItem:eItem]; //处理NSData
                //执行分享内容处理
                [self.extensionContext completeRequestReturningItems:@[eItem] completionHandler:nil];
            };
            NSArray *otherIdentifers = @[@"public.data",@"public.content",@"public.item"@"public.database",
                    @"public.calendar-event",@"public.message",@"public.contact",@"public.archive"];
            if([self loadItemProvider:itemProvider withIdentifier:otherIdentifers completionBlock:otherCompletionBlock]){
                return;
            }


        }//第二层for

        //执行分享内容处理
        [self.extensionContext completeRequestReturningItems:@[eItem] completionHandler:nil];
        return;

    }//第一层for

    [self dismissViewControllerAnimated:YES completion:nil];
}


//从ItemProvider中取数据
- (BOOL)loadItemProvider:(NSItemProvider *)itemProvider
          withIdentifier:(NSArray <NSString *>*)identifiers
         completionBlock:(void (^)(id <NSSecureCoding> item))completionBlock {

    for(NSString *identifier in identifiers){

        if ([itemProvider hasItemConformingToTypeIdentifier:identifier]){
            if (@available(iOS 9.1, *)) {   //如果是livePhoto,显示livePhto按钮
                if ([itemProvider hasItemConformingToTypeIdentifier:@"com.apple.live-photo"]){
                    self.livePhotoBtn.hidden = NO;
                }
            }

            [itemProvider loadItemForTypeIdentifier:identifier options:nil completionHandler:^(id <NSSecureCoding> item, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(completionBlock){
                        completionBlock(item);
                    }
                });
            }];
            return YES;
        }
    }
    return NO;
}

//处理LivePhoto
- (void)handleLivePhoto:(PHLivePhoto *)livePhoto {
    NSArray *resourceArray = [PHAssetResource assetResourcesForLivePhoto:livePhoto];
    PHAssetResourceManager *assetResourceManager = [PHAssetResourceManager defaultManager];

    NSError *error;

    //保存livePhoto中的图片
    PHAssetResource *livePhotoImageAsset = resourceArray[0];
    // Create path.
    NSURL *groupPathURL = [LWMyUtils URLWithGroupName:Share_Group];

    NSString *imageFileName = [NSString stringWithFormat:@"%@.jpg", [LWMyUtils getCurrentTimeStampText]];
    NSURL *livePhotoImageURL = [groupPathURL URLByAppendingPathComponent:imageFileName];
    [[NSFileManager defaultManager] removeItemAtURL:livePhotoImageURL error:nil];

    [assetResourceManager writeDataForAssetResource:livePhotoImageAsset toFile:livePhotoImageURL options:nil completionHandler:^(NSError *_Nullable error) {
        NSLog(@"error: %@", error);
    }];

    NSString *livePhotoImageURLString = livePhotoImageURL.path;
    NSString *livePhotoImageURLText = [livePhotoImageURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];


//    //保存livePhoto中的短视频
//    PHAssetResource *livePhotoVideoAsset = resourceArray[1];
//    // Create path.
//    NSString *videoFileName = [NSString stringWithFormat:@"%@.mov", [LWMyUtils getCurrentTimeStampText]];
//    NSURL *livePhotoVideoURL = [groupPathURL URLByAppendingPathComponent:videoFileName];
//    [[NSFileManager defaultManager] removeItemAtURL:livePhotoVideoURL error:&error];
//
//    [assetResourceManager writeDataForAssetResource:livePhotoVideoAsset toFile:livePhotoVideoURL options:nil completionHandler:^(NSError *_Nullable error) {
//        NSLog(@"error: %@", error);
//    }];
//
//    NSString *livePhotoVideoURLString = livePhotoVideoURL.path;
//    NSString *livePhotoVideoURLURLText = [livePhotoVideoURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];


    NSString *urlString = [NSString stringWithFormat:@"%@://share.file?from=native&file=%@", Share_Scheme, livePhotoImageURLText];
    //NSString *urlString = [NSString stringWithFormat:@"%@://share.livephoto?from=native&imageURL=%@&videoURL=%@", Share_Scheme, livePhotoImageURLText,livePhotoVideoURLURLText];
    [self openURLWithString:urlString];
}


//处理NSData
- (void)handleData:(NSData *)data eItem:(NSExtensionItem *)eItem {
    NSURL *groupPathURL = [LWMyUtils URLWithGroupName:Share_Group];
    NSString *genTitle = [[[LWMyUtils getCurrentTimeStampText] stringByAppendingString:@"."] stringByAppendingString:[data suffix]];
    NSString *title = eItem.attributedTitle ? eItem.attributedTitle.string : genTitle;
    NSString *fileName = [title subStringWithRegex:@".*/([^/]*)$" matchIndex:1] ?: title;
    NSURL *groupFileURL = [groupPathURL URLByAppendingPathComponent:fileName];


    BOOL isSuccess = [data writeToURL:groupFileURL atomically:YES];

    NSString *subURLString = groupFileURL.path;
    NSString *subURLText = [subURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"%@://share.file?from=native&url=%@", Share_Scheme, subURLText];
    [self openURLWithString:urlString];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [touches.anyObject locationInView:self.view];
    if (!CGRectContainsPoint(self.containerView.frame, point)) {
        [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    /* GET TEXT FROM WEB VIEW */
    self.imageView.hidden = YES;
    self.liveView.hidden = YES;
    self.textView.hidden = NO;
    NSString *text = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText"];
    self.textView.text = text;
    self.okButton.enabled = YES;
    [self.okButton setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];

    [self expandContainerViewFrameWithVerticelPadding:40];    //扩大ContainerView

    //保存数据到App Group
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:Share_Group];
    [userDefaults setValue:text forKey:Key_SharedText];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView setContentOffset:CGPointMake(0.0, scrollView.contentOffset.y)];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];

    //处理LivePhoto
    PHLivePhoto *livePhoto = nil;
    if (@available(iOS 9.1, *)) {
        livePhoto = info[UIImagePickerControllerLivePhoto];
    }
    if (livePhoto) {
        [self expandContainerViewFrameWithVerticelPadding:100];    //扩大ContainerView
        self.livePhotoBtn.enabled = NO;
        self.livePhotoBtn.hidden = NO;
        //self.livePhotoBtn.backgroundColor = [UIColor clearColor];
        self.liveView.hidden = NO;
        [self.imageView removeFromSuperview];
        [self.textView removeFromSuperview];
        self.liveView.livePhoto = livePhoto;
        [self.liveView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        self.isLivePhoto = YES;
        return;

    } else {

        [self expandContainerViewFrameWithVerticelPadding:150];    //扩大ContainerView
        [self.livePhotoBtn removeFromSuperview];
        [self.textView removeFromSuperview];
        self.imageView.hidden = NO;
        //处理其他照片
        BOOL isGIF = [self isGIFWithPickerInfo:info];
        if (isGIF) {    //是GIF图片
            self.imageView.image = nil;
            self.imageView.animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:self.imageData];
        }else{
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            self.imageView.image = image;
            self.imageData = UIImagePNGRepresentation(image);
        }
        self.isPickerImage = YES;
        return;
    }
}

- (void)expandContainerViewFrameWithVerticelPadding:(CGFloat)vPadding {
    [UIView animateWithDuration:0.1 animations:^{} completion:^(BOOL finished) {
        [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.leading.equalTo(self.view.mas_leading).offset(20);
            make.trailing.equalTo(self.view.mas_trailing).offset(-20);
            make.top.equalTo(self.view).offset(vPadding);
            make.bottom.equalTo(self.view).offset(-vPadding);
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
}


//判断是否是GIF图片
- (BOOL)isGIFWithPickerInfo:(NSDictionary *)info {
    __block BOOL isGIF = NO;
    if (@available(iOS 11.0, *)) {
        PHAsset *phAsset = info[UIImagePickerControllerPHAsset];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.synchronous = YES;

        weakify(self)
        PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
        [imageManager requestImageDataForAsset:phAsset
                                       options:options
                                 resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, UIImageOrientation orientation, NSDictionary *_Nullable info) {
                                     strongify(self)
                                     Log(@"dataUTI:%@", dataUTI);

                                     //gif 图片
                                     if ([dataUTI isEqualToString:(__bridge NSString *) kUTTypeGIF]) {
                                         //这里获取gif图片的NSData数据
                                         BOOL downloadFinined = (![info[PHImageCancelledKey] boolValue] && !info[PHImageErrorKey]);
                                         if (downloadFinined && imageData) {
                                             isGIF = YES;
                                             self.imageData = imageData;
                                         }
                                     }
                                 }];


    } else {

        weakify(self)
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        //使用信号量解决 assetForURL 同步问题
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [library assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                        strongify(self)
//                        ALAssetRepresentation *repr = [asset defaultRepresentation];
//                        if ([[repr UTI] isEqualToString:@"com.compuserve.gif"]) {
//                            isGIF = YES;
//                        }

                        ALAssetRepresentation *re = [asset representationForUTI:(__bridge NSString *) kUTTypeGIF];
                        if (re) {
                            isGIF = YES;

                            //获取GIF数据
                            size_t size = (size_t) re.size;
                            uint8_t *buffer = malloc(size);
                            NSError *error;
                            NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
                            self.imageData = [NSData dataWithBytes:buffer length:bytes];
                            free(buffer);
                        }

                        dispatch_semaphore_signal(sema);
                    }
                    failureBlock:^(NSError *error) {
                        NSLog(@"Error getting asset! %@", error);
                        dispatch_semaphore_signal(sema);
                    }];
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    return isGIF;
}

@end
