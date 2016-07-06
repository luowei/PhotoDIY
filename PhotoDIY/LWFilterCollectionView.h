//
//  LWFilterCollectionView.h
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWFilterCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) IBOutlet UIView *topLine;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property(nonatomic,strong) IBOutlet NSLayoutConstraint *photoCollectionHeight;

@end


@interface LWFilterCollectionCell : UICollectionViewCell

@property(nonatomic, strong) IBOutlet UIImageView *imageView;
@property(nonatomic, strong) IBOutlet UILabel *titleLbl;

@property(nonatomic,strong) IBOutlet UIImageView *selectIcon;

@end