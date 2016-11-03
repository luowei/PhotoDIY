//
//  LWScrawlView.m
//  PhotoDIY
//
//  Created by luowei on 16/9/30.
//  Copyright © 2016年 wodedata. All rights reserved.
//  涂鸦视图

#import <SDWebImage/SDImageCache.h>
#import "LWScrawlView.h"
#import "MyExtensions.h"
#import "LWDrawBar.h"
#import "LWDrawView.h"
#import "Categorys.h"

@implementation LWScrawlView {
    CGFloat keyboardHeight;
    BOOL keyboardIsShowing;
    CGFloat originY;
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

    _curves = [NSMutableArray array];

    _rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
    [self addGestureRecognizer:_rec];

    _drawType = Hand;
    _freeInkLinewidth = 3.0;
    _freeInkColorIndex = 5;
    _tileImageIndex = 10000;    //[UIImage imageNamed:@"luowei"]
    _tileImageUrl = nil;
    _fontName = @"HelveticaNeue";

}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    originY = self.superview.frame.origin.y;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Keyboard Show/Dismiss

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardBounds;
    NSValue *aValue = [note.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];

    [aValue getValue:&keyboardBounds];
    keyboardHeight = keyboardBounds.size.height;
    if (!keyboardIsShowing) {
        keyboardIsShowing = YES;
        CGRect frame = self.superview.frame;
        frame.origin.y -= keyboardHeight;
        if (frame.origin.y < -280) {
            if (keyboardHeight > self.textConstraintY.constant) {
                frame.origin.y = -self.textConstraintY.constant;
            } else {
                frame.origin.y = -keyboardHeight;
            }
        } else {
            if (keyboardHeight > self.textConstraintY.constant) {
                frame.origin.y = -self.textConstraintY.constant;
            } else {
                frame.origin.y = -keyboardHeight;
            }
        }

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        self.superview.frame = frame;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardBounds;
    NSValue *aValue = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    [aValue getValue:&keyboardBounds];

    keyboardHeight = keyboardBounds.size.height;
    if (keyboardIsShowing) {
        keyboardIsShowing = NO;
        CGRect frame = self.superview.frame;
        frame.origin.y += keyboardHeight;
        if (frame.origin.y > 0) {
            frame.origin.y = originY;
        }

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        self.superview.frame = frame;
        [UIView commitAnimations];

    }
}


//重置画板
- (IBAction)resetDrawing {
    [_curves removeAllObjects];
    [self setNeedsDisplay];
}


