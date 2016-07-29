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


@interface UIView(Recursive)

-(id)superViewWithClass:(Class)clazz;

- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation;

-(void)didLayoutSubviews;

@end