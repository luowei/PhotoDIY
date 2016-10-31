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

    LWInkLine *_currentPath = nil;
    //遍历_curves，查找当前触摸点是否在文字框内
    for (LWInkLine *path in _curves) {
        BOOL isZeroRect = path.textRect.size.height == 0;
        if (!isZeroRect && CGRectContainsPoint(path.textRect, point) && self.drawType == Text) {
            _currentPath = path;
            _currentPath.isNew = NO;
        }
    }

    //如果是绘制文字
    if( self.drawType == Text) {
        //添加一个path
        if (_currentPath == nil && self.textView.hidden) {
            _currentPath = [[LWInkLine alloc] init];
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

            LWInkLine *editingPath = nil;
            //遍历_curves，找出正在编辑的path
            for (LWInkLine *path in _curves) {
                if(path.isTextEditing){
                    editingPath = path;
                }
            }
            //设置当前编辑的Path
            if(editingPath != nil){
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

            if(_currentPath.isNew){
                CGSize textVSize = self.textView.bounds.size;
                self.textConstraintX.constant = point.x - textVSize.width;
                self.textConstraintY.constant = point.y - textVSize.height;
            }else{
                self.textConstraintX.constant = _currentPath.textRect.origin.x;
                self.textConstraintY.constant = _currentPath.textRect.origin.y;
            }

            [self.textView becomeFirstResponder];
        }
        [self setNeedsDisplay];

    //如果是绘制纹底
    }else if (self.drawType == EmojiTile || self.drawType == ImageTile) {
        //添加一个点
        _currentPath = [[LWInkLine alloc] init];
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
            LWInkLine *currentPath = [[LWInkLine alloc] init];
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
            LWInkLine *currentPath = [_curves lastObject];
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
            LWInkLine *currentPath = [_curves lastObject];
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

- (CGRect)tileBrushRectForPoint:(CGPoint)point withPath:(LWInkLine *)path {
    CGSize burshSize = CGSizeMake(path.lineWidth * 4, path.lineWidth * 4);
    return CGRectMake(point.x - burshSize.width / 2, point.y - burshSize.height / 2, burshSize.width, burshSize.height);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    //遍历每一条路径
    for (LWInkLine *path in _curves) {
        //设置颜色与线宽
        UIColor *color = [UIColor colorWithHexString:Color_Items[(NSUInteger) path.colorIndex]];
        [color set];
        CGContextSetLineWidth(ctx, path.lineWidth);

        //检查路径中的点
        NSArray *curve = path.pointArr;
        if (curve.count >= 2) {

            //如果是橡皮擦
            if (path.drawType == Erase) {
                //设置为圆头
                CGContextSetLineCap(ctx, kCGLineCapRound);
                //设置清除颜色
                CGContextSetBlendMode(ctx, kCGBlendModeClear);
                CGContextSetLineWidth(ctx, 20);
            } else {
                CGContextSetBlendMode(ctx, kCGBlendModeNormal);
            }

            switch (path.drawType) {
                case Hand:
                case Erase: {
                    //画笔移到第一个点的位置
                    CGPoint pt = [curve[0] CGPointValue];
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, pt.x, pt.y);

                    CGPoint lastPt = pt;    //设置为上一个点
                    //CGContextSetStrokeColorWithColor(ctx, color.CGColor);
                    for (int i = 1; i < curve.count; i++) {
                        //移动到第i个点
                        pt = [curve[i] CGPointValue];
                        CGContextAddQuadCurveToPoint(ctx, lastPt.x, lastPt.y, (pt.x + lastPt.x) / 2, (pt.y + lastPt.y) / 2);
                        lastPt = pt;
                    }
                    //添加一条线连接到最后一个点
                    CGContextAddLineToPoint(ctx, pt.x, pt.y);
                    //描边
                    CGContextStrokePath(ctx);
                    break;
                }
                case Line: {
                    //画笔移到第一个点的位置
                    CGPoint pt = [curve.firstObject CGPointValue];
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, pt.x, pt.y);
                    //画一条线到第二个点
                    CGPoint lastPt = [curve.lastObject CGPointValue];
                    CGContextAddLineToPoint(ctx, lastPt.x, lastPt.y);
                    //描边
                    CGContextStrokePath(ctx);
                    break;
                }
                case LineArrow: {
                    //画笔移到第一个点的位置
                    CGPoint pt = [curve.firstObject CGPointValue];
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, pt.x, pt.y);
                    //画一条线到第二个点
                    CGPoint lastPt = [curve.lastObject CGPointValue];
                    CGContextAddLineToPoint(ctx, lastPt.x, lastPt.y);
                    CGFloat uX = (lastPt.x - pt.x) / fabs(lastPt.x - pt.x);
                    CGFloat uY = (lastPt.y - pt.y) / fabs(lastPt.y - pt.y);
                    CGContextAddLineToPoint(ctx, lastPt.x - 5 * uX, lastPt.y - 5 * uY);
                    //描边
                    CGContextStrokePath(ctx);
                    break;
                }
                case Rectangle: {
                    //画笔移到第一个点的位置
                    CGPoint pt = [curve.firstObject CGPointValue];
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, pt.x, pt.y);
                    //画矩形到第二个点
                    CGPoint lastPt = [curve.lastObject CGPointValue];
                    CGContextAddRect(ctx, CGRectMake(MIN(pt.x, lastPt.x), MIN(pt.y, lastPt.y), (CGFloat) fabs(pt.x - lastPt.x), (CGFloat) fabs(pt.y - lastPt.y)));
                    //描边
                    CGContextStrokePath(ctx);
                    break;
                }
                case Oval: {
                    //画笔移到第一个点的位置
                    CGPoint pt = [curve.firstObject CGPointValue];
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, pt.x, pt.y);
                    //画椭圆到第二个点
                    CGPoint lastPt = [curve.lastObject CGPointValue];
                    CGContextAddEllipseInRect(ctx, CGRectMake(MIN(pt.x, lastPt.x), MIN(pt.y, lastPt.y), (CGFloat) fabs(pt.x - lastPt.x), (CGFloat) fabs(pt.y - lastPt.y)));
                    //描边
                    CGContextStrokePath(ctx);
                    break;
                }
                default:
                    break;
            }
        }

        LWDrawView *drawView = [self superViewWithClass:[LWDrawView class]];
        //按点描绘底纹图
        if (curve.count > 0 && (path.drawType == EmojiTile || path.drawType == ImageTile)) {
            for (int i = 0; i < curve.count; i++) {
                //移动到第i个点
                CGPoint point = [curve[i] CGPointValue];
                CGRect brushRect = [self tileBrushRectForPoint:point withPath:path];
                __block UIImage *tileImage = [UIImage imageNamed:@"luowei"];
                NSString *name = Emoji_Items[path.tileImageIndex];
                if (path.drawType == ImageTile) {
                    name = path.tileImageUrl.absoluteString;
                }

                if (path.tileImageIndex < 5000) {
                    //从缓存目录找,没有才去相册加载
                    SDImageCache *imageCache = [SDImageCache sharedImageCache];
                    if ([imageCache diskImageExistsWithKey:[NSString stringWithFormat:@"tile_%lf_%@", path.lineWidth, name]]) {
                        tileImage = [imageCache imageFromDiskCacheForKey:[NSString stringWithFormat:@"tile_%lf_%@", path.lineWidth, name]];
                    } else {
                        if (path.drawType == ImageTile) {
                            CGFloat scale = [UIScreen mainScreen].scale;
                            [drawView.drawBar.tileSelectorView.photoPicker pictureWithURL:path.tileImageUrl size:CGSizeMake(path.lineWidth * 2 * scale, path.lineWidth * 2 * scale) imageBlock:^(UIImage *image) {
                                tileImage = image;
                            }];
                        } else {
                            tileImage = [name image:CGSizeMake(path.lineWidth * 2, path.lineWidth * 2)];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^() {
                            [[SDImageCache sharedImageCache] storeImage:tileImage forKey:[NSString stringWithFormat:@"tile_%lf_%@", path.lineWidth, name] toDisk:YES];
                        });
                    }
                }
                [tileImage drawInRect:brushRect];
            }

        }else if( path.drawType == Text && !path.isTextEditing){  //绘制文字
            NSString *textContent = path.text;
            CGRect textRect = path.textRect;
            if ((textContent != nil || textContent != @"") && textRect.size.height != 0 && !path.isTextEditing) {
                NSMutableParagraphStyle *textStyle = [NSMutableParagraphStyle new];
                textStyle.alignment = NSTextAlignmentNatural;

                NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName:path.fontName size:path.lineWidth * 5], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: textStyle};

                CGFloat textTextHeight = [textContent boundingRectWithSize:CGSizeMake(textRect.size.width, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin attributes:textFontAttributes context:nil].size.height;
                CGContextSaveGState(ctx);
                //CGContextClipToRect(ctx, textRect);
                [textContent drawInRect:CGRectMake(CGRectGetMinX(textRect), CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - textTextHeight) / 2, CGRectGetWidth(textRect), textTextHeight) withAttributes:textFontAttributes];
                CGContextRestoreGState(ctx);
            }
        }

    }

}


@end
