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
    NSIndexPath *_sec1SelectedIndexPath;
    NSIndexPath *_sec2SelectedIndexPath;
    NSIndexPath *_sec3SelectedIndexPath;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 7;
        case 1:
            return 1;
        case 2:
            return 3;
        case 3:
            return 5;
        default:
            return 1;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWToolsCell *cell = (LWToolsCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolCell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.item) {
                case 0: {    //黑笔
                    [cell.btn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"pen_selected"] forState:UIControlStateHighlighted ];
                    [self sec1Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 1: {    //红笔
                    [cell.btn setImage:[[UIImage imageNamed:@"pen"] imageWithTintColor:[UIColor redColor]] forState:UIControlStateNormal];
                    [cell.btn setImage:[[UIImage imageNamed:@"pen_selected"] imageWithTintColor:[UIColor redColor] blendMode:kCGBlendModeDestinationAtop] forState:UIControlStateHighlighted ];
                    [self sec1Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 2: {    //绿笔
                    [cell.btn setImage:[[UIImage imageNamed:@"pen"] imageWithTintColor:[UIColor greenColor]] forState:UIControlStateNormal];
                    [cell.btn setImage:[[UIImage imageNamed:@"pen_selected"] imageWithTintColor:[UIColor greenColor] blendMode:kCGBlendModeDestinationAtop] forState:UIControlStateHighlighted ];
                    [self sec1Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 3: {    //蓝笔
                    [cell.btn setImage:[[UIImage imageNamed:@"pen"] imageWithTintColor:[UIColor blueColor]] forState:UIControlStateNormal];
                    [cell.btn setImage:[[UIImage imageNamed:@"pen_selected"] imageWithTintColor:[UIColor blueColor] blendMode:kCGBlendModeDestinationAtop] forState:UIControlStateHighlighted ];
                    [self sec1Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 4: {    //彩笔
                    [cell.btn setImage:[UIImage imageNamed:@"penColor"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"penColor_selected"] forState:UIControlStateHighlighted ];
                    [self sec1Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 5: {    //纹底笔
                    [cell.btn setImage:[UIImage imageNamed:@"penTile"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"penTile_selected"] forState:UIControlStateHighlighted ];
                    [self sec1Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 6: {    //橡皮
                    [cell.btn setImage:[UIImage imageNamed:@"eraser"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"eraser_selected"] forState:UIControlStateHighlighted ];
                    [self sec1Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                default:
                    break;
            }
            break;
        case 1:{
            [cell.btn setImage:[UIImage imageNamed:@"revoke"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"revoke_selected"] forState:UIControlStateHighlighted ];
            break;
        }
        case 2:
            switch (indexPath.item) {
                case 0: {    //小画笔
                    [cell.btn setImage:[UIImage imageNamed:@"dotSmall"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"dotSmall_selected"] forState:UIControlStateHighlighted ];
                    [self sec3Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 1: {    //中画笔
                    [cell.btn setImage:[UIImage imageNamed:@"dotMiddle"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"dotMiddle_selected"] forState:UIControlStateHighlighted ];
                    [self sec3Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 2: {    //大画笔
                    [cell.btn setImage:[UIImage imageNamed:@"dotLarge"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"dotLarge_selected"] forState:UIControlStateHighlighted ];
                    [self sec3Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.item) {
                case 0: {   //直线
                    [cell.btn setImage:[UIImage imageNamed:@"line"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"line_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 1: {   //箭头
                    [cell.btn setImage:[UIImage imageNamed:@"lineArrow"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"lineArrow_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 2: {   //矩形
                    [cell.btn setImage:[UIImage imageNamed:@"rect"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"rect_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 3: {   //圆圈
                    [cell.btn setImage:[UIImage imageNamed:@"oval"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"oval_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 4: {   //文字
                    [cell.btn setImage:[UIImage imageNamed:@"text"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"text_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }

                default:
                    break;
            }
            break;

        default:
            break;
    }

    return cell;
}

- (void)sec1Collection:(UICollectionView *)collectionView selIndexPath:(NSIndexPath *)indexPath cell:(LWToolsCell *)cell {
    if ((_sec1SelectedIndexPath != nil && _sec1SelectedIndexPath.item == indexPath.item) || (_sec1SelectedIndexPath == nil && indexPath.item == 0)) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        cell.highlighted = YES;
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        cell.highlighted = NO;
    }
}
- (void)sec3Collection:(UICollectionView *)collectionView selIndexPath:(NSIndexPath *)indexPath cell:(LWToolsCell *)cell {
    if ((_sec2SelectedIndexPath != nil && _sec2SelectedIndexPath.item == indexPath.item) || (_sec2SelectedIndexPath == nil && indexPath.item == 0)) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        cell.highlighted = YES;
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        cell.highlighted = NO;
    }
}
- (void)sec4Collection:(UICollectionView *)collectionView selIndexPath:(NSIndexPath *)indexPath cell:(LWToolsCell *)cell {
    if (_sec3SelectedIndexPath != nil && _sec3SelectedIndexPath.item == indexPath.item) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        cell.highlighted = YES;
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        cell.highlighted = NO;
    }
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWToolsCell *cell = (LWToolsCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolCell" forIndexPath:indexPath];

    LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.item) {
                case 0: {    //黑笔
                    drawView.scrawlView.drawType = Hand;
                    drawView.scrawlView.freeInkColorIndex = 5;
                    drawView.drawBar.colorTipView.backgroundColor = [UIColor colorWithHexString:Color_Items[5]];
                    [self sec1collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 1: {    //红笔
                    drawView.scrawlView.drawType = Hand;
                    drawView.scrawlView.freeInkColorIndex = 18;
                    drawView.drawBar.colorTipView.backgroundColor = [UIColor colorWithHexString:Color_Items[18]];
                    [self sec1collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 2: {    //绿笔
                    drawView.scrawlView.drawType = Hand;
                    drawView.scrawlView.freeInkColorIndex = 88;
                    drawView.drawBar.colorTipView.backgroundColor = [UIColor colorWithHexString:Color_Items[88]];
                    [self sec1collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 3: {    //蓝笔
                    drawView.scrawlView.drawType = Hand;
                    drawView.scrawlView.freeInkColorIndex = 158;
                    drawView.drawBar.colorTipView.backgroundColor = [UIColor colorWithHexString:Color_Items[158]];
                    [self sec1collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 4: {    //彩笔
                    drawView.scrawlView.drawType = Hand;
                    LWDrawBar *drawBar = [self superViewWithClass:[LWDrawBar class]];
                    drawBar.colorSelectorView.hidden = NO;
                    [self sec1collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 5: {    //纹底笔
                    drawView.scrawlView.drawType = Tile;
                    [self sec1collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 6: {    //橡皮
                    drawView.scrawlView.drawType = Erase;
                    [self sec1collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                default:
                    break;
            }
            break;
        case 1:{
            [drawView.scrawlView.curves removeLastObject];
            [drawView.scrawlView setNeedsDisplay];
            break;
        }
        case 2:
            switch (indexPath.item) {
                case 0: {    //小画笔
                    drawView.scrawlView.freeInkLinewidth = 3.0;
                    [self sec3collectionView:collectionView selecteIndexPath:indexPath cell:cell];
                    break;
                }
                case 1: {    //中画笔
                    drawView.scrawlView.freeInkLinewidth = 6.0;
                    [self sec3collectionView:collectionView selecteIndexPath:indexPath cell:cell];
                    break;
                }
                case 2: {    //大画笔
                    drawView.scrawlView.freeInkLinewidth = 12.0;
                    [self sec3collectionView:collectionView selecteIndexPath:indexPath cell:cell];
                    break;
                }
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.item) {
                case 0: {   //直线
                    drawView.scrawlView.drawType = Line;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 1: {   //箭头
                    drawView.scrawlView.drawType = LineArrow;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 2: {   //矩形
                    drawView.scrawlView.drawType = Rectangle;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 3: {   //圆圈
                    drawView.scrawlView.drawType = Oval;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 4: {   //文字
                    drawView.scrawlView.drawType = Text;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                default:
                    break;
            }
            break;

        default:
            break;
    }

}

- (void)sec4collectionView:(UICollectionView *)collectionView selectIndexPath:(NSIndexPath *)indexPath cell:(LWToolsCell *)cell {
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    cell.highlighted = YES;
    _sec3SelectedIndexPath = indexPath;
    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger) indexPath.section]];
}
- (void)sec3collectionView:(UICollectionView *)collectionView selecteIndexPath:(NSIndexPath *)indexPath cell:(LWToolsCell *)cell {
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    cell.highlighted = YES;
    _sec2SelectedIndexPath = indexPath;
    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger) indexPath.section]];
}
- (void)sec1collectionView:(UICollectionView *)collectionView selectIndexPath:(NSIndexPath *)indexPath cell:(LWToolsCell *)cell {
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    cell.highlighted = YES;
    _sec1SelectedIndexPath = indexPath;
    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger) indexPath.section]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWToolsCell *cell = (LWToolsCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolCell" forIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    cell.highlighted = NO;
}


@end

#pragma mark - LWToolsCell

@implementation LWToolsCell

- (IBAction)btnAction:(UIButton *)btn {
    LWDrawToolsView *toolsView = [self superViewWithClass:[LWDrawToolsView class]];
    NSIndexPath *indPath = [toolsView indexPathForCell:self];
    [toolsView.delegate collectionView:toolsView didSelectItemAtIndexPath:indPath];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
//    UIImage *highlightedImg = [self.btn imageForState:UIControlStateHighlighted];
//    UIImage *normalImg = [self.btn imageForState:UIControlStateNormal];
//    [self.btn setImage:highlightedImg forState:UIControlStateNormal];
//    [self.btn setImage:normalImg forState:UIControlStateHighlighted];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.btn.highlighted = highlighted;
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


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    LWColorCell *cell = (LWColorCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];

    LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];
    drawView.scrawlView.freeInkColorIndex = indexPath.item;
    drawView.drawBar.colorTipView.backgroundColor = [UIColor colorWithHexString:Color_Items[(NSUInteger) indexPath.item]];
    self.hidden = YES;
}

@end

#pragma mark - LWColorCell

@implementation LWColorCell {
    UIColor *_oldColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.colorView.layer.borderWidth = 2.0;
    self.colorView.layer.borderColor = [UIColor colorWithHexString:@"#A1A1A1"].CGColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _oldColor = self.colorView.backgroundColor;
    self.colorView.backgroundColor = [UIColor colorWithHexString:@"#A1A1A1"];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.colorView.backgroundColor = _oldColor;
}


@end
