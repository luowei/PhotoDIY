//
//  LWSettingViewController.h
//  PhotoDIY
//
//  Created by luowei on 2016/11/18.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreObserver.h"
#import "StoreManager.h"


//IAP购买成功
#define Key_isPurchasedSuccessedUser  @"Key_isPurchasedSuccessedUser"
#define IAPProductId @"com.wodedata.PhotoDIY_NoAdPass"   //内购ProductId

#define Open_Day @"2017-12-01"  //开放日,开启WallActivity


@interface LWSettingViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
@property (weak, nonatomic) IBOutlet UILabel *purchasedLabel;

- (IBAction)buyAction:(UIButton *)sender;

@end

@interface LWTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
