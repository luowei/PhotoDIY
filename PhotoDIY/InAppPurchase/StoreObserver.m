/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Implements the SKPaymentTransactionObserver protocol. Handles purchasing and restoring products
         as well as downloading hosted content using paymentQueue:updatedTransactions: and paymentQueue:updatedDownloads:,
         respectively. Provides download progress information using SKDownload's progres. Logs the location of the downloaded
         file using SKDownload's contentURL property.
 */


#import "StoreObserver.h"

NSString *const IAPPurchaseNotification = @"IAPPurchaseNotification";

@interface StoreObserver ()

@end

@implementation StoreObserver

+ (StoreObserver *)sharedInstance {
    static dispatch_once_t onceToken;
    static StoreObserver *storeObserverSharedInstance;

    dispatch_once(&onceToken, ^{
        storeObserverSharedInstance = [[StoreObserver alloc] init];
    });
    return storeObserverSharedInstance;
}


- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _purchasedTransactions = [[NSMutableArray alloc] initWithCapacity:0];
        _restoredTransactions = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Make a purchase

// Create and add a payment request to the payment queue
- (void)buy:(SKProduct *)product {
    //添加交易队列观察者
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    self.product = product;

    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - Has purchased products

// Returns whether there are purchased products
- (BOOL)hasPurchasedProducts {
    // purchasedTransactions keeps track of all our purchases.
    // Returns YES if it contains some items and NO, otherwise
    return (self.purchasedTransactions.count > 0);
}


#pragma mark - Has restored products

// Returns whether there are restored purchases
- (BOOL)hasRestoredProducts {
    // restoredTransactions keeps track of all our restored purchases.
    // Returns YES if it contains some items and NO, otherwise
    return (self.restoredTransactions.count > 0);
}


#pragma mark - Restore purchases

//恢复购买指定product
- (void)restoreWithProduct:(SKProduct *)product {
    //添加交易队列观察者
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    self.product = product;

    self.restoredTransactions = [[NSMutableArray alloc] initWithCapacity:0];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


//恢复购买
- (void)restore {
    //添加交易队列观察者
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    self.restoredTransactions = [[NSMutableArray alloc] initWithCapacity:0];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark - SKPaymentTransactionObserver methods

// Called when there are trasactions in the payment queue
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {

        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;

            case SKPaymentTransactionStateDeferred:
                // Do not block your UI. Allow the user to continue using your app.
                NSLog(@"Allow the user to continue using your app.");
                break;
                // The purchase was successful
            case SKPaymentTransactionStatePurchased: {
                self.purchasedID = transaction.payment.productIdentifier;
                [self.purchasedTransactions addObject:transaction];

                NSLog(@"Deliver content for %@", transaction.payment.productIdentifier);
                // Check whether the purchased product has content hosted with Apple.
                if (transaction.downloads && transaction.downloads.count > 0) {
                    [self completeTransaction:transaction forStatus:IAPDownloadStarted];
                } else {
                    [self completeTransaction:transaction forStatus:IAPPurchaseSucceeded];
                }
                break;
            }
                // There are restored products
            case SKPaymentTransactionStateRestored: {
                self.purchasedID = transaction.payment.productIdentifier;
                [self.restoredTransactions addObject:transaction];

                NSLog(@"Restore content for %@", transaction.payment.productIdentifier);
                // Send a IAPDownloadStarted notification if it has
                if (transaction.downloads && transaction.downloads.count > 0) {
                    [self completeTransaction:transaction forStatus:IAPDownloadStarted];
                } else {
                    [self completeTransaction:transaction forStatus:IAPRestoredSucceeded];
                }
                break;
            }
                // The transaction failed
            case SKPaymentTransactionStateFailed: {
                self.message = [NSString stringWithFormat:@"Purchase of %@ failed.", transaction.payment.productIdentifier];
                [self completeTransaction:transaction forStatus:IAPPurchaseFailed];
                break;
            }
            default:
                break;
        }
    }
}


// Called when the payment queue has downloaded content
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    for (SKDownload *download in downloads) {
        switch (download.downloadState) {
            // The content is being downloaded. Let's provide a download progress to the user
            case SKDownloadStateActive: {
                self.status = IAPDownloadInProgress;
                self.purchasedID = download.transaction.payment.productIdentifier;
                self.downloadProgress = download.progress * 100;
                [[NSNotificationCenter defaultCenter] postNotificationName:IAPPurchaseNotification object:self];
                break;
            }
            case SKDownloadStateCancelled:
                // StoreKit saves your downloaded content in the Caches directory. Let's remove it
                // before finishing the transaction.
                [[NSFileManager defaultManager] removeItemAtURL:download.contentURL error:nil];
                [self finishDownloadTransaction:download.transaction];
                break;

            case SKDownloadStateFailed:
                // If a download fails, remove it from the Caches, then finish the transaction.
                // It is recommended to retry downloading the content in this case.
                [[NSFileManager defaultManager] removeItemAtURL:download.contentURL error:nil];
                [self finishDownloadTransaction:download.transaction];
                break;

            case SKDownloadStatePaused:
                NSLog(@"Download was paused");
                break;

            case SKDownloadStateFinished:
                // Download is complete. StoreKit saves the downloaded content in the Caches directory.
                NSLog(@"Location of downloaded file %@", download.contentURL);
                [self finishDownloadTransaction:download.transaction];
                break;

            case SKDownloadStateWaiting:
                NSLog(@"Download Waiting");
                [[SKPaymentQueue defaultQueue] startDownloads:@[download]];
                break;

            default:
                break;
        }
    }
}