//点击降下colourView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    CGPoint point = [[touches anyObject] locationInView:self];

    LWDrafter *_currentPath = nil;
    //遍历_curves，查找当前触摸点是否在文字框内
    for (LWDrafter *path in _curves) {
        BOOL isZeroRect = path.textRect.size.height == 0;
        if (!isZeroRect && CGRectContainsPoint(path.textRect, point) && self.drawType == Text) {
            _currentPath = path;
            _currentPath.isNew = NO;
        }
    }

    //如果是绘制文字
    if (self.drawType == Text) {
        //添加一个path
        if (_currentPath == nil && self.textView.hidden) {
            _currentPath = [[LWDrafter alloc] init];
            _currentPath.text = @"";
            _currentPath.textRect = CGRectZero;
            _currentPath.pointArr = [[NSMutableArray alloc] init];
            _currentPath.colorIndex = self.freeInkColorIndex;
            _currentPath.lineWidth = self.freeInkLinewidth;
            _currentPath.fontName = self.fontName;
            _currentPath.drawType = self.drawType;
            //把 _currentPath 添加 _curves 曲线集合中
            [_curves addObject:_currentPath];
        }

        //如果是显示的就是在编辑状态,则变为非编辑状态
        if (!self.textView.hidden) {

            LWDrafter *editingPath = nil;
            //遍历_curves，找出正在编辑的path
            for (LWDrafter *path in _curves) {
                if (path.isTextEditing) {
                    editingPath = path;
                }
            }
            //设置当前编辑的Path
            if (editingPath != nil) {
                editingPath.isTextEditing = NO;
                editingPath.text = self.textView.text;
                editingPath.textRect = self.textView.frame;
                editingPath.fontName = self.textView.font.fontName;
                [self.textView resignFirstResponder];
                self.textView.hidden = YES;
            }

        } else {    //显示并设置为编辑状态
            //设置textView的样式
            UIColor *color = [UIColor colorWithHexString:Color_Items[(NSUInteger) _currentPath.colorIndex]];
            self.textView.textColor = color;
            self.textView.text = _currentPath.text;
            self.textView.font = [UIFont fontWithName:_currentPath.fontName size:_currentPath.lineWidth * 5];
            self.textView.layer.borderWidth = 1.0;
            self.textView.layer.cornerRadius = _currentPath.lineWidth;
            self.textView.layer.borderColor = color.CGColor;

            //显示textView,并设置它的位置
            self.textView.hidden = NO;
            _currentPath.isTextEditing = YES;

            if (_currentPath.isNew) {
                CGSize textVSize = self.textView.bounds.size;
                self.textConstraintX.constant = point.x - textVSize.width;
                self.textConstraintY.constant = point.y - textVSize.height;
            } else {
                self.textConstraintX.constant = _currentPath.textRect.origin.x;
                self.textConstraintY.constant = _currentPath.textRect.origin.y;
            }

            [self.textView becomeFirstResponder];
        }
        [self setNeedsDisplay];

        //如果是绘制纹底
    } else if (self.drawType == EmojiTile || self.drawType == ImageTile) {
        //添加一个点
        _currentPath = [[LWDrafter alloc] init];
        _currentPath.pointArr = [[NSMutableArray alloc] init];
        _currentPath.colorIndex = self.freeInkColorIndex;
        _currentPath.lineWidth = self.freeInkLinewidth;
        _currentPath.tileImageIndex = self.tileImageIndex;
        _currentPath.tileImageUrl = self.tileImageUrl;
        _currentPath.drawType = self.drawType;
        //把 _currentPath 添加 _curves 曲线集合中
        [_curves addObject:_currentPath];

        [_currentPath.pointArr addObject:[NSValue valueWithCGPoint:point]];

        [self setNeedsDisplay];
    }

}


