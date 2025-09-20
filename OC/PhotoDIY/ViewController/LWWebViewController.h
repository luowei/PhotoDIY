//
//  LWWebViewController.h
//  PhotoDIY
//
//  Created by luowei on 2016/11/19.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KINWebBrowserViewController;

@interface LWWebViewController : UIViewController

@property(nonatomic, weak) IBOutlet UIButton *previousBtn;
@property(nonatomic, weak) IBOutlet UIButton *nextBtn;
@property(nonatomic, weak) IBOutlet UIButton *listBtn;

@property(nonatomic, strong) NSURL *initialURL;
@property(nonatomic, strong)  KINWebBrowserViewController *embeddedViewController;

@property(nonatomic, strong) NSDictionary *nextRowDict;

@property(nonatomic, strong) NSDictionary *previousRowDict;

@property(nonatomic, strong) NSArray *sectionData;

@property(nonatomic) NSInteger currentRow;

+(LWWebViewController *)viewController:(NSURL *)url title:(NSString *)title;

@end
