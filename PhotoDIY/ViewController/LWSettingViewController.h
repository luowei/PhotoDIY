//
//  LWSettingViewController.h
//  PhotoDIY
//
//  Created by luowei on 2016/11/18.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWSettingViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
@property (weak, nonatomic) IBOutlet UILabel *purchasedLabel;


- (IBAction)buyAction:(UIButton *)sender;

@end
