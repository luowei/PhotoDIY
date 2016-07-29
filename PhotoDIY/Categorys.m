//
//  Categorys.m
//  PhotoDIY
//
//  Created by luowei on 16/7/4.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "Categorys.h"

@implementation Categorys

@end


@implementation UIView(Recursive)

//获得指class类型的父视图
-(id)superViewWithClass:(Class)clazz{
    UIResponder *responder = self;
    while (![responder isKindOfClass:clazz]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return responder;
}

//递归的向子视图发送屏幕发生旋转了的消息
- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    for (UIView *v in self.subviews) {
        [v rotationToInterfaceOrientation:orientation];
    }
}

//VC的viewDidLayoutSubviews递归地往下调
-(void)didLayoutSubviews{

    for(UIView *v in self.subviews){
        [v didLayoutSubviews];
    }

}

@end
