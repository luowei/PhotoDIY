//
//  Categorys.h
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Categorys : NSObject

@end


@interface UIView (FindUIViewController)

-(id)superViewWithClass:(Class)clazz;

@end


@interface UIView (Rotation)

- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end