//
//  ViewController.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "ViewController.h"
#import "LWContentView.h"
#import "Categorys.h"
#import "LWImageZoomView.h"
#import "LWWebViewController.h"
#import "AppDelegate.h"
#import <UShareUI/UShareUI.h>

@interface ViewController ()

@end

@implementation ViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //绘图板添加默认图片
    [self.contentView loadDefaultImage];

    self.fontURLMap = @{
            @"SCFYYREN":@"http://oss.wodedata.com/Fonts/%E4%B9%A6%E4%BD%93%E5%9D%8A%E4%BA%8E%E5%8F%B3%E4%BB%BB%E6%A0%87%E5%87%86%E8%8D%89%E4%B9%A6.ttf",
            @"STCaiyun":@"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E5%BD%A9%E4%BA%91.ttf",
            @"STKaiti":@"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E6%A5%B7%E4%BD%93.ttf",
            @"STHupo":@"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E7%90%A5%E7%8F%80.ttf",
            @"STXingkai":@"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E8%A1%8C%E6%A5%B7.ttf",
            @"STLiti":@"http://oss.wodedata.com/Fonts/%E5%8D%8E%E6%96%87%E9%9A%B6%E4%B9%A6.ttf",
            @"FZY1JW--GB1-0":@"http://oss.wodedata.com/Fonts/%E6%96%B9%E6%AD%A3%E7%BB%86%E5%9C%86%E7%AE%80%E4%BD%93.ttf",
            @"LiuJiang-Cao-1.0":@"http://oss.wodedata.com/Fonts/%E9%92%9F%E9%BD%90%E6%B5%81%E6%B1%9F%E7%A1%AC%E7%AC%94%E8%8D%89%E4%BD%93.ttf",
            @"momo_xinjian":@"http://oss.wodedata.com/Fonts/%E9%BB%98%E9%99%8C%E4%BF%A1%E7%AC%BA%E6%89%8B%E5%86%99%E4%BD%93.ttf",
    };

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDetailVC:) name:Notification_ShowViewController object:nil];

}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    self.circleProgressBar = [[CircleProgressBar alloc] init];
    [self.view addSubview:self.circleProgressBar];
    self.circleProgressBar.backgroundColor = [UIColor clearColor];
    self.circleProgressBar.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:self.circleProgressBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:self.circleProgressBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.circleProgressBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:60];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.circleProgressBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:60];
    [NSLayoutConstraint activateConstraints:@[xConstraint,yConstraint,widthConstraint,heightConstraint]];
    self.circleProgressBar.hidden = YES;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view didLayoutSubviews];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self.view rotationToInterfaceOrientation:toInterfaceOrientation];
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//}


#pragma mark - IBAction
- (IBAction)titleBtnAction:(UIButton *)sender {
}

- (IBAction)selPhotoAction:(id)sender {
    [self.contentView showPhotos];
}

- (IBAction)filterAction:(id)sender {
    [self.contentView showFilters];
}

- (IBAction)cropAction:(id)sender {
    [self.contentView showOrHideCropView];
}

- (IBAction)drawAction:(id)sender {
    [self.contentView showDrawView];
}


- (IBAction)saveAction:(id)sender {
    [self.contentView saveImage];
}

- (IBAction)recovery:(id)sender {
    [self.contentView recovery];
}

- (IBAction)rotateRight:(id)sender {
    [self.contentView.zoomView rotateRight];
}

- (IBAction)rotateLeft:(id)sender {
    [self.contentView.zoomView rotateLeft];
}

- (IBAction)flipHorizonal:(id)sender {
    [self.contentView.zoomView flipHorizonal];
}

- (IBAction)share:(id)sender {

    //显示分享面板
    __weak typeof(self) weakSelf = self;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [weakSelf shareImageAndTextToPlatformType:platformType];
    }];

}

- (IBAction)cropOkAction:(id)sender {
    [self.contentView cropImageOk];
}

- (IBAction)cropCancelAction:(id)sender {
    [self.contentView cancelCropImage];
}


//分享图片和文字
- (void)shareImageAndTextToPlatformType:(UMSocialPlatformType)platformType {
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];

    //设置文本
    messageObject.text = NSLocalizedString(@"ShareText",@"照片DIY的图片分享");

    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = [UIImage imageNamed:@"thumbImg"];
//    NSString* thumbURL =  @"http://dev.umeng.com/images/tab2_1.png";
//    shareObject.shareImage = thumbURL;

    shareObject.shareImage = [self.contentView getSyncImage];

    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;

    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********", error);
        } else {
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@", resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@", resp.originalResponse);

            } else {
                UMSocialLogInfo(@"response data is %@", data);
            }
        }
        [self alertWithError:error];
    }];
}

- (void)alertWithError:(NSError *)error {
    NSString *result = nil;
    if (!error) {
        result = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Share succeed", @"分享成功")];
    } else {
        result = [NSString stringWithFormat:@"%@ %d\n", NSLocalizedString(@"Share fail", @"分享失败,错误码为："), (int) error.code];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"share", @"分享")
                                                    message:result
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"确定")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showDetailVC:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    NSURL *url = dict[@"URL"];
    NSString *scheme = [[url scheme] lowercaseString];
    NSString *host = [url host];
    NSString *hostSufix = [host subStringWithRegex:@".*\\.([\\w_-]*)$" matchIndex:1];
    NSDictionary *queryDict = [url queryDictionary];
    UIViewController *controller = nil;

    if ([scheme isEqualToString:@"photodiy"]) {
        NSString *urlString = [queryDict[@"url"] stringByRemovingPercentEncoding];
        urlString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef) urlString, (CFStringRef) @"!NULL,'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
        NSURL *detailURL = [NSURL URLWithString:urlString];

        if (([hostSufix isEqualToString:@"http"] || [hostSufix isEqualToString:@"https"]) && detailURL) {
            controller = [LWWebViewController viewController:detailURL title:nil];
        }else{
            return;
        }
    }
    if (controller) {
        NSString *title = [queryDict[@"title"] stringByRemovingPercentEncoding];
        controller.navigationItem.title = title;
        [controller setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


@end


@implementation LWToolBar {
    CALayer *_topLine;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

@end

