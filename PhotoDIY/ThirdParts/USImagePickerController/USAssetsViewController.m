//
//  USAssetsViewController.m
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetsViewController.h"
#import "USAssetCollectionCell.h"
#import "USAssetsPageViewController.h"
#import "USAssetsPreviewViewController.h"
#import "RSKImageCropViewController.h"

#define MinAssetItemLength     80.f
#define AssetItemSpace         2.f

@interface USAssetsViewController () <USAssetCollectionCellDelegate, USAssetsPreviewViewControllerDelegate, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

//底部状态栏
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countWidthConstraint;

@property (nonatomic, strong) NSMutableArray *allAssets;

//PHAsset 生成缩略图及缓存时需要的数据
@property (nonatomic, assign) CGRect previousPreheatRect;
@property (nonatomic, assign) CGSize thumbnailTargetSize;
@property (nonatomic, strong) PHImageRequestOptions *thumbnailRequestOptions;

@property (nonatomic, assign) BOOL didLayoutSubviews;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation USAssetsViewController

- (USImagePickerController *)picker {
    return (USImagePickerController *)self.navigationController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupViews];
    
    [self setupAssets];
    [self resetCachedAssetImages];
    
    [self refreshTitle];
    
    [self.collectionView layoutIfNeeded];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.didLayoutSubviews && self.allAssets.count){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.allAssets.count-1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        
        self.didLayoutSubviews = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateCachedAssetImages];
}

- (void)refreshTitle
{
    if (self.assetCollection) self.title = self.assetCollection.localizedTitle;
    else self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    NSInteger count = self.selectedAssets.count;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",count];
    self.countLabel.hidden = count?NO:YES;
    self.sendButton.alpha = count?1:0.5;
    self.previewButton.alpha = count?1:0.5;
    self.bottomBar.userInteractionEnabled = count?YES:NO;
}


#pragma mark - Setup

- (void)setupViews
{
    CGFloat containerWidth = self.picker.view.frame.size.width;
    
    NSInteger lineMaxCount = 1;
    while ((lineMaxCount*MinAssetItemLength+(lineMaxCount+1)*AssetItemSpace) <= containerWidth) {
        lineMaxCount ++;
    }
    lineMaxCount --;
    
    lineMaxCount = MAX(4, lineMaxCount);  //一排最少4个
    CGFloat itemLength = floorf((containerWidth-AssetItemSpace*(lineMaxCount-1))/lineMaxCount);
    
    self.flowLayout.itemSize = CGSizeMake(itemLength, itemLength);
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = AssetItemSpace;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 0, 8, 0);
    
    if (PHPhotoLibraryClass) {
        _thumbnailRequestOptions = [[PHImageRequestOptions alloc] init];
        _thumbnailRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _thumbnailRequestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        
        NSInteger retinaMultiplier  = MIN([UIScreen mainScreen].scale, 2);
        _thumbnailTargetSize = CGSizeMake(self.flowLayout.itemSize.width * retinaMultiplier, self.flowLayout.itemSize.height * retinaMultiplier);
        _thumbnailTargetSize = [PHAsset targetSizeByCompatibleiPad:_thumbnailTargetSize];
    }
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    NSString *identifier = NSStringFromClass([USAssetCollectionCell class]);
    UINib *cellNib = [UINib nibWithNibName:identifier bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:identifier];
    
    NSInteger topInset = 0;
    if (self.picker.navigationBar.isTranslucent) {
        topInset = 64;
    }
    
    if(self.picker.allowsMultipleSelection){
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self.collectionView addGestureRecognizer:_tapGestureRecognizer];
        
        self.countLabel.backgroundColor = self.picker.tintColor;
        self.countLabel.layer.cornerRadius = self.countLabel.frame.size.height/2.f;
        self.countLabel.layer.masksToBounds = YES;
        [self.sendButton setTitleColor:self.picker.tintColor forState:UIControlStateNormal];
        [self.collectionView setContentInset:UIEdgeInsetsMake(topInset, 0, self.bottomBar.frame.size.height, 0)];
    }
    else {
        self.bottomBar.hidden = YES;
        [self.collectionView setContentInset:UIEdgeInsetsMake(topInset, 0, 0, 0)];
    }
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(rightNavButtonAction:)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 2;  //向左移动2个像素
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,buttonItem];
    
    if (self.picker.returnKey) {
        [self.sendButton setTitle:self.picker.returnKey forState:UIControlStateNormal];
    }
}