- (void)onDrag:(UIPanGestureRecognizer *)rec {
    CGPoint beganPoint;
    CGPoint movePoint;
    CGPoint endPoint;


    switch (rec.state) {
        case UIGestureRecognizerStateBegan: {
            LWDrafter *currentPath = [[LWDrafter alloc] init];
            currentPath.pointArr = [[NSMutableArray alloc] init];
            currentPath.colorIndex = self.freeInkColorIndex;
            currentPath.lineWidth = self.freeInkLinewidth;
            currentPath.tileImageIndex = self.tileImageIndex;
            currentPath.tileImageUrl = self.tileImageUrl;
            currentPath.drawType = self.drawType;
            [_curves addObject:currentPath];

            beganPoint = [rec locationInView:self];
            [currentPath.pointArr addObject:[NSValue valueWithCGPoint:beganPoint]];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            LWDrafter *currentPath = [_curves lastObject];
            movePoint = [rec locationInView:self];
            [currentPath.pointArr addObject:[NSValue valueWithCGPoint:movePoint]];

            //移动文本输入框
            if (currentPath.drawType == Text && !self.textView.hidden) {
                CGSize textVSize = self.textView.bounds.size;
                self.textConstraintX.constant = movePoint.x - textVSize.width;
                self.textConstraintY.constant = movePoint.y - textVSize.height;
            }

            [self setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            LWDrafter *currentPath = [_curves lastObject];
            currentPath.drawType = self.drawType;

            endPoint = [rec locationInView:self];
            [currentPath.pointArr addObject:[NSValue valueWithCGPoint:endPoint]];

            //移动文本输入框
            if (currentPath.drawType == Text && !self.textView.hidden) {
                CGSize textVSize = self.textView.bounds.size;
                self.textConstraintX.constant = endPoint.x - textVSize.width;
                self.textConstraintY.constant = endPoint.y - textVSize.height;
            }

            [self setNeedsDisplay];
            break;
        }
        default:
            break;
    }

}

- (CGRect)tileBrushRectForPoint:(CGPoint)point withPath:(LWDrafter *)path {
    CGSize burshSize = CGSizeMake(path.lineWidth * 4, path.lineWidth * 4);
    return CGRectMake(point.x - burshSize.width / 2, point.y - burshSize.height / 2, burshSize.width, burshSize.height);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    //遍历每一条路径
    for (LWDrafter *drafter in _curves) {
        //设置颜色与线宽
        [drafter.color set];
        CGContextSetLineWidth(ctx, drafter.lineWidth);

        //检查路径中的点
        NSArray *points = drafter.pointArr;
        if (points.count >= 2) {

            //如果是橡皮擦
            if (drafter.drawType == Erase) {
                //设置为圆头
                CGContextSetLineCap(ctx, kCGLineCapRound);
                //设置清除颜色
                CGContextSetBlendMode(ctx, kCGBlendModeClear);
            } else {
                CGContextSetBlendMode(ctx, kCGBlendModeNormal);
            }

            switch (drafter.drawType) {
                case Hand:
                case Erase: {
                    [self drawCurveWithPoits:points withDrawer:drafter];
                    break;
                }
                case Line: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    [self drawLineFromPoint1:pt toPoint2:lastPt withDrawer:drafter];
                    break;
                }
                case LineArrow: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    [self drawLineArrowFromPoint1:pt toPoint2:lastPt withDrawer:drafter];
                    break;
                }
                case Rectangle: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    [self drawRectangleFromPoint1:pt toPoint2:lastPt withDrawer:drafter];
                    break;
                }
                case Oval: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    [self drawOvalFromPoint1:pt toPoint2:lastPt withDrawer:drafter];

                    break;
                }
                default:
                    break;
            }
        }

        LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];
        //按点描绘底纹图
        if (points.count > 0 && (drafter.drawType == EmojiTile || drafter.drawType == ImageTile)) {
            for (int i = 0; i < points.count; i++) {
                //移动到第i个点
                CGPoint point = [points[i] CGPointValue];
                CGRect brushRect = [self tileBrushRectForPoint:point withPath:drafter];
                __block UIImage *tileImage = [UIImage imageNamed:@"luowei"];
                NSString *name = Emoji_Items[(NSUInteger) drafter.tileImageIndex];
                if (drafter.drawType == ImageTile) {
                    name = drafter.tileImageUrl.absoluteString;
                }

                if (drafter.tileImageIndex < 5000) {
                    //从缓存目录找,没有才去相册加载
                    SDImageCache *imageCache = [SDImageCache sharedImageCache];
                    if ([imageCache diskImageExistsWithKey:[NSString stringWithFormat:@"tile_%lf_%@", drafter.lineWidth, name]]) {
                        tileImage = [imageCache imageFromDiskCacheForKey:[NSString stringWithFormat:@"tile_%lf_%@", drafter.lineWidth, name]];
                    } else {
                        if (drafter.drawType == ImageTile) {
                            CGFloat scale = [UIScreen mainScreen].scale;
                            [drawView.drawBar.tileSelectorView.photoPicker pictureWithURL:drafter.tileImageUrl size:CGSizeMake(drafter.lineWidth * 2 * scale, drafter.lineWidth * 2 * scale) imageBlock:^(UIImage *image) {
                                tileImage = image;
                            }];
                        } else {
                            tileImage = [name image:CGSizeMake(drafter.lineWidth * 2, drafter.lineWidth * 2)];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            [[SDImageCache sharedImageCache] storeImage:tileImage forKey:[NSString stringWithFormat:@"tile_%lf_%@", drafter.lineWidth, name] toDisk:YES];
                        });
                    }
                }
                [tileImage drawInRect:brushRect];
            }

        } else if (drafter.drawType == Text && !drafter.isTextEditing) {  //绘制文字
            NSString *textContent = drafter.text;
            CGRect textRect = drafter.textRect;
            if ((textContent != nil || textContent != @"") && textRect.size.height != 0 && !drafter.isTextEditing) {
                NSMutableParagraphStyle *textStyle = [NSMutableParagraphStyle new];
                textStyle.alignment = NSTextAlignmentNatural;

                NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName:drafter.fontName size:drafter.lineWidth * 5], NSForegroundColorAttributeName: drafter.color, NSParagraphStyleAttributeName: textStyle};

                CGFloat textTextHeight = [textContent boundingRectWithSize:CGSizeMake(textRect.size.width, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin attributes:textFontAttributes context:nil].size.height;
                CGContextSaveGState(ctx);
                //CGContextClipToRect(ctx, textRect);
                [textContent drawInRect:CGRectMake(CGRectGetMinX(textRect), CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - textTextHeight) / 2, CGRectGetWidth(textRect), textTextHeight) withAttributes:textFontAttributes];
                CGContextRestoreGState(ctx);
            }
        }

    }

}

