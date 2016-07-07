//
//  ViewController.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "ViewController.h"
#import "PDDrawView.h"
#import "Categorys.h"

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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self.view rotationToInterfaceOrientation:toInterfaceOrientation];
}


- (IBAction)selPhotoAction:(UIBarButtonItem *)sender {
    [self.drawView showPhotos];
}

- (IBAction)filterAction:(UIBarButtonItem *)sender {
    [self.drawView showFilters];
}

- (IBAction)cropAction:(UIBarButtonItem *)sender {
    [self.drawView showOrHideCropView];
}

- (IBAction)saveAction:(UIBarButtonItem *)sender {
    [self.drawView saveImage];
}

- (IBAction)rotateRight:(UIBarButtonItem *)sender {
    [self.drawView rotateRight];
}

- (IBAction)rotateLeft:(UIBarButtonItem *)sender {
    [self.drawView rotateLeft];
}

- (IBAction)flipHorizonal:(UIBarButtonItem *)sender {
    [self.drawView flipHorizonal];
}

- (IBAction)share:(UIBarButtonItem *)sender {
}

- (IBAction)cropOkAction:(UIButton *)sender {
    [self.drawView cropImageOk];
}

- (IBAction)cropCancelAction:(UIButton *)sender {
    [self.drawView cancelCropImage];
}


@end
