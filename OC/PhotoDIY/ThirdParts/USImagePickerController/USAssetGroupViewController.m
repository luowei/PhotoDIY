//
//  USAssetGroupViewController.m
//  USImagePickerController
//
//  Created by marujun on 16/7/1.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "USAssetGroupViewController.h"
#import "USAssetGroupTableCell.h"
#import "USAssetsViewController.h"

@interface USAssetGroupViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIView *tipNoAssetsView;
@property (weak, nonatomic) IBOutlet UIView *tipNotAllowedView;
@property (weak, nonatomic) IBOutlet UIImageView *padlockImageView;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@property (nonatomic, strong) ALAssetsGroup *displayAssetsGroup;
@property (nonatomic, strong) PHAssetCollection *displayAssetCollection;

@property (nonatomic, strong) UIButton *rightNavButton;

@end

@implementation USAssetGroupViewController

- (USImagePickerController *)picker {
    return (USImagePickerController *)self.navigationController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"相簿", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _selectedAssets = [[NSMutableSet alloc] init];
    
    [self setupViews];
    [self setupGroup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_selectedAssets removeAllObjects];
}

#pragma mark - Setup

- (void)setupViews
{
    self.tableView.rowHeight = kThumbnailLength + 20;
    
    if (self.picker.navigationBar.isTranslucent) {
        [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    }
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain
                                    target:self action:@selector(rightNavButtonAction:)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = 8;  //向右移动8个像素
    
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,buttonItem];
    
    [self.view layoutIfNeeded];
    
    _padlockImageView.tintColor = RGBACOLOR(110, 116, 130, 1);
    _padlockImageView.image = [[UIImage imageNamed:@"USPicker-Assets-Locked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setupPHGroup
{
    [self.indicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *albums = [NSMutableArray array];
        
        void (^enumerateBlock)(id, NSUInteger, BOOL *) = ^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop){
            if (![collection respondsToSelector:@selector(assetCollectionSubtype)]) {
                return;
            }
            
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [albums insertObject:collection atIndex:0];
            }
            else if (collection.assetCollectionSubtype!=PHAssetCollectionSubtypeSmartAlbumVideos) {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
                
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
                if (result.count) {
                    [albums addObject:collection];
                }
            }
        };
        
        //列出所有的智能相册
        PHAssetCollectionSubtype subtype = PHAssetCollectionSubtypeAlbumRegular;
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subtype options:nil];
        [smartAlbums enumerateObjectsUsingBlock:enumerateBlock];
        
        //列出所有电脑导入的相册
        subtype = PHAssetCollectionSubtypeAlbumSyncedAlbum;
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:subtype options:nil];
        [syncedAlbums enumerateObjectsUsingBlock:enumerateBlock];
        
        //列出所有用户创建的相册
        PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        [userAlbums enumerateObjectsUsingBlock:enumerateBlock];
        
        //去掉【最近删除】相册
        [albums filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT localizedTitle IN %@",@[@"最近删除",@"Recently Deleted"]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.groups addObjectsFromArray:albums];
            
            if(!_tableView.accessibilityIdentifier){
                [self pushAssetViewController:0 animation:NO];
                
                _tableView.accessibilityIdentifier = @"HasAutoPushGroup";
            }
            
            [self.tableView reloadData];
            [self.indicatorView stopAnimating];
        });
    });
}

- (void)setupGroup
{
    if (!self.groups){
        self.groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    
    if (PHPhotoLibraryClass) {
        // 获取当前应用对照片的访问授权状态
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusRestricted || authorizationStatus == PHAuthorizationStatusDenied) {
            _tipNotAllowedView.hidden = NO;
            return;
        }
        
        if (authorizationStatus == PHAuthorizationStatusAuthorized) {
            [self setupPHGroup];
            return;
        }
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self performSelectorOnMainThread:@selector(setupPHGroup) withObject:nil waitUntilDone:NO];
            } else {
                [_tipNotAllowedView performSelectorOnMainThread:@selector(setHidden:) withObject:@(NO) waitUntilDone:NO];
            }
        }];
        
        return;
    }
    
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        _tipNotAllowedView.hidden = NO;
        return;
    }
    
    self.assetsLibrary = [USImagePickerController defaultAssetsLibrary];
    
    [self.indicatorView startAnimating];
    
    ALAssetsFilter *assetsFilter = self.picker.assetsFilter;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:assetsFilter];
            
            ALAssetsGroupType assetType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
            BOOL isCameraRollGroup = assetType == ALAssetsGroupSavedPhotos;  //是否是相机胶卷类型
            
            if (group.numberOfAssets > 0 || isCameraRollGroup){
                [self.groups addObject:group];
            }
        } else {
            if(!_tableView.accessibilityIdentifier) {
                [self pushAssetViewController:0 animation:NO];
                
                _tableView.accessibilityIdentifier = @"HasAutoPushGroup";
            }
            
            [self reloadData];
            [self.indicatorView stopAnimating];
        }
    };
    
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        _tipNotAllowedView.hidden = NO;
        
    };
    
    // Enumerate Camera roll first
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type =
    ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
    ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [self.assetsLibrary enumerateGroupsWithTypes:type
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
}

#pragma mark - Reload Data

- (void)reloadData
{
    if (self.groups.count == 0) {
        _tipNoAssetsView.hidden = NO;
    }
    
    [self.tableView reloadData];
}

- (void)rightNavButtonAction:(UIButton *)sender
{
    if (self.picker.delegate && [self.picker.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.picker.delegate imagePickerControllerDidCancel:self.picker];
    } else {
        [self.picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"USAssetGroupTableCell";
    
    USAssetGroupTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[USAssetGroupTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell bind:[self.groups objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self pushAssetViewController:indexPath.row animation:YES];
}

- (void)pushAssetViewController:(NSInteger)index animation:(BOOL)animation
{
    USAssetsViewController *vc = [[USAssetsViewController alloc] initWithNibName:@"USAssetsViewController" bundle:nil];
    if (PHPhotoLibraryClass) {
        vc.assetCollection = [self.groups objectAtIndex:index];
        vc.imageManager = [[PHCachingImageManager alloc] init];
        _displayAssetCollection = vc.assetCollection;
    }
    else {
        vc.assetsGroup = [self.groups objectAtIndex:index];
        _displayAssetsGroup = vc.assetsGroup;
    }
    
    vc.selectedAssets = self.selectedAssets;
    
    [self.navigationController pushViewController:vc animated:animation];
}

@end
