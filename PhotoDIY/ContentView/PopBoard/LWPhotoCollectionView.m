//
//  LWPhotoCollectionView.m
//  PhotoDIY
//
//  Created by luowei on 16/7/5.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWPhotoCollectionView.h"
#import "LWDataManager.h"
#import "Categorys.h"
#import "LWContentView.h"
#import "SDImageCache.h"

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
//    [self.photoPicker getAllPicturesWithItemSize:itemSize];
    [self.photoPicker getAllPicturesURL];

}


- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.topLine.hidden = hidden;
    if(!hidden){
        [self reloadData];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.photoPicker && self.photoPicker.photoURLs && self.photoPicker.photoURLs.count > 0) {
        NSLog(@"==========%lu", (unsigned long) self.photoPicker.photoURLs.count);
        return self.photoPicker.photoURLs.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LWPhotoCollectionCell" forIndexPath:indexPath];
    if (self.photoPicker && self.photoPicker.photoURLs && self.photoPicker.photoURLs.count > 0) {
//        NSString *urlString = self.photoPicker.photoURLs[indexPath.item];
//        NSURL *url = [NSURL URLWithString:urlString];

        NSURL *url = self.photoPicker.photoURLs[indexPath.item];
        cell.url = url;

        //从缓存目录找,没有才去相册加载
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        if([imageCache diskImageExistsWithKey:url.absoluteString]){
            UIImage *image = [imageCache imageFromDiskCacheForKey:url.absoluteString];
            cell.imageView.image = image;
            cell.imageView.highlightedImage = image;
        }else{
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize itemSize = CGSizeMake(80 * scale, 100 * scale);
            [self.photoPicker pictureWithURL:url size:itemSize imageBlock:^(UIImage *image){
                dispatch_async(dispatch_get_main_queue(), ^() {
                    cell.imageView.image = image;
                    cell.imageView.highlightedImage = image;
                    [[SDImageCache sharedImageCache] storeImage:image forKey:url.absoluteString toDisk:YES];
                });
            }];
        }
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

- (void)allURLPicked:(NSArray *)urls {
    [self reloadData];
    [self.loadingIndicator stopAnimating];
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
