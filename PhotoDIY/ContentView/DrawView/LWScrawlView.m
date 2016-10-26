//
//  LWScrawlView.m
//  PhotoDIY
//
//  Created by luowei on 16/9/30.
//  Copyright © 2016年 wodedata. All rights reserved.
//  涂鸦视图

#import "LWScrawlView.h"
#import "LWInkLine.h"
#import "MyExtensions.h"
#import "LWDrawBar.h"

@implementation LWScrawlView {
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
    
    _freeInkLinewidth = 3.0;
    _freeInkColorIndex = 5;

}


//重置画板
- (IBAction)resetDrawing {
    [curves removeAllObjects];
    [self setNeedsDisplay];
}


//点击降下colourView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //[[FGColourView sharedManager] goDown];

}


- (void)onDrag:(UIPanGestureRecognizer *)rec {
    CGSize scale = fitPageToScreen([UIScreen mainScreen].bounds.size, self.bounds.size);
    CGPoint p = [rec locationInView:self];
    p.x /= scale.width;
    p.y /= scale.height;

    if (rec.state == UIGestureRecognizerStateBegan) {
        LWInkLine *il = [[LWInkLine alloc] init];
        il.pointArr = [[NSMutableArray alloc] init];
        il.colorIndex = _freeInkColorIndex;
        il.lineWidth = _freeInkLinewidth;
        [curves addObject:il];
    }
    LWInkLine *il = [curves lastObject];
    il.isEraseMode = _isEraseMode;

    [il.pointArr addObject:[NSValue valueWithCGPoint:p]];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGSize scale = fitPageToScreen([UIScreen mainScreen].bounds.size, self.bounds.size);
    CGContextRef cref = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(cref, scale.width, scale.height);

    for (LWInkLine *il in curves) {
        //设置颜色与线宽
        UIColor *color = [UIColor colorWithHexString:Color_Items[(NSUInteger) il.colorIndex]];
        [color set];
        CGContextSetLineWidth(cref, il.lineWidth);

        NSArray *curve = il.pointArr;
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
            //CGContextSetStrokeColorWithColor(cref, color.CGColor);
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
