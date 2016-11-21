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

@property(nonatomic, strong) NSURL *initialURL;
@property(nonatomic, strong)  KINWebBrowserViewController *embeddedViewController;

+(LWWebViewController *)viewController:(NSURL *)url title:(NSString *)title;

@end
