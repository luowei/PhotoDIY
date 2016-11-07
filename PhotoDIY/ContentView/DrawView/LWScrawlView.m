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

    LWDrafter *_currentDrafter = nil;
    //遍历_curves，查找当前触摸点是否在文字框内
    for (LWDrafter *path in _curves) {
        BOOL isZeroRect = path.textRect.size.height == 0;
        if (!isZeroRect && CGRectContainsPoint(path.textRect, point) && self.drawType == Text) {
            _currentDrafter = path;
            _currentDrafter.isNew = NO;
        }
    }

    //如果是绘制文字
    if (self.drawType == Text) {
        //添加一个path
        if (_currentDrafter == nil && self.textView.hidden) {
            _currentDrafter = [[LWDrafter alloc] init];
            _currentDrafter.text = @"";
            _currentDrafter.textRect = CGRectZero;
            _currentDrafter.pointArr = [[NSMutableArray alloc] init];
            _currentDrafter.colorIndex = self.freeInkColorIndex;
            _currentDrafter.lineWidth = self.freeInkLinewidth;
            _currentDrafter.fontName = self.fontName;
            _currentDrafter.drawType = self.drawType;
            //把 _currentDrafter 添加 _curves 曲线集合中
            [_curves addObject:_currentDrafter];
        }

        //如果是显示的就是在编辑状态,则变为非编辑状态
        if (!self.textView.hidden) {

            LWDrafter *editingDrafter = nil;
            //遍历_curves，找出正在编辑的path
            for (LWDrafter *draf in _curves) {
                if (draf.isTextEditing) {
                    editingDrafter = draf;
                }
            }
            //设置当前编辑的Path
            if (editingDrafter != nil) {
                editingDrafter.isTextEditing = NO;
                editingDrafter.text = self.textView.text;
                editingDrafter.textRect = self.textView.frame;
                editingDrafter.fontName = self.textView.font.fontName;
                [self.textView resignFirstResponder];
                self.textView.hidden = YES;
            }

        } else {    //显示并设置为编辑状态
            //设置textView的样式
            UIColor *color = [UIColor colorWithHexString:Color_Items[(NSUInteger) _currentDrafter.colorIndex]];
            self.textView.textColor = color;
            self.textView.text = _currentDrafter.text;
            self.textView.font = [UIFont fontWithName:_currentDrafter.fontName size:_currentDrafter.lineWidth * 5];
            self.textView.layer.borderWidth = 1.0;
            self.textView.layer.cornerRadius = _currentDrafter.lineWidth;
            self.textView.layer.borderColor = color.CGColor;

            //显示textView,并设置它的位置
            self.textView.hidden = NO;
            _currentDrafter.isTextEditing = YES;

            if (_currentDrafter.isNew) {
                CGSize textVSize = self.textView.bounds.size;
                self.textConstraintX.constant = point.x - textVSize.width;
                self.textConstraintY.constant = point.y - textVSize.height;
            } else {
                self.textConstraintX.constant = _currentDrafter.textRect.origin.x;
                self.textConstraintY.constant = _currentDrafter.textRect.origin.y;
            }

            [self.textView becomeFirstResponder];
        }
        [self setNeedsDisplay];


    } else if (self.drawType == EmojiTile || self.drawType == ImageTile) {  //如果是绘制纹底
        //添加一个点
        _currentDrafter = [[LWDrafter alloc] init];
        _currentDrafter.pointArr = [[NSMutableArray alloc] init];
        _currentDrafter.colorIndex = self.freeInkColorIndex;
        _currentDrafter.lineWidth = self.freeInkLinewidth;
        _currentDrafter.tileImageIndex = self.tileImageIndex;
        _currentDrafter.tileImageUrl = self.tileImageUrl;
        _currentDrafter.drawType = self.drawType;
        //把 _currentDrafter 添加 _curves 曲线集合中
        [_curves addObject:_currentDrafter];

        [_currentDrafter.pointArr addObject:[NSValue valueWithCGPoint:point]];

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
                    [self drawLineFromPoint1:pt toPoint2:lastPt withDrafter:drafter];
                    break;
                }
                case LineArrow: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    [self drawLineArrowFromPoint1:pt toPoint2:lastPt withDrafter:drafter];
                    break;
                }
                case Rectangle: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    [self drawRectangleFromPoint1:pt toPoint2:lastPt withDrafter:drafter];
                    break;
                }
                case Oval: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    [self drawOvalFromPoint1:pt toPoint2:lastPt withDrafter:drafter];

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
                CGRect brushRect = CGRectMake(point.x - drafter.burshSize.width / 2, point.y - drafter.burshSize.height / 2, drafter.burshSize.width, drafter.burshSize.height);

                UIImage *tileImage = [self getTileImageWithDrafter:drafter];

                //绘制tileImage
                [tileImage drawInRect:brushRect];
            }

        } else if (drafter.drawType == Text && !drafter.isTextEditing) {  //绘制文字
            if ((drafter.text != nil || drafter.text != @"") && drafter.textRect.size.height != 0 && !drafter.isTextEditing) {
                [self drawTextWithDrafter:drafter];
            }
        }

    }


}


