//
//  LWWebViewController.m
//  PhotoDIY
//
//  Created by luowei on 2016/11/19.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWWebViewController.h"
#import "KINWebBrowserViewController.h"

@interface LWWebViewController ()

@end

@implementation LWWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.embeddedViewController loadURL:self.initialURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    UIViewController *desVC = segue.destinationViewController;
    if([desVC isMemberOfClass:[KINWebBrowserViewController class]]){
        self.embeddedViewController = (KINWebBrowserViewController *)desVC;
    }
}


+(LWWebViewController *)viewController:(NSURL *)url title:(NSString *)title{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LWWebViewController *webViewController = [storyboard instantiateViewControllerWithIdentifier:@"LWWebViewController"];
    webViewController.title = title;
    webViewController.initialURL = url;
    return webViewController;
}

-(IBAction)previousAction:(UIButton *)btn{

}

-(IBAction)nextAction:(UIButton *)btn{

}

-(IBAction)listAction:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
