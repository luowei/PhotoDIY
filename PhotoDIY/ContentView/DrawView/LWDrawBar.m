//
// Created by luowei on 16/10/11.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWDrawBar.h"
#import "MyExtensions.h"
#import "Categorys.h"
#import "LWDrawView.h"
#import "LWScrawlView.h"


#pragma mark - LWDrawBar

@implementation LWDrawBar {

}

- (void)awakeFromNib {
    [super awakeFromNib];

}


@end

#pragma mark - LWDrawToolsView

//画板工具的选择
@implementation LWDrawToolsView {

}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 15;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWToolsCell *cell = (LWToolsCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolCell" forIndexPath:indexPath];
    switch (indexPath.item) {
        case 0: {    //黑笔
            [cell.btn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"pen_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 1: {    //红笔
            [cell.btn setImage:[[UIImage imageNamed:@"pen"] imageWithTintColor:[UIColor redColor]] forState:UIControlStateNormal];
            [cell.btn setImage:[[UIImage imageNamed:@"pen_selected"] imageWithTintColor:[UIColor redColor] blendMode:kCGBlendModeDestinationAtop] forState:UIControlStateHighlighted];
            break;
        }
        case 2: {    //绿笔
            [cell.btn setImage:[[UIImage imageNamed:@"pen"] imageWithTintColor:[UIColor greenColor]] forState:UIControlStateNormal];
            [cell.btn setImage:[[UIImage imageNamed:@"pen_selected"] imageWithTintColor:[UIColor greenColor] blendMode:kCGBlendModeDestinationAtop] forState:UIControlStateHighlighted];
            break;
        }
        case 3: {    //蓝笔
            [cell.btn setImage:[[UIImage imageNamed:@"pen"] imageWithTintColor:[UIColor blueColor]] forState:UIControlStateNormal];
            [cell.btn setImage:[[UIImage imageNamed:@"pen_selected"] imageWithTintColor:[UIColor blueColor] blendMode:kCGBlendModeDestinationAtop] forState:UIControlStateHighlighted];
            break;
        }
        case 4: {    //彩笔
            [cell.btn setImage:[UIImage imageNamed:@"penColor"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"penColor_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 5: {    //纹底笔
            [cell.btn setImage:[UIImage imageNamed:@"penTile"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"penTile_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 6: {    //橡皮
            [cell.btn setImage:[UIImage imageNamed:@"eraser"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"eraser_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 7: {    //小画笔
            [cell.btn setImage:[UIImage imageNamed:@"dotSmall"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"dotSmall_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 8: {    //中画笔
            [cell.btn setImage:[UIImage imageNamed:@"dotMiddle"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"dotMiddle_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 9: {    //大画笔
            [cell.btn setImage:[UIImage imageNamed:@"dotLarge"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"dotLarge_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 10: {   //直线
            [cell.btn setImage:[UIImage imageNamed:@"line"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"line_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 11: {   //箭头
            [cell.btn setImage:[UIImage imageNamed:@"lineArrow"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"lineArrow_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 12: {   //矩形
            [cell.btn setImage:[UIImage imageNamed:@"rect"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"rect_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 13: {   //圆圈
            [cell.btn setImage:[UIImage imageNamed:@"oval"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"oval_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 14: {   //文字
            [cell.btn setImage:[UIImage imageNamed:@"text"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"text_selected"] forState:UIControlStateHighlighted];
            break;
        }
        default:
            break;
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWToolsCell *cell = (LWToolsCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolCell" forIndexPath:indexPath];

    LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];
    

    switch (indexPath.item) {
        case 0: {    //黑笔
            drawView.scrawlView.freeInkColorIndex = 5;
            break;
        }
        case 1: {    //红笔
            drawView.scrawlView.freeInkColorIndex = 18;
            break;
        }
        case 2: {    //绿笔
            drawView.scrawlView.freeInkColorIndex = 88;
            break;
        }
        case 3: {    //蓝笔
            drawView.scrawlView.freeInkColorIndex = 168;
            break;
        }
        case 4: {    //彩笔
            LWDrawBar *drawBar = [self superViewWithClass:[LWDrawBar class]];
            drawBar.colorSelectorView.hidden = NO;
            break;
        }
        case 5: {    //纹底笔
            drawView.scrawlView.isTile = YES;
            break;
        }
        case 6: {    //橡皮
            drawView.scrawlView.isEraseMode = YES;
            break;
        }
        case 7: {    //小画笔
            drawView.scrawlView.freeInkLinewidth = 3.0;
            break;
        }
        case 8: {    //中画笔
            drawView.scrawlView.freeInkLinewidth = 6.0;
            break;
        }
        case 9: {    //大画笔
            drawView.scrawlView.freeInkLinewidth = 12.0;
            break;
        }
        case 10: {   //直线
            drawView.scrawlView.isLine = YES;
            break;
        }
        case 11: {   //箭头
            drawView.scrawlView.isLineArrow = YES;
            break;
        }
        case 12: {   //矩形
            drawView.scrawlView.isRect = YES;
            break;
        }
        case 13: {   //圆圈
            drawView.scrawlView.isOval = YES;
            break;
        }
        case 14: {   //文字
            drawView.scrawlView.isText = YES;
            break;
        }
        default:
            break;
    }
}


@end

#pragma mark - LWToolsCell

@implementation LWToolsCell

-(IBAction)btnAction:(UIButton *)btn{
    LWDrawToolsView *toolsView = [self superViewWithClass:[LWDrawToolsView class]];
    NSIndexPath *indPath = [toolsView indexPathForCell:self];
    [toolsView.delegate collectionView:toolsView didSelectItemAtIndexPath:indPath];
}

@end


#pragma mark - LWColorSelectorView

//画笔颜色选择
@implementation LWColorSelectorView {

}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return Color_Items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWColorCell *cell = (LWColorCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    cell.colorView.backgroundColor = [UIColor colorWithHexString:Color_Items[(NSUInteger) indexPath.item]];
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LWColorCell *cell = (LWColorCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    LWDrawView *drawView = [self superViewWithClass:[LWDrawView class] ];
    drawView.scrawlView.freeInkColorIndex = indexPath.item;
    self.hidden = YES;
}

@end

#pragma mark - LWColorCell

@implementation LWColorCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.colorView.layer.borderWidth = 2.0;
    self.colorView.layer.borderColor = [UIColor colorWithHexString:@"#A1A1A1"].CGColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UIColor *color = self.colorView.backgroundColor;
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    CGFloat alpha = CGColorGetAlpha(color.CGColor);
    self.colorView.backgroundColor = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:alpha/2];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UIColor *color = self.colorView.backgroundColor;
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    self.colorView.backgroundColor = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:1.0];
}


@end
