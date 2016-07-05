//
//  LWPhotoCollectionView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDPhotoLibPicker.h"

@interface LWPhotoCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PDPhotoPickerProtocol>

@property(nonatomic,strong) IBOutlet UIView *topLine;
@property(nonatomic,strong) IBOutlet NSLayoutConstraint *photoCollectionHeight;

@property(nonatomic, strong) PDPhotoLibPicker *photoPicker;

@property(nonatomic, strong) NSMutableDictionary *photoDict;
@property(nonatomic, strong) NSMutableArray *photoURLs;

@property(nonatomic, strong) ALAssetsLibrary *library;

- (void)reloadPhotos;
@end


@interface LWPhotoCollectionCell : UICollectionViewCell

@property(nonatomic, strong) IBOutlet UIImageView *imageView;

@property(nonatomic, strong) NSURL *url;
@end