- (void)rightNavButtonAction:(UIButton *)sender
{
    if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.picker.delegate imagePickerControllerDidCancel:self.picker];
    } else {
        [self.picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setupAssets
{
    self.allAssets = [[NSMutableArray alloc] init];
    
    if (self.assetCollection) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
        //options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
        
        PHAssetCollection *assetCollection = (PHAssetCollection *)self.assetCollection;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        NSArray *fetchArray = [fetchResult objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, fetchResult.count)]];
        [self.allAssets addObjectsFromArray:fetchArray];
        
        return;
    }
    
    [self.indicatorView startAnimating];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset) {
            if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [self.allAssets addObject:asset];
            }
        }
        else {
            [self.indicatorView stopAnimating];
            [self.collectionView reloadData];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

- (NSArray *)selectedAssetsArray
{
    NSMutableArray *tmpArray= [NSMutableArray array];
    [_allAssets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([_selectedAssets containsObject:obj]) [tmpArray addObject:obj];
    }];
    return tmpArray;
}

- (CGRect)imageRectWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    CGRect rect = [_flowLayout layoutAttributesForItemAtIndexPath:indexPath].frame;
    
    return [self.collectionView convertRect:rect toView:self.view];
}

- (void)scrollIndexToVisible:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    NSArray *visibleArray = [self.collectionView indexPathsForVisibleItems];
    if (![visibleArray containsObject:indexPath]) {
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }
}

#pragma mark - BottomBar button action
- (IBAction)previewButtonAction:(UIButton *)sender
{
    USAssetsPreviewViewController *previewVC = [[USAssetsPreviewViewController alloc] initWithAssets:self.selectedAssetsArray];
    previewVC.selectedAssets = self.selectedAssets;
    previewVC.delegate = self;
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (IBAction)sendButtonAction:(UIButton *)sender
{
    if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithAssets:)]) {
        [self.picker.delegate imagePickerController:self.picker didFinishPickingMediaWithAssets:self.selectedAssetsArray];
    } else {
        [self.picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITapGestureRecognizer
- (void)handleTapGesture: (UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if (!indexPath) return;
    
    USAssetCollectionCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        [cell handleTapGestureAtPoint:[recognizer locationInView:cell]];
    }
}

- (void)oneAsset:(id)asset didSelect:(BOOL)selected
{
    if (selected) [self.selectedAssets addObject:asset];
    else [self.selectedAssets removeObject:asset];
    
    [self refreshTitle];
}

- (void)pushImageCropViewController:(id)asset
{
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:[asset aspectRatioThumbnailImage]
                                                                                       cropMode:RSKImageCropModeCustom];
    imageCropVC.maskLayerStrokeColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    imageCropVC.delegate = self;
    imageCropVC.dataSource = self;
    imageCropVC.avoidEmptySpaceAroundImage = YES;
    imageCropVC.portraitMoveAndScaleLabelTopAndCropViewTopVerticalSpace = 40;
    [self.navigationController pushViewController:imageCropVC animated:YES];
    
    imageCropVC.chooseButton.userInteractionEnabled = NO;
    imageCropVC.moveAndScaleLabel.text = nil;
    [imageCropVC.moveAndScaleLabel performSelector:@selector(setText:) withObject:@"图片加载中…" afterDelay:1.f];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *hdImage = [asset thumbnailImageWithMaxPixelSize:USFullScreenImageMaxPixelSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageCropVC.moveAndScaleLabel.alpha = 0;
            
            imageCropVC.originalImage = hdImage;
            imageCropVC.chooseButton.userInteractionEnabled = YES;
        });
    });
}

