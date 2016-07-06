//
//  LWPhotoCollectionView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWPhotoCollectionView.h"
#import "LWFilterManager.h"

@implementation LWPhotoCollectionView {
}

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

    self.library = [[ALAssetsLibrary alloc] init];
}

- (void)reloadPhotos {
    [self.loadingIndicator startAnimating];

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize itemSize = CGSizeMake(80 * scale, 100 * scale);

    if(!self.photoPicker){
        self.photoPicker = [[PDPhotoLibPicker alloc] initWithDelegate:self itemSize:itemSize];
    }else{
        [self.photoPicker getAllPictures];
    }


}


- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.topLine.hidden = hidden;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.photoPicker && self.photoPicker.photoDict && self.photoPicker.photoDict.count > 0) {
        NSLog(@"==========%lu", (unsigned long) self.photoPicker.photoDict.count);
        return self.photoPicker.photoDict.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LWPhotoCollectionCell" forIndexPath:indexPath];
    if (self.photoPicker && self.photoPicker.photoDict && self.photoPicker.photoDict.count > 0) {
        NSString *urlString = self.photoPicker.photoDict.allKeys[indexPath.item];
        NSURL *url = [NSURL URLWithString:urlString];

        cell.url = url;
        cell.imageView.image = self.photoPicker.photoDict[urlString];
    }

    return cell;
}


#pragma mark - PDPhotoPickerProtocol 实现

- (void)allPhotosCollected:(NSDictionary *)photoDic {
    //write your code here after getting all the photos from library...
    NSLog(@"all pictures count: %ul", self.photoPicker.photoDict.allValues.count);

    [self reloadData];
    [self.loadingIndicator stopAnimating];
}

- (void)allPhotoURLsCollected:(NSArray *)urls {
}

- (void)loadPhoto:(UIImage *)image {
}

-(void)collectPhotoFailed{
    //self.msgView.hidden = NO;
}


@end


@implementation LWPhotoCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView = (UIImageView *) [self viewWithTag:101];
}


@end
