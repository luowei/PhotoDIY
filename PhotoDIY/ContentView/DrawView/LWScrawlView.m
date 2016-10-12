//
//  LWScrawlView.m
//  PhotoDIY
//
//  Created by luowei on 16/9/30.
//  Copyright © 2016年 wodedata. All rights reserved.
//  涂鸦视图

#import "LWScrawlView.h"
#import "LWInkLine.h"
#import "LWConfigManager.h"

@implementation LWScrawlView {
    BOOL _isEraseMode;  // 打开橡皮擦
    CGSize pageSize;
    NSMutableArray *curves;
    UIPanGestureRecognizer *_rec;
}

static inline float fz_min(float a, float b) {
    return (a < b ? a : b);
}

CGSize fitPageToScreen(CGSize page, CGSize screen) {
    float hscale = screen.width / page.width;
    float vscale = screen.height / page.height;
    float scale = fz_min(hscale, vscale);
    hscale = floorf(page.width * scale) / page.width;
    vscale = floorf(page.height * scale) / page.height;
    return CGSizeMake(hscale, vscale);
}

- (void)awakeFromNib {
    [super awakeFromNib];

    curves = [NSMutableArray array];

    _rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
    [self addGestureRecognizer:_rec];

}

- (void)eraseModeOn:(BOOL)is {
    _isEraseMode = is;

}


//点击降下colourView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //[[FGColourView sharedManager] goDown];

}

- (void)resetDrawing {
    [curves removeAllObjects];
    [self setNeedsDisplay];
}

- (void)onDrag:(UIPanGestureRecognizer *)rec {
    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    CGPoint p = [rec locationInView:self];
    p.x /= scale.width;
    p.y /= scale.height;

    if (rec.state == UIGestureRecognizerStateBegan) {
        LWInkLine *il = [[LWInkLine alloc] init];
        il.lineArr = [[NSMutableArray alloc] init];
        il.colorIndex = [[LWConfigManager sharedInstance] getInkColorIndex];
        il.lineWidth = [[LWConfigManager sharedInstance] getFreeInkLineWidth];
        [curves addObject:il];
    }
    LWInkLine *il = [curves lastObject];
    il.isEraseMode = _isEraseMode;

    [il.lineArr addObject:[NSValue valueWithCGPoint:p]];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGSize scale = fitPageToScreen(pageSize, self.bounds.size);
    CGContextRef cref = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(cref, scale.width, scale.height);

    for (LWInkLine *il in curves) {

        CGFloat lineWidth = il.lineWidth;
        [[[LWConfigManager sharedInstance] getFreeInkColorWithIndex:il.colorIndex] set];
        CGContextSetLineWidth(cref, lineWidth);

        NSArray *curve = il.lineArr;
        if (curve.count >= 2) {
            CGPoint pt = [curve[0] CGPointValue];
            CGContextBeginPath(cref);
            CGContextMoveToPoint(cref, pt.x, pt.y);
            CGPoint lpt = pt;

            if (il.isEraseMode) {
                //设置为圆头
                CGContextSetLineCap(cref, kCGLineCapRound);
                //设置清除颜色
                CGContextSetBlendMode(cref, kCGBlendModeClear);
                CGContextSetLineWidth(cref, 20);
            } else {
                CGContextSetBlendMode(cref, kCGBlendModeNormal);
            }
            //CGContextSetStrokeColorWithColor(cref, [[[FGConfigManager sharedInstance] getFreeInkColorWithIndex:il.colorIndex] CGColor]);
            for (int i = 1; i < curve.count; i++) {
                pt = [curve[i] CGPointValue];
                CGContextAddQuadCurveToPoint(cref, lpt.x, lpt.y, (pt.x + lpt.x) / 2, (pt.y + lpt.y) / 2);
                lpt = pt;
            }

            CGContextAddLineToPoint(cref, pt.x, pt.y);
            CGContextStrokePath(cref);
        }
    }

}


@end
