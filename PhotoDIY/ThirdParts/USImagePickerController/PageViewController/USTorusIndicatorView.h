//
//  USTorusIndicatorView.h
//  USImagePickerController
//
//  Created by marujun on 2016/11/16.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USTorusIndicatorView : UIView

@property(nonatomic) BOOL hidesWhenStopped;      // default is YES. calls -setHidden when animating gets set to NO

@property(nonatomic, readonly) BOOL isAnimating;

- (void)startAnimating;
- (void)stopAnimating;

@end
