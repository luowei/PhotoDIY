//
//  LWPhotoCollectionView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWPhotoCollectionView.h"
#import "LWFilterManager.h"
#import "Categorys.h"
#import "LWContentView.h"

@implementation LWPhotoCollectionView {
    NSIndexPath *_selectedIndexPath;
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
        self.photoPicker = [[PDPhotoLibPicker alloc] initWithDelegate:self];
    }
    self.photoPicker.delegate = self;
    [self.photoPicker getAllPicturesWithItemSize:itemSize];

}


- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.topLine.hidden = hidden;
    if(!hidden){
        [self reloadData];
    }
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
        UIImage *image = self.photoPicker.photoDict[urlString];
        cell.imageView.image = image;
        cell.imageView.highlightedImage = image;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *pathes = collectionView.indexPathsForSelectedItems;
//    [pathes enumerateObjectsUsingBlock:^(NSIndexPath *path, NSUInteger idx, BOOL *stop) {
//
//    }];

    LWPhotoCollectionCell *cel = (LWPhotoCollectionCell *)cell;
    if(_selectedIndexPath != nil && _selectedIndexPath.item == indexPath.item){
        cel.selectIcon.hidden = NO;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }else{
        cel.selectIcon.hidden = YES;
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LWPhotoCollectionCell *cell = (LWPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    cell.selected = YES;
    cell.selectIcon.hidden = NO;
    _selectedIndexPath = indexPath;

    LWContentView *drawView = [self superViewWithClass:[LWContentView class]];
    PDPhotoLibPicker *photoPicker = [[PDPhotoLibPicker alloc] initWithDelegate:drawView];
    [photoPicker pictureWithURL:cell.url];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    LWPhotoCollectionCell *cell = (LWPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    cell.selected = NO;
    cell.selectIcon.hidden = YES;
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
    [self.loadingIndicator stopAnimating];
    self.msgView.hidden = NO;
}


#pragma mark - Action

-(IBAction)settingAction:(UIButton *)btn{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

-(IBAction)reloadAction:(UIButton *)btn{
    [self reloadPhotos];
}

@end


@implementation LWPhotoCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView = (UIImageView *) [self viewWithTag:101];
}


@end
