//
//  USAssetGroupTableCell.h
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAssetGroupViewController.h"

#define kThumbnailLength    70.0f

@interface USAssetGroupTableCell : UITableViewCell

@property (nonatomic, strong) UIImageView *seprateLine;

- (void)bind:(id)assetsGroup;

@end
