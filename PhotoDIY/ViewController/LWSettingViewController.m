//
//  LWSettingViewController.m
//  PhotoDIY
//
//  Created by luowei on 2016/11/18.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWSettingViewController.h"
#import "LWWebViewController.h"
#import "Reachability.h"
#import "LWHelper.h"
#import "FCAlertView.h"

@interface LWSettingViewController () {
}

@property(nonatomic, strong) NSArray *data;

@property(nonatomic, strong) SKProduct *iapProduct;
@property(nonatomic) BOOL isRestoreRequest;

@end

@implementation LWSettingViewController

+(instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LWSettingViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"LWSettingViewController"];
    return settingVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.data = @[];

    NSString *fileName = [self getJsonFileName];    //获得json文件的名字

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        self.data = ((NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil])[@"data"];
    } else {
        NSString *urlStr = [NSString stringWithFormat:@"http://wodedata.com/MyResource/PhotoDIY-Guide/%@.json",fileName];
        NSURL *url = [NSURL URLWithString:urlStr];
        __weak typeof(self) weakSelf = self;
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            weakSelf.data = ((NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:nil])[@"data"];
        }] resume];
    }

    //监听产品请求处理通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProductRequestNotification:)
                                                 name:IAPProductRequestNotification
                                               object:[StoreManager sharedInstance]];
    //监听内购处理通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchasesNotification:)
                                                 name:IAPPurchaseNotification
                                               object:[StoreObserver sharedInstance]];

}

//获得json文件的名字
- (NSString *)getJsonFileName {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [locale displayNameForKey:NSLocaleIdentifier value:[locale localeIdentifier]];
//    NSString *languageCode = locale.languageCode;
//    NSLog(@"-----languageCode:%@",languageCode);
    NSLog(@"-----language:%@",language);

    NSString *fileName = @"guide_en";
    if ([language containsString:@"中文"] && ![language containsString:@"繁體"]) {
        fileName = @"guide_cn";
    }else if ([language containsString:@"English"]) {
        fileName = @"guide_en";
    } else if ([language containsString:@"الولايات المتحدة"]) {
        fileName = @"guide_ar";
    } else if ([language containsString:@"français"]) {
        fileName = @"guide_fr";
    } else if ([language containsString:@"日本語"]) {
        fileName = @"guide_ja";
    } else if ([language containsString:@"한국어"]) {
        fileName = @"guide_ko";
    } else if ([language containsString:@"português"]) {
        fileName = @"guide_pt";
    } else if ([language containsString:@"русский"]) {
        fileName = @"guide_ru";
    } else if ([language containsString:@"español"]) {
        fileName = @"guide_es";
    } else if ([language containsString:@"Deutsch"]) {
        fileName = @"guide_de";
    } else if ([language containsString:@"繁體"]) {
        fileName = @"guide_hk";
    }
    return fileName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(!self.data || self.data.count == 0){
        NSString *fileName = [self getJsonFileName];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        self.data = ((NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil])[@"data"];
    }
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = 0;
    NSDictionary *sectionDict = self.data[(NSUInteger) section];
    NSArray *sectionData = sectionDict.allValues.firstObject;
    count = sectionData.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *sectionDict = self.data[(NSUInteger) indexPath.section];
    NSArray *sectionData = sectionDict.allValues.firstObject;
    NSDictionary *rowDict = sectionData[(NSUInteger) indexPath.row];
    NSString *key = rowDict.allKeys.firstObject;
    cell.titleLabel.text = key;
    return cell;
}


#pragma mark - UITableViewDelegate

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionDict = self.data[(NSUInteger) section];
    NSString *sectionTitle = sectionDict.allKeys.firstObject;
    return sectionTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *sectionDict = self.data[(NSUInteger) indexPath.section];
    NSArray *sectionData = sectionDict.allValues.firstObject;
    NSDictionary *rowDict = sectionData[(NSUInteger) indexPath.row];
    NSString *key = rowDict.allKeys.firstObject;

    NSString *urlString = rowDict[key];
    if (![urlString isKindOfClass:[NSString class]] || [urlString isEqualToString:@""]) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    LWWebViewController *webVC = [LWWebViewController viewController:url title:key];
    
    webVC.sectionData = sectionData;
    webVC.currentRow = indexPath.row;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - 内购处理

//开始购买
- (IBAction)buyAction:(UIButton *)sender {
    self.isRestoreRequest = NO;
    NSNumber *isPurchasedValue = [[NSUserDefaults standardUserDefaults] objectForKey:Key_isPurchasedSuccessedUser];
    if(![isPurchasedValue boolValue]){ //还未赋初值或还未购买
        [self fetchProductInformation]; //获取内购产品
    }else {
        [LWHelper showHUDWithDetailMessage:NSLocalizedString(@"Have been purchased", nil)];
    }
}