//根据drafter获得一张TileImage
- (UIImage *)getTileImageWithDrafter:(LWDrafter *)drafter{
    //获得tileImage
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
                            LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];
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
    return tileImage;
}

//根据给定的点集自由绘制
- (void)drawCurveWithPoits:(NSArray *)points withDrawer:(LWDrafter *)drafter {
    UIBezierPath *pointsPath = [UIBezierPath bezierPath];

    CGPoint pt = [points[0] CGPointValue];
    [pointsPath moveToPoint:pt];
    CGPoint lastPt = pt;

    for (int i = 1; i < points.count; i++) {
        //画一条曲线到第i个点
        pt = [points[i] CGPointValue];
        [pointsPath addQuadCurveToPoint:CGPointMake((pt.x + lastPt.x) / 2, (pt.y + lastPt.y) / 2) controlPoint:lastPt];
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
- (void)drawOvalFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrafter:(LWDrafter *)drafter {
    CGRect frame = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), (CGFloat) fabs(p1.x - p2.x), (CGFloat) fabs(p1.y - p2.y));
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:frame];
    [drafter.color setStroke];
    ovalPath.lineWidth = drafter.lineWidth;
    [ovalPath stroke];
}

//画矩形
- (void)drawRectangleFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrafter:(LWDrafter *)drawer {
    CGRect frame = CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), (CGFloat) fabs(p1.x - p2.x), (CGFloat) fabs(p1.y - p2.y));
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:frame];
    [drawer.color setStroke];
    rectanglePath.lineWidth = drawer.lineWidth;
    [rectanglePath stroke];
}

//画直线
- (void)drawLineFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrafter:(LWDrafter *)drafter {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:p1];     //画笔移到第一个点的位置
    [linePath addLineToPoint:p2];      //画一条线到第二个点
    linePath.lineCapStyle = kCGLineCapRound;
    [drafter.color setStroke];
    linePath.lineWidth = drafter.lineWidth;
    [linePath stroke];
}

//画文字
- (void)drawTextWithDrafter:(LWDrafter *)drafter {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Declarations
    NSString *textContent = drafter.text;
    UIColor *color = drafter.color;
    CGRect rectangle = drafter.textRect;
    CGFloat angle = drafter.rotateAngle;
    NSShadow *shadow = drafter.shadow;

    //// Variable Declarations
    CGPoint center = CGPointMake(rectangle.origin.x + rectangle.size.width / 2.0, rectangle.origin.y + rectangle.size.height / 2.0);
    CGPoint offset = CGPointMake(-rectangle.size.width / 2.0, -rectangle.size.height / 2.0);

    //// Text Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, center.x, center.y);
    CGContextRotateCTM(context, -angle * M_PI / 180);

    CGRect textRect = CGRectMake(offset.x, offset.y, rectangle.size.width, rectangle.size.height);
    {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
        NSMutableParagraphStyle *textStyle = [NSMutableParagraphStyle new];
        textStyle.alignment = NSTextAlignmentLeft;

        NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName:drafter.fontName size:drafter.lineWidth * 5], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: textStyle};

        CGFloat textTextHeight = [textContent boundingRectWithSize:CGSizeMake(textRect.size.width, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin attributes:textFontAttributes context:nil].size.height;
        CGContextSaveGState(context);
        CGContextClipToRect(context, textRect);
        [textContent drawInRect:CGRectMake(CGRectGetMinX(textRect), CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - textTextHeight) / 2, CGRectGetWidth(textRect), textTextHeight) withAttributes:textFontAttributes];
        CGContextRestoreGState(context);
        CGContextRestoreGState(context);

    }

    CGContextRestoreGState(context);
}

