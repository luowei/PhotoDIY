//
//  USAssetGroupViewController.h
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USImagePickerController.h"
#import "USImagePickerController+Protect.h"

@interface USAssetGroupViewController : UIViewController

@property (nonatomic, strong) NSMutableSet *selectedAssets;

@end