//恢复购买
- (IBAction)restoreAction:(UIButton *)sender {
    self.isRestoreRequest = YES;
    NSNumber *isPurchasedValue = [[NSUserDefaults standardUserDefaults] objectForKey:Key_isPurchasedSuccessedUser];
    if(![isPurchasedValue boolValue]){ //还未赋初值或还未购买
        [self fetchProductInformation]; //获取内购产品
    }else {
        [LWHelper showHUDWithDetailMessage:NSLocalizedString(@"Have been purchased", nil)];
    }
}


//从AppStore获取内购产品信息
- (void)fetchProductInformation {
    if ([SKPaymentQueue canMakePayments]) {
        NSArray<NSString *> *productIds = @[IAPProductId];
        [[StoreManager sharedInstance] fetchProductInformationForIds:productIds];
    } else {
        [LWHelper showHUDWithDetailMessage:NSLocalizedString(@"Purchases Disabled on this device.", nil)];
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

                SKProduct *iapProduct = products.firstObject;
                if([IAPProductId isEqualToString:iapProduct.productIdentifier]){
                    self.iapProduct = iapProduct;
                    if(self.isRestoreRequest){
                        //首次安装走恢复购买
                        [[StoreObserver sharedInstance] restoreWithProduct:iapProduct];   //恢复购买
                    }else{
                        //显示购买产品弹窗
                        [self showProductAlert:iapProduct];
                    }
                    return;
                }
            }
        }

    }
}

//显示购买产品弹窗
- (void)showProductAlert:(SKProduct *)iapProduct {
    NSString *title = iapProduct.localizedTitle;
    NSString *price = [NSString stringWithFormat:@"%@%@", [iapProduct.priceLocale objectForKey:NSLocaleCurrencySymbol], iapProduct.price];
    NSString *descText = [NSString stringWithFormat:@"%@\n%@%@",iapProduct.localizedDescription, NSLocalizedString(@"Support Developer", nil),price];
    NSLog(@"====availabel===title:%@, price:%@",title,price);


    //弹窗
    FCAlertView *alert = [FCAlertView new];
    alert.avoidCustomImageTint = YES;
    [alert makeAlertTypeSuccess];
    //alert.blurBackground = YES;
    alert.bounceAnimations = YES;

    __weak typeof(alert) weakAlert = alert;
    [alert doneActionBlock:^{
        __strong typeof(weakAlert) strongAlert = weakAlert;

        [[StoreObserver sharedInstance] buy:iapProduct];    //执行购买
        [strongAlert dismissAlertView];
    }];
    [alert addButton:NSLocalizedString(@"Cancel", nil) withActionBlock:^{
        __strong typeof(weakAlert) strongAlert = weakAlert;
        [strongAlert dismissAlertView];
    }];

    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [alert showAlertInWindow:keyWindow withTitle:title withSubtitle:descText
             withCustomImage:nil withDoneButtonTitle:NSLocalizedString(@"Ok", nil) andButtons:nil];

    //消息提示
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:Key_isPurchasedSuccessedUser];
    if(!value && [LWHelper isAfterDate:Open_Day]){  //新安装
        [LWHelper showHUDWithDetailMessage:NSLocalizedString(@"RePurchased Free", nil)];
    }

}


//处理购买结果通知
- (void)handlePurchasesNotification:(NSNotification *)notification {
    StoreObserver *storeObserver = (StoreObserver *) notification.object;
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus) storeObserver.status;

    switch (status) {
        case IAPPurchaseFailed:
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:Key_isPurchasedSuccessedUser];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [LWHelper showHUDWithDetailMessage:storeObserver.message];
            [self updateBuyUI]; //更新购买UI
            break;
        case IAPRestoredSucceeded: {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:Key_isPurchasedSuccessedUser];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [LWHelper showHUDWithDetailMessage:storeObserver.message];
            [self updateBuyUI]; //更新购买UI
            break;
        }
        case IAPRestoredFailed:
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:Key_isPurchasedSuccessedUser];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [LWHelper showHUDWithDetailMessage:storeObserver.message];
            [self updateBuyUI]; //更新购买UI
            break;
        case IAPDownloadStarted: {
            break;
        }
        case IAPDownloadInProgress: {
            //[NSString stringWithFormat:@" Downloading %@   %.2f%%", displayedTitle, storeObserver.downloadProgress];
            break;
        }
        case IAPDownloadSucceeded: {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:Key_isPurchasedSuccessedUser];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //[LWHelper showHUDWithDetailMessage:storeObserver.message];
            [self updateBuyUI]; //更新购买UI
            break;
        }
        default:
            break;
    }
}

/*
 * 更新购买UI
 */
- (void)updateBuyUI {
    if([LWHelper isPurchased]){
        self.buyBtn.enabled = NO;
        self.purchasedLabel.hidden = NO;
        self.purchasedLabel.text = NSLocalizedString(@"Thanks for Your Surpport", nil);
    }else{
        self.buyBtn.enabled = YES;
        self.purchasedLabel.hidden = YES;
    }
}


@end

@implementation LWTableViewCell


@end

