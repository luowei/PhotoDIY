//
//  ViewController.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "ViewController.h"
#import "PDDrawView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //绘图板添加默认图片
    [self.drawView loadDefaultImage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)selPhotoAction:(UIBarButtonItem *)sender {

    [self.drawView showPhotos];
}

- (IBAction)filterAction:(UIBarButtonItem *)sender {

    [self.drawView showFilters];
}

- (IBAction)cropAction:(UIBarButtonItem *)sender {
}

- (IBAction)undoAction:(UIBarButtonItem *)sender {
}

- (IBAction)saveAction:(UIBarButtonItem *)sender {
}

@end