// Logs all transactions that have been removed from the payment queue
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"%@ was removed from the payment queue.", transaction.payment.productIdentifier);
    }
}


// Called when an error occur while restoring purchases. Notify the user about the error.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (error.code != SKErrorPaymentCancelled) {
        self.status = IAPRestoredFailed;
        self.message = error.localizedDescription;
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPPurchaseNotification object:self];
    }
}


// Called when all restorable transactions have been processed by the payment queue
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"All restorable transactions have been processed by the payment queue.");

//    for (SKPaymentTransaction *transaction in [[SKPaymentQueue defaultQueue] transactions]) {
//        if ([transaction.payment.productIdentifier isEqualToString:IAPProductId]
//                && [self verifyPurchaseWithPaymentTrasaction:transaction]) {
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Key_isPurchasedSuccessedUser];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            break;
//        }
//    }

    if ([[[SKPaymentQueue defaultQueue] transactions] count] == 0){ //如果没有交易记录，则直接去购买
        [self buy:self.product];
    } else {
        for (SKPaymentTransaction *transaction in [[SKPaymentQueue defaultQueue] transactions]) {
            if (![transaction.payment.productIdentifier isEqualToString:self.product.productIdentifier]) {
                [self buy:self.product];
                break;
            }
        }
    }
}

////添加一个付款条
//-(void)addNewPaymentForProductId:(NSString *)productId{
//    if([SKPaymentQueue canMakePayments]){
//        SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
//        [[SKPaymentQueue defaultQueue] addPayment:payment];
//    }
//}



#pragma mark - Complete transaction

