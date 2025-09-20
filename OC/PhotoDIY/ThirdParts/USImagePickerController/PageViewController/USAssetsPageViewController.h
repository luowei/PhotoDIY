//
//  USAssetsPageViewController.h
//  USImagePickerController
//
//  Created by marujun on 16/6/27.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "USAssetScrollView.h"

typedef void (^USAssetsPageIndexHandler)(NSInteger index);
typedef void (^USAssetsPageReloadHandler)(USAssetScrollView *weak_view, id weak_asset);

@interface USAssetsPageViewController : UIPageViewController

/** 当前展示的照片的顺序 */
@property (nonatomic, assign) NSInteger pageIndex;

/** 当前展示的照片的位置 */
@property (nonatomic, assign, readonly) CGRect imageRect;

/** 当前展示的照片次序发生变化时的回调处理 */
@property (nonatomic, copy) USAssetsPageIndexHandler indexChangedHandler;

/** 单击屏幕事件的回调处理 */
@property (nonatomic, copy) USAssetsPageIndexHandler singleTapHandler;

/** 重新加载 ItemPageViewController 时的回调处理，TODO: 设置该属性的代码必须在设置pageIndex之前！！！ */
@property (nonatomic, copy) USAssetsPageReloadHandler reloadItemHandler;

- (instancetype)initWithAssets:(NSArray *)assets;

@end
