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
#import "StoreObserver.h"
#import "StoreManager.h"
#import <UMengUShare/UMShareMenuSelectionView.h>
#import <UMengUShare/UMSocialUIManager.h>

@interface ViewController ()

@end

@implementation ViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //绘图板添加默认图片
    [self.contentView loadDefaultImage];

//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];

//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

/*
    //监听产品请求处理通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProductRequestNotification:)
                                                 name:IAPProductRequestNotification
                                               object:[StoreManager sharedInstance]];
    //监听内购处理通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchasesNotification:)
                                                 name:IAPPurchaseNotification
                                               object:[StoreObserver sharedInstance]];

    //从AppStore获取内购产品信息
    [self fetchProductInformation];
*/
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPProductRequestNotification object:[StoreManager sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPPurchaseNotification object:[StoreObserver sharedInstance]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).portraitVC = YES;
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.portraitVC = NO;
//
//    [self supportedInterfaceOrientations];
//    [self shouldAutorotate];
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];

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

////只允许竖屏
//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self.view rotationToInterfaceOrientation:toInterfaceOrientation];
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//}

#pragma mark - 内购处理

//从AppStore获取内购产品信息
- (void)fetchProductInformation {
    if ([SKPaymentQueue canMakePayments]) {
        NSArray<NSString *> *productIds = @[@"com.wodedata.PhotoDIY_InAppPurchase"];
        [[StoreManager sharedInstance] fetchProductInformationForIds:productIds];
    } else {
        [self alertWithTitle:@"Warning" message:@"Purchases are disabled on this device."];
    }
}

//处理内购产品请求结果通知
- (void)handleProductRequestNotification:(NSNotification *)notification {
    StoreManager *storeManager = (StoreManager *) notification.object;
    IAPProductRequestStatus result = (IAPProductRequestStatus) storeManager.status;

    if (result == IAPProductRequestResponse) {
        NSArray *models = storeManager.responseModels;

        for (MyModel *model in models) {
            NSArray<SKProduct *> *products = model.elements;
            if ([model.name isEqualToString:@"AVAILABLE PRODUCTS"]) {
                SKProduct *aProduct = products.firstObject;
                NSString *title = aProduct.localizedTitle;
                NSString *price = [NSString stringWithFormat:@"%@ %@",[aProduct.priceLocale objectForKey:NSLocaleCurrencySymbol],aProduct.price];
                NSLog(@"====availabel===title:%@, price:%@",title,price);
            }
        }

    }
}

//处理购买结果通知
- (void)handlePurchasesNotification:(NSNotification *)notification {
    StoreObserver *purchasesNotification = (StoreObserver *) notification.object;
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus) purchasesNotification.status;

    /*switch (status) {
        case IAPPurchaseFailed:
            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            break;
            // Switch to the iOSPurchasesList view controller when receiving a successful restore notification
        case IAPRestoredSucceeded: {
            self.restoreWasCalled = YES;

            [self cycleFromViewController:self.currentViewController toViewController:self.purchasesList];
            [self.purchasesList reloadUIWithData:[self dataSourceForPurchasesUI]];
        }
            break;
        case IAPRestoredFailed:
            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            break;
            // Notify the user that downloading is about to start when receiving a download started notification
        case IAPDownloadStarted: {
            self.hasDownloadContent = YES;
            [self.view addSubview:self.statusMessage];
        }
            break;
            // Display a status message showing the download progress
        case IAPDownloadInProgress: {
            self.hasDownloadContent = YES;
            NSString *title = [[StoreManager sharedInstance] titleMatchingProductIdentifier:purchasesNotification.purchasedID];
            NSString *displayedTitle = (title.length > 0) ? title : purchasesNotification.purchasedID;
            self.statusMessage.text = [NSString stringWithFormat:@" Downloading %@   %.2f%%", displayedTitle, purchasesNotification.downloadProgress];
        }
            break;
            // Downloading is done, remove the status message
        case IAPDownloadSucceeded: {
            self.hasDownloadContent = NO;
            self.statusMessage.text = @"Download complete: 100%";

            // Remove the message after 2 seconds
            [self performSelector:@selector(hideStatusMessage) withObject:nil afterDelay:2];
        }
            break;
        default:
            break;
    }*/
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


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
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
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

@end


@implementation LWToolBar {
    CALayer *_topLine;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

@end