#pragma mark - USAssetCollectionCellDelegate
- (void)photoDidClickedInCollectionCell:(USAssetCollectionCell *)cell
{
    NSInteger itemIndex = [_collectionView indexPathForCell:cell].row;
    
    if (self.picker.allowsMultipleSelection) {
        USAssetsPreviewViewController *previewVC = [[USAssetsPreviewViewController alloc] initWithAssets:_allAssets];
        previewVC.selectedAssets = self.selectedAssets;
        previewVC.delegate = self;
        previewVC.pageIndex = itemIndex;
        [self.navigationController pushViewController:previewVC animated:YES];
    }
    else if (self.picker.allowsEditing) {
        id asset = _allAssets[itemIndex];
        [self pushImageCropViewController:asset];
    }
    else {
        if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithAsset:)]) {
            [self.picker.delegate imagePickerController:self.picker didFinishPickingMediaWithAsset:_allAssets[itemIndex]];
        }
        
        if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithImage:)]) {
            UIImage *selectedImage = [_allAssets[itemIndex] thumbnailImageWithMaxPixelSize:USFullScreenImageMaxPixelSize];
            [self.picker.delegate imagePickerController:self.picker didFinishPickingMediaWithImage:selectedImage];
        }
    }
}

- (BOOL)collectionCell:(USAssetCollectionCell *)cell canSelect:(BOOL)selected
{
    if (selected && self.selectedAssets.count >= self.picker.maxSelectNumber) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:[NSString stringWithFormat:@"你最多只能选择%zd张照片",self.picker.maxSelectNumber]
                                   delegate:nil
                          cancelButtonTitle:@"我知道了"
                          otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}


- (void)collectionCell:(USAssetCollectionCell *)cell didSelect:(BOOL)selected
{
    [self oneAsset:cell.asset didSelect:selected];
}

#pragma mark - USAssetsPreviewViewControllerDelegate

- (BOOL)previewViewController:(USAssetsPreviewViewController *)vc canSelect:(BOOL)selected
{
    return [self collectionCell:nil canSelect:selected];
}

- (void)sendButtonClickedInPreviewViewController:(USAssetsPreviewViewController *)vc
{
    [self sendButtonAction:_sendButton];
}

- (void)previewViewController:(USAssetsPreviewViewController *)vc didSelect:(BOOL)selected
{
    [self oneAsset:vc.asset didSelect:selected];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([USAssetCollectionCell class]);
    USAssetCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.selectedColor = self.picker.tintColor;
    cell.imageManager = self.imageManager;
    cell.thumbnailTargetSize = self.thumbnailTargetSize;
    cell.thumbnailRequestOptions = self.thumbnailRequestOptions;
    cell.markView.hidden = !self.picker.allowsMultipleSelection;
    
    id asset = [self assetAtIndexPath:indexPath];
    [cell bind:asset selected:[self.selectedAssets containsObject:asset]];
    
    return cell;
}


