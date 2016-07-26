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


- (IBAction)selPhotoAction:(id)sender {
    [self.drawView showPhotos];
}

- (IBAction)filterAction:(id)sender {
    [self.drawView showFilters];
}

- (IBAction)cropAction:(id)sender {
    [self.drawView showOrHideCropView];
}

- (IBAction)saveAction:(id)sender {
    [self.drawView saveImage];
}

- (IBAction)rotateRight:(id)sender {
    [self.drawView rotateRight];
}

- (IBAction)rotateLeft:(id)sender {
    [self.drawView rotateLeft];
}

- (IBAction)flipHorizonal:(id)sender {
    [self.drawView flipHorizonal];
}

- (IBAction)share:(id)sender {
}

- (IBAction)cropOkAction:(id)sender {
    [self.drawView cropImageOk];
}

- (IBAction)cropCancelAction:(id)sender {
    [self.drawView cancelCropImage];
}


@end


@implementation LWToolBar{
    CALayer *_topLine;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

@end

