//
// Created by luowei on 16/10/11.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FDStackView.h"

@class LWDrawToolsView;
@class LWColorSelectorView;


@interface UIColor(HexString)

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end


#define Color_Items @[@"#FFFFFF",@"#CCCCCC",@"#999999",@"#666666",@"#333333",@"#000000",@"#FFCCCC",@"#CC9999",  \
@"#996666",@"#663333",@"#330000",@"#FF9999",@"#CC6666",@"#CC3333",@"#993333",@"#660000",@"#FF6666",@"#FF3333",\
@"#FF0000",@"#CC0000",@"#990000",@"#FF9966",@"#FF6633",@"#FF3300",@"#CC3300",@"#993300",@"#FFCC99",@"#CC9966",\
@"#CC6633",@"#996633",@"#663300",@"#FF9933",@"#FF6600",@"#FF9900",@"#CC6600",@"#CC9933",@"#FFCC66",@"#FFCC33",\
@"#FFCC00",@"#CC9900",@"#996600",@"#FFFFCC",@"#CCCC99",@"#999966",@"#666633",@"#333300",@"#FFFF99",@"#CCCC66",\
@"#CCCC33",@"#999933",@"#666600",@"#FFFF66",@"#FFFF33",@"#FFFF00",@"#CCCC00",@"#999900",@"#CCFF66",@"#CCFF33",\
@"#CCFF00",@"#99CC00",@"#669900",@"#CCFF00",@"#99CC66",@"#99CC33",@"#669933",@"#336600",@"#99FF33",@"#99FF00",\
@"#66FF00",@"#66CC00",@"#66CC33",@"#99FF66",@"#66FF33",@"#33FF00",@"#33CC00",@"#339900",@"#CCFFCC",@"#99CC99",\
@"#669966",@"#336633",@"#003300",@"#99FF99",@"#66CC66",@"#33CC33",@"#339933",@"#006600",@"#66FF66",@"#33FF33",\
@"#00FF00",@"#00CC00",@"#009900",@"#66FF99",@"#33FF66",@"#00FF33",@"#00CC33",@"#009933",@"#99FFCC",@"#66CC99",\
@"#33CC66",@"#339966",@"#006633",@"#33FF99",@"#00FF66",@"#00FF99",@"#00CC66",@"#33CC99",@"#66FFCC",@"#33FFCC",\
@"#00FFCC",@"#00CC99",@"#009966",@"#CCFFFF",@"#99CCCC",@"#669999",@"#336699",@"#003333",@"#99FFFF",@"#66CCCC",\
@"#99CCCC",@"#339999",@"#006666",@"#66FFFF",@"#33FFFF",@"#00FFFF",@"#00CCCC",@"#009999",@"#66CCFF",@"#33CCFF",\
@"#00CCFF",@"#0099CC",@"#006699",@"#99CCFF",@"#6699CC",@"#3399CC",@"#336699",@"#003366",@"#3399FF",@"#0099FF",\
@"#0066FF",@"#0066CC",@"#3366CC",@"#6699FF",@"#3366FF",@"#0033FF",@"#0033CC",@"#003399",@"#CCCCFF",@"#9999CC",\
@"#666699",@"#333366",@"#000033",@"#9999FF",@"#6666CC",@"#3333CC",@"#333399",@"#000066",@"#6666FF",@"#3333FF",\
@"#0000FF",@"#0000CC",@"#000099",@"#9966FF",@"#6633FF",@"#3300FF",@"#3300FF",@"#330099",@"#CC99FF",@"#9966CC",\
@"#6633CC",@"#663399",@"#330066",@"#9933FF",@"#6600FF",@"#9900FF",@"#6600CC",@"#9933CC",@"#CC66FF",@"#CC33FF",\
@"#CC00FF",@"#9900CC",@"#660099",@"#FFCCFF",@"#CC99CC",@"#996699",@"#663366",@"#330033",@"#FF99FF",@"#CC66CC",\
@"#CC33CC",@"#993399",@"#660066",@"#FF66FF",@"#FF33FF",@"#FF00FF",@"#CC00CC",@"#990099",@"#FF66CC",@"#FF33CC",\
@"#FF00CC",@"#CC0099",@"#990066",@"#FF99CC",@"#CC6699",@"#CC3399",@"#993366",@"#660033",@"#FF3399",@"#FF0099",\
@"#FF0066",@"#CC0066",@"#CC3366",@"#FF6699",@"#FF3366",@"#FF0033",@"#CC0033",@"#990033"]


@interface LWDrawBar : UIView

@property(nonatomic,weak) IBOutlet LWDrawToolsView *drawToolsView;
@property(nonatomic,weak) IBOutlet LWColorSelectorView *colorSelectorView;


@end

#pragma mark - LWDrawToolsView

@interface LWDrawToolsView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@interface LWToolsCell:UICollectionViewCell

@property(nonatomic,weak) IBOutlet UIButton *btn;

@end


#pragma mark - LWColorSelectorView

@interface LWColorSelectorView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@interface LWColorCell:UICollectionViewCell

@property(nonatomic,weak) IBOutlet UIView *colorView;

@end