// Notify the user about the purchase process. Start the download process if status is
// IAPDownloadStarted. Finish all transactions, otherwise.
- (void)completeTransaction:(SKPaymentTransaction *)transaction forStatus:(NSInteger)status {
    self.status = (IAPPurchaseNotificationStatus) status;
    //Do not send any notifications when the user cancels the purchase
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // Notify the user
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPPurchaseNotification object:self];
    }

    if (status == IAPDownloadStarted) {
        // The purchased product is a hosted one, let's download its content
        [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
    } else if(status == IAPPurchaseSucceeded || status == IAPRestoredSucceeded || status == IAPDownloadSucceeded){
//todo:非消耗型商品，这里可以无需作凭证数据验证
//        // 发送到苹果服务器验证凭证
//        [self verifyPurchaseWithPayment];

        // Remove the transaction from the queue for purchased and restored statuses
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }else{
        // Remove the transaction from the queue for purchased and restored statuses
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}


#pragma mark - Handle download transaction

- (void)finishDownloadTransaction:(SKPaymentTransaction *)transaction {
    //allAssetsDownloaded indicates whether all content associated with the transaction were downloaded.
    BOOL allAssetsDownloaded = YES;

    // A download is complete if its state is SKDownloadStateCancelled, SKDownloadStateFailed, or SKDownloadStateFinished
    // and pending, otherwise. We finish a transaction if and only if all its associated downloads are complete.
    // For the SKDownloadStateFailed case, it is recommended to try downloading the content again before finishing the transaction.
    for (SKDownload *download in transaction.downloads) {
        if (download.downloadState != SKDownloadStateCancelled &&
                download.downloadState != SKDownloadStateFailed &&
                download.downloadState != SKDownloadStateFinished) {
            //Let's break. We found an ongoing download. Therefore, there are still pending downloads.
            allAssetsDownloaded = NO;
            break;
        }
    }

    // Finish the transaction and post a IAPDownloadSucceeded notification if all downloads are complete
    if (allAssetsDownloaded) {
        self.status = IAPDownloadSucceeded;

        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPPurchaseNotification object:self];

        if ([self.restoredTransactions containsObject:transaction]) {
            self.status = IAPRestoredSucceeded;
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPPurchaseNotification object:self];
        }

    }
}

#pragma mark - 验证购买凭据

//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"


// 验证购买凭据
- (BOOL)verifyPurchaseWithPayment {

    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];

    // 发送网络POST请求，对购买凭据进行验证
    //测试验证地址:https://sandbox.itunes.apple.com/verifyReceipt
    //正式验证地址:https://buy.itunes.apple.com/verifyReceipt
    NSData *appStoreResult = [self postReceiptData:receiptData withURL:[NSURL URLWithString:AppStore]];

    // AppStore验证结果为空
    if (appStoreResult == nil) {
        NSLog(@"验证失败");
        return NO;
    }

    //AppStore验证结果
    NSDictionary *appStoreResultDict = [NSJSONSerialization JSONObjectWithData:appStoreResult options:NSJSONReadingAllowFragments error:nil];
    if (appStoreResultDict != nil) {

        if([appStoreResultDict[@"status"] longValue] == 21007){ //如果返回21007,则再去Sanbox验证
            NSData *sandboxResult = [self postReceiptData:receiptData withURL:[NSURL URLWithString:SANDBOX]];

            // Sandbox验证结果为空
            if (sandboxResult == nil) {
                NSLog(@"验证失败");
                return NO;
            }

            NSDictionary *sandboxResultDict = [NSJSONSerialization JSONObjectWithData:sandboxResult options:NSJSONReadingAllowFragments error:nil];
            if(sandboxResultDict != nil){
                // 比对字典中以下信息基本上可以保证数据安全,确保用户是否已经正确购买
                // bundle_id , application_version , product_id , transaction_id
                //NSLog(@"Sandbox 验证成功！购买的商品是：%@", [sandboxResultDict yy_modelToJSONString]);
                NSLog(@"Sandbox 验证成功！");
                return YES;
            }

        } else{
            // 比对字典中以下信息基本上可以保证数据安全
            // bundle_id , application_version , product_id , transaction_id
            //NSLog(@"App Store 验证成功！购买的商品是：%@", [appStoreResultDict yy_modelToJSONString]);
            NSLog(@"App Store 验证成功！");
            return YES;
        }
    }
    return NO;
}

// 发送网络POST请求，对购买凭据进行验证
- (NSData *)postReceiptData:(NSData *)receiptData withURL:(NSURL *)url {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    urlRequest.HTTPMethod = @"POST";
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPBody = payloadData;

    // 提交验证请求，并获得官方的验证JSON结果 iOS9后更改了另外的一个方法
    NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    return result;
}


@end