//画图片
- (void)drawImageWithFrame:(CGRect)imageFrame andDrafter:(LWDrafter *)drafter{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();


    //// Declarations
    UIImage *image = [UIImage imageNamed:@"luowei"];

    //// Variable Declarations
    CGPoint center = CGPointMake((CGFloat) (imageFrame.origin.x + imageFrame.size.width / 2.0), (CGFloat) (imageFrame.origin.y + imageFrame.size.height / 2.0));
    CGPoint offset = CGPointMake((CGFloat) (-imageFrame.size.width / 2.0), (CGFloat) (-imageFrame.size.height / 2.0));

    //获得角度
    NSString *key = [NSString stringWithFormat:@"%f,%f",center.x,center.y];
    CGFloat angle = (CGFloat) [drafter.rotateAngleDict[key] doubleValue];

    //// img Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, center.x, center.y);
    CGContextRotateCTM(context, (CGFloat) (-angle * M_PI / 180));

    CGRect imgRect = CGRectMake(offset.x, offset.y, imageFrame.size.width, imageFrame.size.height);
    UIBezierPath *imgPath = [UIBezierPath bezierPathWithRect:imgRect];
    CGContextSaveGState(context);
    [imgPath addClip];
    [image drawInRect:imgRect];
    CGContextRestoreGState(context);

    CGContextRestoreGState(context);
}


//画箭头
- (void)drawLineArrowFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrafter:(LWDrafter *)drafter {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Shadow Declarations
    NSShadow *shadow = drafter.shadow;

    CGFloat p1x = p1.x;
    CGFloat p1y = p1.y;
    CGFloat p2x = p2.x;
    CGFloat p2y = p2.y;
    CGFloat lineWidth = drafter.lineWidth > 0 ? drafter.lineWidth : 0;

    //旋转角度
    CGFloat angle = (CGFloat) (atan2(p2y - p1y, p2x - p1x) * 180 / M_PI);


    //// Variable Declarations
    CGFloat arrowP0x = (CGFloat) fabs(sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y)));
    CGFloat lineP3x = (CGFloat) fabs(sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y)));
    CGFloat lineP4x = (CGFloat) fabs(sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y)));
    CGFloat arrowP1x = (CGFloat) (arrowP0x + lineWidth * 3 / 2.0);
    CGFloat arrowP2x = (CGFloat) (arrowP0x - lineWidth * 3 / 2.0 * cos(60 * M_PI / 180));
    CGFloat arrowP2y = (CGFloat) (-lineWidth * 3 / 2.0 * sin(60 * M_PI / 180));
    CGFloat arrowP3x = (CGFloat) (arrowP0x - lineWidth * 3 / 2.0 * cos(60 * M_PI / 180));
    CGFloat arrowP3y = (CGFloat) (lineWidth * 3 / 2.0 * sin(60 * M_PI / 180));
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

        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(lineP1x, lineP1y)];
        [linePath addLineToPoint:CGPointMake(lineP2x, lineP2y)];
        [linePath addLineToPoint:CGPointMake(lineP3x, lineP3y)];
        [linePath addLineToPoint:CGPointMake(lineP4x, lineP4y)];
        [linePath addLineToPoint:CGPointMake(lineP5x, lineP5y)];
        [linePath addLineToPoint:CGPointMake(lineP6x, lineP6y)];
        [linePath addLineToPoint:CGPointMake(lineP0x, lineP0y)];
        [linePath addLineToPoint:CGPointMake(lineP1x, lineP1y)];
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

        UIBezierPath *arrowPath = [UIBezierPath bezierPath];
        [arrowPath moveToPoint:CGPointMake(arrowP1x, arrowP1y)];
        [arrowPath addLineToPoint:CGPointMake(arrowP2x, arrowP2y)];
        [arrowPath addLineToPoint:CGPointMake(arrowP0x, arrowP0y)];
        [arrowPath addLineToPoint:CGPointMake(arrowP3x, arrowP3y)];
        [arrowPath addLineToPoint:CGPointMake(arrowP1x, arrowP1y)];
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


#pragma mark - LWScratchTextView

@implementation LWScratchTextView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];

    UIColor *shadowColor = self.textColor.isLight ? [UIColor.blackColor colorWithAlphaComponent:0.6] : [UIColor.whiteColor colorWithAlphaComponent:0.6];

    //textView边框加阴影
    self.layer.shadowColor = [shadowColor CGColor];
    self.layer.shadowOffset = CGSizeMake(1.1f, 1.1f);
    self.layer.shadowOpacity = 0.6f;
    self.layer.shadowRadius = 2.0f;
}


@end


#pragma mark - LWControlBtn

@implementation LWControlImgV


@end


#pragma mark - LWControlView

@implementation LWControlView


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    //绘制虚线框
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: self.bounds];
    [[UIColor colorWithHexString:@"ff4000"] setStroke];
    rectanglePath.lineWidth = 1;
    CGFloat rectanglePattern[] = {2, 2};
    [rectanglePath setLineDash: rectanglePattern count: 2 phase: 0];
    [rectanglePath stroke];
}


@end