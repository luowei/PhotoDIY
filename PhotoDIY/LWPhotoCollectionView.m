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
    self.photoURLs = @[].mutableCopy;
}

- (void)reloadPhotos {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize itemSize = CGSizeMake(80 * scale, 100 * scale);
//    self.photoPicker = [[PDPhotoLibPicker alloc] initWithDelegate:self itemSize:itemSize];

//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *inStop) {
//                    if (asset) {
//
//                    }
//                }
//                ];
//            }
//                         failureBlock:^(NSError *error) {
//
//                         }
//    ];


    __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (!group) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                [weakSelf reloadData];
            });
        } else {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *inStop) {
                if (result == nil || ![[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    return;
                }
                NSURL *url = (NSURL *) [[result defaultRepresentation] url];
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [weakSelf.photoURLs addObject:url];
                });


            }];
            [assetGroups addObject:group];
        }
    }                         failureBlock:^(NSError *error) {
        NSLog(@"There is an error");
    }];
//}
}


- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.topLine.hidden = hidden;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.photoURLs && self.photoURLs.count > 0) {
        NSLog(@"==========%lu", (unsigned long) self.photoURLs.count);
        NSLog(@"==========%lu", (unsigned long) self.photoDict.count);
        return self.photoURLs.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LWPhotoCollectionCell" forIndexPath:indexPath];
    if (self.photoURLs && self.photoURLs.count > 0) {
//        NSString *urlString = self.photoDict.allKeys[indexPath.item];
//        NSURL *url = [NSURL URLWithString:urlString];

        NSURL *url = self.photoURLs[indexPath.item];

        __weak typeof(self) weakSelf = self;
//        

        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        dispatch_async(queue, ^{
            [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
                CGImageRef cgImage = [[asset defaultRepresentation] fullScreenImage];
                if (cgImage) {
                    UIImage *image = [PDPhotoLibPicker imageWithImage:[UIImage imageWithCGImage:cgImage]
                                                         scaledToSize:cell.imageView.bounds.size];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        weakSelf.photoDict[url.absoluteString] = image;
                        cell.url = url;
                        cell.imageView.image = image;
                    });
                }
                dispatch_semaphore_signal(sema);
            }            failureBlock:^(NSError *error) {
                dispatch_semaphore_signal(sema);
            }];
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }

    return cell;
}


#pragma mark - PDPhotoPickerProtocol 实现

- (void)allPhotosCollected:(NSDictionary *)photoDic {
    //write your code here after getting all the photos from library...
    NSLog(@"all pictures are %@", self.photoDict.allValues);

    self.photoDict = photoDic;

    [self reloadData];
}

- (void)allPhotoURLsCollected:(NSArray *)urls {
    self.photoURLs = urls;
}


- (void)loadPhoto:(UIImage *)image {

}


@end


@implementation LWPhotoCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView = (UIImageView *) [self viewWithTag:101];
}


@end
