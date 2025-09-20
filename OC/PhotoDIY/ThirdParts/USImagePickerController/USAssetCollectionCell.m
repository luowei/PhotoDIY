//
//  USAssetCollectionCell.m
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetCollectionCell.h"

@interface USAssetCollectionCell ()

@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@property (nonatomic, strong) ALAsset *alAsset;

@property (nonatomic, strong) PHAsset *phAsset;
@property (nonatomic, assign) PHImageRequestID requestID;

@end

@implementation USAssetCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self initialize];
}

- (void)initialize
{
    self.checkButton.tintColor = [UIColor whiteColor];
    self.checkButton.layer.cornerRadius = CGRectGetHeight(self.checkButton.frame) / 2.0;
    
    UIImage *selectedImage = [[UIImage imageNamed:@"USPicker-Checkmark-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.checkButton setImage:selectedImage forState:UIControlStateNormal];
    [self.checkButton setImage:selectedImage forState:UIControlStateSelected];
    [self reloadCheckButtonBgColor];
    
    [self.imageButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
    [self.imageButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
}

- (void)reloadCheckButtonBgColor
{
    self.checkButton.backgroundColor = self.checkButton.selected ? self.selectedColor : RGBACOLOR(0, 0, 0, 0.2);
}

- (void)bind:(id)asset selected:(BOOL)selected
{
    _asset = asset;
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        self.phAsset = asset;
    } else {
        self.alAsset = asset;
    }
    
    if(self.phAsset) {
        
        NSInteger tag = self.tag + 1;
        self.tag = tag;
        
        [self.imageManager cancelImageRequest:self.requestID];
        
        self.requestID = [self.imageManager requestImageForAsset:self.phAsset
                                                      targetSize:_thumbnailTargetSize
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:_thumbnailRequestOptions
                                                   resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                       if (self.tag == tag && result) {
                                                           [self.imageButton setImage:result forState:UIControlStateNormal];
                                                       }
                                                   }];
    }
    else {
        UIImage *thumbImage = [UIImage imageWithCGImage:self.alAsset.thumbnail];
        if (!thumbImage) {
            thumbImage = self.alAsset.aspectRatioThumbnailImage;
        }
        [self.imageButton setImage:thumbImage forState:UIControlStateNormal];
    }
    
    self.checkButton.selected = selected;
    [self reloadCheckButtonBgColor];
}

- (IBAction)imageButtonAction:(UIButton *)sender
{
    if (!self.asset) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoDidClickedInCollectionCell:)]) {
        [self.delegate photoDidClickedInCollectionCell:self];
    }
}

- (void)checkButtonAction:(UIButton *)sender
{
    if (!self.asset) return;
    
    BOOL selected = !sender.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionCell:canSelect:)]) {
        if (![self.delegate collectionCell:self canSelect:selected]) return;
    }
    
    self.checkButton.selected = selected;
    [self reloadCheckButtonBgColor];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionCell:didSelect:)]) {
        [self.delegate collectionCell:self didSelect:selected];
    }
}

- (void)handleTapGestureAtPoint:(CGPoint)point
{
    CGRect checkRect = self.checkButton.frame;
    checkRect.origin.x -= 30;
    checkRect.origin.y = 0;
    checkRect.size.width += 30+10;
    checkRect.size.height += 30;
    
    if (CGRectContainsPoint(checkRect, point)) {
        [self checkButtonAction:self.checkButton];
    } else {
        [self imageButtonAction:self.imageButton];
    }
}

@end
