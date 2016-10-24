//
// Created by luowei on 16/10/11.
// Copyright (c) 2016 wodedata. All rights reserved.
//

#import "LWDrawBar.h"


@implementation LWDrawBar {

}

- (void)awakeFromNib {
    [super awakeFromNib];

}


@end

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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolCell" forIndexPath:indexPath];
    switch (indexPath.item) {
        case 0:{    //黑笔
            break;
        }
        case 1:{    //红笔
            break;
        }
        case 2:{    //绿笔
            break;
        }
        case 3:{    //蓝笔
            break;
        }
        case 4:{    //彩笔
            break;
        }
        case 5:{    //纹底笔
            break;
        }
        case 6:{    //橡皮
            break;
        }
        case 7:{    //小画笔
            break;
        }
        case 8:{    //中画笔
            break;
        }
        case 9:{    //大画笔
            break;
        }
        case 10:{   //直线
            break;
        }
        case 11:{   //箭头
            break;
        }
        case 12:{   //矩形
            break;
        }
        case 13:{   //圆圈
            break;
        }
        case 14:{   //文字
            break;
        }
        default:
            break;
    }

    return cell;
}


@end


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


@implementation LWColorCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.colorView.layer.borderWidth = 2.0;
    self.colorView.layer.borderColor = [UIColor whiteColor].CGColor;
}


@end