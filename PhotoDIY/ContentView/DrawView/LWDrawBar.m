//
// Created by luowei on 16/10/11.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWDrawBar.h"
#import "MyExtensions.h"
#import "Categorys.h"
#import "LWDrawView.h"
#import "LWScrawlView.h"
#import "SDImageCache.h"


#pragma mark - LWDrawBar

@implementation LWDrawBar {

}

- (void)awakeFromNib {
    [super awakeFromNib];

}


@end

#pragma mark - LWDrawToolsView （工具条）

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
            return 2;
        case 2:
            return 3;
        case 3:
            return 9;
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
            switch (indexPath.item) {
                case 0: {
                    [cell.btn setImage:[UIImage imageNamed:@"revoke"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"revoke_selected"] forState:UIControlStateHighlighted ];
                    break;
                }
                case 1:{
                    cell = (LWToolsCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolSliderCell" forIndexPath:indexPath];
                }
                default:
                    break;
            }
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
                case 3: {   //矩形(虚线)
                    [cell.btn setImage:[UIImage imageNamed:@"rectDash"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"rectDash_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 4: {   //矩形(填充)
                    [cell.btn setImage:[UIImage imageNamed:@"rectFill"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"rectFill_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 5: {   //圆圈
                    [cell.btn setImage:[UIImage imageNamed:@"oval"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"oval_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 6: {   //圆圈(虚线)
                    [cell.btn setImage:[UIImage imageNamed:@"ovalDash"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"ovalDash_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 7: {   //圆圈(填充)
                    [cell.btn setImage:[UIImage imageNamed:@"ovalFill"] forState:UIControlStateNormal];
                    [cell.btn setImage:[UIImage imageNamed:@"ovalFill_selected"] forState:UIControlStateHighlighted ];
                    [self sec4Collection:collectionView selIndexPath:indexPath cell:cell];
                    break;
                }
                case 8: {   //文字
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


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.item == 1){
        return CGSizeMake(200, 80);
    }else{
        return CGSizeMake(40, 80);
    }
}

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
                    if(drawView.scrawlView.drawType != Text){
                        drawView.scrawlView.drawType = Hand;
                    }
                    drawView.drawBar.colorSelectorView.hidden = NO;
                    [self sec1collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 5: {    //纹底笔
                    drawView.scrawlView.drawType = EmojiTile;
                    drawView.drawBar.tileSelectorView.hidden = NO;
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
            switch (indexPath.item) {
                case 0: {
                    [drawView.scrawlView.curves removeLastObject];
                    [drawView.scrawlView setNeedsDisplay];
                    break;
                }
                case 1:{

                }
                default:
                    break;
            }
            break;
        }
        case 2:
            switch (indexPath.item) {
                case 0: {    //小画笔
                    drawView.scrawlView.freeInkLinewidth = 3.0;
                    [self sec3collectionView:collectionView selecteIndexPath:indexPath cell:cell];
                    LWToolsCell *toolsCell = (LWToolsCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]];
                    toolsCell.slider.value = (float) (3.0 / 60);
                    break;
                }
                case 1: {    //中画笔
                    drawView.scrawlView.freeInkLinewidth = 6.0;
                    [self sec3collectionView:collectionView selecteIndexPath:indexPath cell:cell];
                    LWToolsCell *toolsCell = (LWToolsCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]];
                    toolsCell.slider.value = (float) (6.0 / 60);
                    break;
                }
                case 2: {    //大画笔
                    drawView.scrawlView.freeInkLinewidth = 12.0;
                    [self sec3collectionView:collectionView selecteIndexPath:indexPath cell:cell];
                    LWToolsCell *toolsCell = (LWToolsCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]];
                    toolsCell.slider.value = (float) (12.0 / 60);
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
                case 3: {   //矩形(虚线)
                    drawView.scrawlView.drawType = RectangleDash;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 4: {   //矩形(填充)
                    drawView.scrawlView.drawType = RectangleFill;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 5: {   //圆圈
                    drawView.scrawlView.drawType = Oval;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 6: {   //圆圈(虚线)
                    drawView.scrawlView.drawType = OvalDash;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 7: {   //圆圈(填充)
                    drawView.scrawlView.drawType = OvalFill;
                    [self sec4collectionView:collectionView selectIndexPath:indexPath cell:cell];
                    break;
                }
                case 8: {   //文字
                    drawView.scrawlView.drawType = Text;
                    drawView.drawBar.fontSelectorView.hidden = NO;
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
    [drawView.scrawlView exitEditingOrTexting];

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

#pragma mark - LWToolsCell（工具条的Cell）

@implementation LWToolsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.slider.value = 3.0/60;
}

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

-(IBAction)slideMove:(UISlider *)slider{
    LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];
    drawView.scrawlView.freeInkLinewidth = 60 * slider.value;
}

@end


#pragma mark - LWColorSelectorView （颜色选择面板）

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

#pragma mark - LWColorCell （颜色选择面板的Cell）

@implementation LWColorCell {
    UIColor *_oldColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.colorView.layer.borderWidth = 1.0;
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


#pragma mark - LWTileImagesView (底纹图片选择面板)

@implementation LWTileImagesView{
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    _currentDrawType = EmojiTile;
    _itemsData = Emoji_Items;

//    [self registerClass:[LWTileHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TileHeader"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemsData.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWTileCell *cell = (LWTileCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"TileCell" forIndexPath:indexPath];
    __block UIImage *tileImage = [UIImage imageNamed:@"luowei"];
    if(_currentDrawType == EmojiTile){
        tileImage = [((NSString *) _itemsData[(NSUInteger) indexPath.item]) image:CGSizeMake(40 * 2,40 * 2)];
    }else{
        NSURL *url = (NSURL *) _itemsData[(NSUInteger) indexPath.item];

        //从缓存目录找,没有才去相册加载
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        if([imageCache diskImageExistsWithKey:[NSString stringWithFormat:@"%@_80",url.absoluteString] ]){
            tileImage = [imageCache imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@_80",url.absoluteString] ];
        }else{
            [self.photoPicker pictureWithURL:url size:CGSizeMake(40 * 2,40 * 2) imageBlock:^(UIImage *image){
                dispatch_async(dispatch_get_main_queue(), ^() {
                    tileImage = image;
                    cell.imageView.image = tileImage;
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"%@_80",url.absoluteString] toDisk:YES];
                });
            }];
        }
    }

    cell.imageView.image = tileImage;
    return cell;
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        self.tileHeader = (LWTileHeader *) [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"TileHeader" forIndexPath:indexPath];
        return self.tileHeader;

    }
    return nil;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LWTileCell *cell = (LWTileCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"TileCell" forIndexPath:indexPath];
    LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];
    drawView.scrawlView.drawType = _currentDrawType;
    
    switch (_currentDrawType) {
        case EmojiTile:{
            drawView.scrawlView.tileImageIndex = indexPath.item;
            break;
        }
        case ImageTile:{
            NSURL *url = (NSURL *) _itemsData[(NSUInteger) indexPath.item];
            drawView.scrawlView.tileImageUrl = url;
            break;
        }
        default:
            break;
    }
    
    self.hidden = YES;
}

#pragma mark - PDPhotoPickerProtocol 实现

- (void)allURLPicked:(NSArray *)urls {
    self.itemsData = urls;
    [self reloadData];
}

-(void)collectPhotoFailed{
    //获取相册照片失败
}


@end


@implementation LWTileCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = [UIColor colorWithHexString:@"#A1A1A1"].CGColor;
}

@end

@implementation LWTileHeader


- (void)awakeFromNib {
    [super awakeFromNib];

    self.tileBtn.layer.borderWidth = 1.0;
    self.tileBtn.layer.borderColor = [UIColor colorWithHexString:@"#A1A1A1"].CGColor;
}

- (IBAction)tileBtnAction {
    LWTileImagesView * tileImagesView = [self superViewWithClass:[LWTileImagesView class]];
    if(tileImagesView.currentDrawType == EmojiTile){
        tileImagesView.currentDrawType = ImageTile;
        if(!tileImagesView.photoPicker){
            tileImagesView.photoPicker = [[PDPhotoLibPicker alloc] initWithDelegate:tileImagesView];
        }
        tileImagesView.photoPicker.delegate = tileImagesView;
        [tileImagesView.photoPicker getAllPicturesURL];
        [self.tileBtn setImage:[UIImage imageNamed:@"EmojiBtn"] forState:UIControlStateNormal];
        [self.tileBtn setImage:[UIImage imageNamed:@"EmojiBtn_Selected"] forState:UIControlStateHighlighted];
    }else{
        tileImagesView.itemsData = Emoji_Items;
        tileImagesView.currentDrawType = EmojiTile;
        [tileImagesView reloadData];
        [self.tileBtn setImage:[UIImage imageNamed:@"TileBtn"] forState:UIControlStateNormal];
        [self.tileBtn setImage:[UIImage imageNamed:@"TileBtn_Selected"] forState:UIControlStateHighlighted];
    }
}

@end



#pragma mark - LWFontSelectorView

@implementation LWFontSelectorView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return Font_Items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWFontCell *cell = (LWFontCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"FontCell" forIndexPath:indexPath];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellImgSize = CGSizeMake(160 * scale, 80 * scale);
    NSString *fontName = Font_Items[(NSUInteger) indexPath.item];

    //从缓存目录找,没有才去生成
    UIImage *image = [UIImage imageNamed:@"luowei"];
//    SDImageCache *imageCache = [SDImageCache sharedImageCache];
//    if([imageCache diskImageExistsWithKey:[NSString stringWithFormat:@"%@_160",fontName] ]){
//        image = [imageCache imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@_160",fontName] ];
//    }else{
//        image = [self getFontImageWithSize:&cellImgSize fontName:fontName];
//        [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"%@_160",fontName] toDisk:YES];
//    }

    image = [self getFontImageWithSize:cellImgSize fontName:fontName withIndexPath:indexPath];
    cell.imageView.image = image;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fontName = Font_Items[(NSUInteger) indexPath.item];

    LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];
    drawView.scrawlView.fontName = fontName;
    self.hidden = YES;
}


//根据字体获得指定大小的图片
- (UIImage *)getFontImageWithSize:(CGSize)cellImgSize fontName:(NSString *)fontName withIndexPath:(NSIndexPath *)indexPath {
//根据fontText,font以及cellImgSize,确定合适的fontSize,得到合适的文本矩形区attrTextRect
    NSString *fontText = @"你好世界";
    if(indexPath.item > 19){
        fontText = @"你好Abc";
    }
    CGFloat fontSize = 64;
    NSDictionary *attributes = nil;
    NSAttributedString *attrText = nil;
    CGRect attrTextRect = CGRectMake(0, 0, cellImgSize.width, cellImgSize.height);
    do {
        fontSize -= 4;
        attributes = @{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize],NSForegroundColorAttributeName : [UIColor blackColor],NSBackgroundColorAttributeName : [UIColor clearColor]};
        attrText = [[NSAttributedString alloc] initWithString:fontText attributes:attributes];
        attrTextRect = [attrText boundingRectWithSize:CGSizeMake(attrText.size.width, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    } while (fontSize > 30 && (attrTextRect.size.width > cellImgSize.width || attrTextRect.size.height > cellImgSize.height));

    UIImage *textImg = [UIImage imageFromString:fontText attributes:attributes size:attrTextRect.size];
    UIImage *colorImage = [UIImage imageFromColor:[UIColor whiteColor] withRect:CGRectMake(0, 0, cellImgSize.width, cellImgSize.height)];

    //合并图片
    CGRect logoFrame = CGRectMake((colorImage.size.width - textImg.size.width) / 2, (colorImage.size.height - textImg.size.height) / 2, textImg.size.width, textImg.size.height);
    UIImage *combinedImg = [UIImage addImageToImage:colorImage withImage2:textImg andRect:logoFrame withImageSize:cellImgSize];
    return combinedImg;
}


@end


@implementation LWFontCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = [UIColor colorWithHexString:@"#A1A1A1"].CGColor;
}

@end