#pragma mark - RSKImageCropViewControllerDelegate
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithImage:)]) {
        [self.picker.delegate imagePickerController:self.picker didFinishPickingMediaWithImage:croppedImage];
    } else {
        [self.picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - RSKImageCropViewControllerDataSource
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGSize ssize = controller.view.bounds.size;
    if (self.picker.cropMaskAspectRatio <= 0) self.picker.cropMaskAspectRatio = 1.f;
    
    CGFloat topEdge = 40.f;
    CGFloat bottomEdge = 40.f;
    if ([controller isPortraitInterfaceOrientation]) {
        topEdge += controller.portraitMoveAndScaleLabelTopAndCropViewTopVerticalSpace;
        bottomEdge += MAX(controller.portraitCropViewBottomAndCancelButtonBottomVerticalSpace, controller.portraitCropViewBottomAndChooseButtonBottomVerticalSpace);
    } else {
        topEdge += controller.landscapeMoveAndScaleLabelTopAndCropViewTopVerticalSpace;
        bottomEdge += MAX(controller.landscapeCropViewBottomAndCancelButtonBottomVerticalSpace, controller.landscapeCropViewBottomAndChooseButtonBottomVerticalSpace);
    }
    
    CGFloat maxWidth = ssize.width-controller.maskLayerLineWidth*2.f;
    CGFloat maxHeight = ssize.height - topEdge - bottomEdge;
    
    CGFloat tmpWidth = maxHeight * self.picker.cropMaskAspectRatio;
    
    CGSize csize;
    if (tmpWidth <= maxWidth) csize = CGSizeMake(tmpWidth, maxHeight);
    else csize = CGSizeMake(maxWidth, maxWidth / self.picker.cropMaskAspectRatio);
    
    if ((csize.height/2.f + MAX(topEdge, bottomEdge)) < ssize.height/2.f) {
        return CGRectMake((ssize.width-csize.width)/2.f, (ssize.height-csize.height)/2.f, csize.width, csize.height);
    }
    return CGRectMake((ssize.width-csize.width)/2.f, topEdge+(maxHeight-csize.height)/2.f, csize.width, csize.height);
}

// Returns a custom path for the mask.
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
    CGRect rect = [self imageCropViewControllerCustomMaskRect:controller];
    CGFloat inset = controller.maskLayerLineWidth/2.f;
    rect = CGRectMake(rect.origin.x-inset, rect.origin.y-inset, rect.size.width+2*inset, rect.size.height+2*inset);
    
    CGPoint point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint point2 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGPoint point3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGPoint point4 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:point1];
    [triangle addLineToPoint:point2];
    [triangle addLineToPoint:point3];
    [triangle addLineToPoint:point4];
    [triangle closePath];
    
    return triangle;
}

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
    return [self imageCropViewControllerCustomMaskRect:controller];
}

#pragma mark - Asset images caching

- (void)resetCachedAssetImages
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (NSArray *)indexPathsForElementsInRect:(CGRect)rect
{
    NSArray *allAttributes = [self.flowLayout layoutAttributesForElementsInRect:rect];
    
    if (allAttributes.count == 0)
        return nil;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allAttributes.count];
    
    for (UICollectionViewLayoutAttributes *attributes in allAttributes) {
        NSIndexPath *indexPath = attributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    
    return indexPaths;
}

- (void)updateCachedAssetImages
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    
    if (!isViewVisible)
        return;
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect) {
                                NSArray *indexPaths = [self indexPathsForElementsInRect:removedRect];
                                [removedIndexPaths addObjectsFromArray:indexPaths];
                            } addedHandler:^(CGRect addedRect) {
                                NSArray *indexPaths = [self indexPathsForElementsInRect:addedRect];
                                [addedIndexPaths addObjectsFromArray:indexPaths];
                            }];
        
        [self startCachingThumbnailsForIndexPaths:addedIndexPaths];
        [self stopCachingThumbnailsForIndexPaths:removedIndexPaths];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (id)assetAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if(index < 0 || index>=self.allAssets.count){
        return nil;
    }
    return [self.allAssets objectAtIndex:index];
}


- (void)startCachingThumbnailsForIndexPaths:(NSArray *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = [self assetAtIndexPath:indexPath];
        
        if (!asset) break;
        
        [self.imageManager startCachingImagesForAssets:@[asset]
                                            targetSize:_thumbnailTargetSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:_thumbnailRequestOptions];
    }
}

- (void)stopCachingThumbnailsForIndexPaths:(NSArray *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = [self assetAtIndexPath:indexPath];
        
        if (!asset) break;
        
        [self.imageManager stopCachingImagesForAssets:@[asset]
                                           targetSize:_thumbnailTargetSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:_thumbnailRequestOptions];
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.imageManager stopCachingImagesForAllAssets];
}

- (void)dealloc
{
    [self.imageManager stopCachingImagesForAllAssets];
    
    USPickerLog(@"dealloc 释放类 %@",  NSStringFromClass([self class]));
}

@end
