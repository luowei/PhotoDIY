//
//  LWWebViewController.m
//  PhotoDIY
//
//  Created by luowei on 2016/11/19.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWWebViewController.h"
#import "KINWebBrowserViewController.h"

@interface LWWebViewController (){
    NSURL *_previousURL;
    NSURL *_nextURL;
}

@end

@implementation LWWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.embeddedViewController loadURL:self.initialURL];
    [self resetPreAndNextURL];  //重新设置下一个/上一个的URL

}

- (void)resetPreAndNextURL {
    if(_currentRow + 1 < self.sectionData.count){  //下一项
        self.nextRowDict =  self.sectionData[(NSUInteger) _currentRow + 1];
        self.currentRow = _currentRow + 1;
    }
    if(_currentRow -1 >= 0){  //上一项
        self.previousRowDict =  self.sectionData[(NSUInteger) _currentRow - 1];
        self.currentRow = _currentRow - 1;
    }

    //上一个
    NSString *previousRowKey = self.previousRowDict.allKeys.firstObject;
    NSString *previousUrlString = self.previousRowDict[previousRowKey];
    if (![previousUrlString isKindOfClass:[NSString class]] || [previousUrlString isEqualToString:@""]) {
        self.previousBtn.enabled = NO;
    }else{
        self.previousBtn.enabled = YES;
        _previousURL = [NSURL URLWithString:previousUrlString];
    }

    //下一个
    NSString *nextRowKey = self.nextRowDict.allKeys.firstObject;
    NSString *nextUrlString = self.nextRowDict[nextRowKey];
    if (![nextUrlString isKindOfClass:[NSString class]] || [nextUrlString isEqualToString:@""]) {
        self.nextBtn.enabled = NO;
    }else{
        self.nextBtn.enabled = YES;
        _nextURL = [NSURL URLWithString:nextUrlString];
    }
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
    if(self.currentRow <= 0 ){
        return;
    }
    //加载上一页
    NSString *previousRowKey = self.previousRowDict.allKeys.firstObject;
    _previousURL = [NSURL URLWithString:self.previousRowDict[previousRowKey]];
    self.title = previousRowKey;
    self.initialURL = _previousURL;
    [self.embeddedViewController loadURL:_previousURL];
    self.currentRow = _currentRow - 1;

    [self resetPreAndNextURL];  //重新设置下一个/上一个的URL
}

-(IBAction)nextAction:(UIButton *)btn{
    if(self.currentRow >= self.sectionData.count-1 ){
        return;
    }
    //加截下一页
    NSString *nextRowKey = self.nextRowDict.allKeys.firstObject;
    _nextURL = [NSURL URLWithString:self.nextRowDict[nextRowKey]];
    self.title = nextRowKey;
    self.initialURL = _nextURL;
    [self.embeddedViewController loadURL:_nextURL];
    self.currentRow = _currentRow + 1;

    [self resetPreAndNextURL];  //重新设置下一个/上一个的URL
}

-(IBAction)listAction:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
