//
// Created by luowei on 16/10/11.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWDrawBar.h"

#pragma mark - LWDrawBar

@implementation LWDrawBar {

}

- (void)awakeFromNib {
    [super awakeFromNib];

}


@end

#pragma mark - LWDrawToolsView

//画板工具的选择
@implementation LWDrawToolsView{

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
    LWToolsCell *cell = (LWToolsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ToolCell" forIndexPath:indexPath];
    switch (indexPath.item) {
        case 0:{    //黑笔
            [cell.btn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"pen_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 1:{    //红笔
            [cell.btn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"pen_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 2:{    //绿笔
            [cell.btn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"pen_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 3:{    //蓝笔
            [cell.btn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"pen_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 4:{    //彩笔
            [cell.btn setImage:[UIImage imageNamed:@"penColor"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"penColor_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 5:{    //纹底笔
            [cell.btn setImage:[UIImage imageNamed:@"penTile"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"penTile_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 6:{    //橡皮
            [cell.btn setImage:[UIImage imageNamed:@"eraser"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"eraser_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 7:{    //小画笔
            [cell.btn setImage:[UIImage imageNamed:@"dotSmall"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"dotSmall_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 8:{    //中画笔
            [cell.btn setImage:[UIImage imageNamed:@"dotMiddle"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"dotMiddle_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 9:{    //大画笔
            [cell.btn setImage:[UIImage imageNamed:@"dotLarge"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"dotLarge_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 10:{   //直线
            [cell.btn setImage:[UIImage imageNamed:@"line"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"line_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 11:{   //箭头
            [cell.btn setImage:[UIImage imageNamed:@"lineArrow"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"lineArrow_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 12:{   //矩形
            [cell.btn setImage:[UIImage imageNamed:@"rect"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"rect_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 13:{   //圆圈
            [cell.btn setImage:[UIImage imageNamed:@"oval"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"oval_selected"] forState:UIControlStateHighlighted];
            break;
        }
        case 14:{   //文字
            [cell.btn setImage:[UIImage imageNamed:@"text"] forState:UIControlStateNormal];
            [cell.btn setImage:[UIImage imageNamed:@"text_selected"] forState:UIControlStateHighlighted];
            break;
        }
        default:
            break;
    }

    return cell;
}


@end

#pragma mark - LWToolsCell

@implementation LWToolsCell

@end



#pragma mark - LWColorSelectorView

//画笔颜色选择
@implementation LWColorSelectorView{

}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (Color_Items).count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWColorCell *cell = (LWColorCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    cell.colorView.backgroundColor = (Color_Items)[(NSUInteger) indexPath.item];
    return cell;
}


@end

#pragma mark - LWColorCell

@implementation LWColorCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.colorView.layer.borderWidth = 2.0;
    self.colorView.layer.borderColor = [UIColor whiteColor].CGColor;
}


@end