//根据给定的点集自由绘制
- (void)drawCurveWithPoits:(NSArray *)points withDrawer:(LWDrafter *)drafter {
    UIBezierPath* pointsPath = [UIBezierPath bezierPath];

    CGPoint pt = [points[0] CGPointValue];
    [pointsPath moveToPoint: pt];
    CGPoint lastPt = pt;

    for (int i = 1; i < points.count; i++) {
        //画一条曲线到第i个点
        pt = [points[i] CGPointValue];
        [pointsPath addQuadCurveToPoint:CGPointMake((pt.x + lastPt.x) / 2, (pt.y + lastPt.y) / 2) controlPoint: lastPt];
        lastPt = pt;
    }
    [pointsPath addLineToPoint:pt];
    pointsPath.lineCapStyle = kCGLineCapRound;
    pointsPath.lineJoinStyle = kCGLineJoinRound;

    [drafter.color setStroke];
    pointsPath.lineWidth = drafter.lineWidth;
    [pointsPath stroke];
}

//画椭圆
- (void)drawOvalFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrawer:(LWDrafter *)drafter {
    CGRect frame = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), (CGFloat) fabs(p1.x - p2.x), (CGFloat) fabs(p1.y - p2.y));
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: frame];
    [drafter.color setStroke];
    ovalPath.lineWidth = drafter.lineWidth;
    [ovalPath stroke];
}

//画矩形
- (void)drawRectangleFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrawer:(LWDrafter *)drawer {
    CGRect frame = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), (CGFloat) fabs(p1.x - p2.x), (CGFloat) fabs(p1.y - p2.y));
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: frame];
    [drawer.color setStroke];
    rectanglePath.lineWidth = drawer.lineWidth;
    [rectanglePath stroke];
}

//画直线
- (void)drawLineFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrawer:(LWDrafter *)drafter {
    UIBezierPath* linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint: p1];     //画笔移到第一个点的位置
    [linePath addLineToPoint: p2];      //画一条线到第二个点
    linePath.lineCapStyle = kCGLineCapRound;
    [drafter.color setStroke];
    linePath.lineWidth = drafter.lineWidth;
    [linePath stroke];
}

