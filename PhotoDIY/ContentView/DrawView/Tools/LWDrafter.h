//
// Created by luowei on 16/10/8.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//绘制笔类型
typedef NS_OPTIONS(NSUInteger, DrawType) {
    Hand = 1,
    Erase = 1 << 1,
    Line = 1 << 2,
    LineArrow = 1 << 3,
    Rectangle = 1 << 4,
    Oval = 1 << 5,
    Text = 1 << 6,
    EmojiTile = 1 << 7,
    ImageTile = 1 << 8,
};

typedef NS_OPTIONS(NSUInteger, DrawStatus){
    Drawing = 1,   //绘制中
    Editing = 2,   //编辑中
};

@interface LWDrafter : NSObject

@property (nonatomic, strong) NSMutableArray *pointArr;

@property (nonatomic, assign) NSInteger colorIndex;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic,assign) DrawType drawType;


@property(nonatomic, assign) NSInteger tileImageIndex;
@property(nonatomic, strong) NSURL *tileImageUrl;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *fontName;
@property(nonatomic, assign) CGRect rect;
@property(nonatomic) BOOL isEditing;
@property(nonatomic) BOOL isNew;

@property(nonatomic) CGFloat rotateAngle;
//EmojiTile/ImageTile
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSNumber *> *rotateAngleDict; //{"x,y":"45"}

@property(nonatomic, strong) NSShadow *shadow;

-(UIColor *)color;
-(CGSize)burshSize;

@end