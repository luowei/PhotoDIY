//
//  LWFilterCollectionView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWFilterCollectionView.h"
#import "LWFilterManager.h"

@implementation LWFilterCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {

    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.dataSource = self;
    self.delegate = self;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.topLine.hidden = hidden;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 23;//[LWFilterManager filters].allKeys.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWFilterCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LWFilterCollectionCell" forIndexPath:indexPath];

    return cell;
}


@end


@implementation LWFilterCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView = (UIImageView *)[self viewWithTag:101];
    self.titleLbl = (UILabel *)[self viewWithTag:102];
}


@end