//画箭头
- (void)drawLineArrowFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrawer:(LWDrafter *)drafter {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Shadow Declarations
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor.blackColor colorWithAlphaComponent:0.6]];
    [shadow setShadowOffset:CGSizeMake(1.1, 1.1)];
    [shadow setShadowBlurRadius:2];

    CGFloat p1x = p1.x;
    CGFloat p1y = p1.y;
    CGFloat p2x = p2.x;
    CGFloat p2y = p2.y;
    CGFloat lineWidth = drafter.lineWidth > 0 ? drafter.lineWidth : 0;

    //旋转角度
    CGFloat angle = (CGFloat) (atan2(p2y - p1y, p2x - p1x) * 180/M_PI);


    //// Variable Declarations
    CGFloat arrowP0x = (CGFloat) fabs(sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y)));
    CGFloat lineP3x = (CGFloat) fabs(sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y)));
    CGFloat lineP4x = (CGFloat) fabs(sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y)));
    CGFloat arrowP1x = (CGFloat) (arrowP0x + lineWidth * 3 / 2.0);
    CGFloat arrowP2x = (CGFloat) (arrowP0x - lineWidth * 3 / 2.0 * cos(60 * M_PI/180));
    CGFloat arrowP2y = (CGFloat) (-lineWidth * 3 / 2.0 * sin(60 * M_PI/180));
    CGFloat arrowP3x = (CGFloat) (arrowP0x - lineWidth * 3 / 2.0 * cos(60 * M_PI/180));
    CGFloat arrowP3y = (CGFloat) (lineWidth * 3 / 2.0 * sin(60 * M_PI/180));
    CGFloat lineP1y = (CGFloat) (fabs(lineWidth / 10.0) > 1 ? -1 : -lineWidth / 10.0);
    CGFloat lineP2y = (CGFloat) (fabs(lineWidth / 5.0) > 2 ? -2 : -lineWidth / 5.0);
    CGFloat lineP3y = (CGFloat) (-lineWidth / 2.0);
    CGFloat lineP4y = (CGFloat) (lineWidth / 2.0);
    CGFloat lineP5y = (CGFloat) (fabs(lineWidth / 5.0) > 2 ? 2 : lineWidth / 5.0);
    CGFloat lineP6y = (CGFloat) (fabs(lineWidth / 10.0) > 1 ? 1 : lineWidth / 10.0);
    CGFloat arrowP0y = 0;
    CGFloat arrowP1y = 0;
    CGFloat lineP0x = 0;
    CGFloat lineP0y = 0;
    CGFloat lineP1x = 0;
    CGFloat lineP2x = 1;
    CGFloat lineP5x = 1;
    CGFloat lineP6x = 0;

    //// line_arrow
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, p1x, p1y);
        CGContextRotateCTM(context, (CGFloat) (angle * M_PI / 180));

        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
        CGContextBeginTransparencyLayer(context, NULL);


        //// Line Drawing
        CGContextSaveGState(context);

        UIBezierPath* linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint: CGPointMake(lineP1x, lineP1y)];
        [linePath addLineToPoint: CGPointMake(lineP2x, lineP2y)];
        [linePath addLineToPoint: CGPointMake(lineP3x, lineP3y)];
        [linePath addLineToPoint: CGPointMake(lineP4x, lineP4y)];
        [linePath addLineToPoint: CGPointMake(lineP5x, lineP5y)];
        [linePath addLineToPoint: CGPointMake(lineP6x, lineP6y)];
        [linePath addLineToPoint: CGPointMake(lineP0x, lineP0y)];
        [linePath addLineToPoint: CGPointMake(lineP1x, lineP1y)];
        [linePath closePath];
        linePath.lineJoinStyle = kCGLineJoinRound;

        [drafter.color setFill];
        [linePath fill];
        [drafter.color setStroke];
        linePath.lineWidth = 1;
        [linePath stroke];

        CGContextRestoreGState(context);


        //// Arrow Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, -0, -0);

        UIBezierPath* arrowPath = [UIBezierPath bezierPath];
        [arrowPath moveToPoint: CGPointMake(arrowP1x, arrowP1y)];
        [arrowPath addLineToPoint: CGPointMake(arrowP2x, arrowP2y)];
        [arrowPath addLineToPoint: CGPointMake(arrowP0x, arrowP0y)];
        [arrowPath addLineToPoint: CGPointMake(arrowP3x, arrowP3y)];
        [arrowPath addLineToPoint: CGPointMake(arrowP1x, arrowP1y)];
        [arrowPath closePath];
        arrowPath.lineJoinStyle = kCGLineJoinRound;

        [drafter.color setFill];
        [arrowPath fill];
        [drafter.color setStroke];
        arrowPath.lineWidth = 1;
        [arrowPath stroke];

        CGContextRestoreGState(context);


        CGContextEndTransparencyLayer(context);

        CGContextRestoreGState(context);
    }
}


@end
