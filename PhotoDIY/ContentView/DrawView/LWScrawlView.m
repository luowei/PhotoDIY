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
#import "BezierUtils.h"

@implementation LWScrawlView {
    CGFloat keyboardHeight;
    BOOL keyboardIsShowing;
    CGFloat originY;
    UIPanGestureRecognizer *_rec;
    DrawStatus _drawStatus;
    BOOL _isRotating;
    BOOL _isControling;
    BOOL _isMoving;
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

    _drawStatus = Drawing;
    _isRotating = NO;
    _isControling = NO;
    _isMoving = NO;
    [self setEnableEdit:NO];

    _openShadow = NO;

}

- (void)setEnableEdit:(BOOL)enableEdit {
    _enableEdit = enableEdit;
    if(_enableEdit){
        self.controlView.rotate.hidden = NO;
        self.controlView.control.hidden = NO;
    }else{
        self.controlView.rotate.hidden = YES;
        self.controlView.control.hidden = YES;
    }
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
        if (keyboardHeight > self.textVConstY.constant) {
            frame.origin.y = -self.textVConstY.constant;
        } else {
            frame.origin.y = -keyboardHeight;
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
    [self exitEditingOrTexting];
    [self setNeedsDisplay];
}

- (UIImage *)scrawlImage{
    return [self snapshot];
}

//退出编辑以及文本输入状态
-(void)exitEditingOrTexting{
    _drawStatus = Drawing;
    _isRotating = NO;
    _isControling = NO;
    _isMoving = NO;
    self.controlView.hidden = YES;
    self.textView.hidden = YES;
    [self setNeedsDisplay];
}


//点击降下colourView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    if(!_enableEdit && _drawType != Text && _drawType != EmojiTile && _drawType != ImageTile){
        _drawStatus = Drawing;
        self.controlView.hidden = YES;
        [self.nextResponder touchesBegan:touches withEvent:event];
        return;
    }

    CGPoint point = [[touches anyObject] locationInView:self];

    LWDrafter *_currentDrafter = nil;
    //遍历_curves，查找当前触摸点是否在某个Path框内
    for (LWDrafter *path in _curves) {
        BOOL isZeroRect = path.rect.size.height == 0;
        if (!isZeroRect) {//Path所占矩形框不为0

            //编辑模式下，是否在控制范围内
            BOOL isNotType = path.drawType != Erase && path.drawType != Line && path.drawType != LineDash && path.drawType != LineArrow;
            BOOL isInControl = CGRectContainsPoint(CGRectInset(path.rect,-25,-25),point);
            if(isNotType && _drawStatus == Editing && path.isEditing && isInControl){
                if(path.drawType == Text){
                    CGPoint rotateOrigin = CGPointMake(path.rect.origin.x + path.rect.size.width - 25,path.rect.origin.y - 25);
                    CGRect rotateFrame = CGRectMake(rotateOrigin.x,rotateOrigin.y,50,50);
                    if(CGRectContainsPoint(rotateFrame,point)){
                        [self.nextResponder touchesBegan:touches withEvent:event];
                        return;
                    }
                }else{
                    [self.nextResponder touchesBegan:touches withEvent:event];
                    return;
                }

            }

            //触摸点在框内
            if(CGRectContainsPoint(path.rect, point)){
                _currentDrafter = path;
                _currentDrafter.isNew = NO;
            }
        }
    }

    DrawType type = _currentDrafter != nil ? _currentDrafter.drawType : self.drawType;
    switch (type) {
        case Text: {

            switch (_drawStatus) {
                case Drawing: {  //绘制模式
                    //添加一个path
                    if (_currentDrafter == nil) {
                        _currentDrafter = [[LWDrafter alloc] init];
                        _currentDrafter.text = @"";
                        _currentDrafter.rect = CGRectZero;
                        _currentDrafter.pointArr = [[NSMutableArray alloc] init];
                        _currentDrafter.colorIndex = self.freeInkColorIndex;
                        _currentDrafter.lineWidth = self.freeInkLinewidth;
                        _currentDrafter.fontName = self.fontName;
                        _currentDrafter.drawType = self.drawType;
                        _currentDrafter.openShadow = self.openShadow;
                        //把 _currentDrafter 添加 _curves 曲线集合中
                        [_curves addObject:_currentDrafter];

                        _drawStatus = Texting;
                        _currentDrafter.isEditing = NO;
                        _currentDrafter.isTexting = YES;

                        //设置文本框，并进入文本输入模式
                        [self setupTextViewWithPoint:point andDrafter:_currentDrafter];

                    } else {  //进入编辑模式
                        self.controlView.hidden = NO;
                        _drawStatus = Editing;
                        _currentDrafter.isEditing = YES;
                        //设置controlView
                        [self updateControlViewWithDrafter:_currentDrafter];
                    }
                    break;
                }

                case Editing: {  //编辑模式
                    if (_currentDrafter == nil) {   //输入绘制模式
                        _drawStatus = Drawing;
                        self.controlView.hidden = YES;
                        self.textView.hidden = YES;
                        _currentDrafter.isTexting = NO;
                        _currentDrafter.isEditing = NO;

                    } else {  //进入文本输入模式
                        self.controlView.hidden = YES;
                        _drawStatus = Texting;
                        _currentDrafter.isEditing = NO;
                        _currentDrafter.isTexting = YES;
                        //设置文本框，并进入文本输入模式
                        [self setupTextViewWithPoint:point andDrafter:_currentDrafter];

                    }
                    break;
                }

                case Texting: {  //文本输入模式
                    _drawStatus = Drawing;
                    self.controlView.hidden = YES;
                    //隐藏文本输入框并且退出文本输入模式
                    [self hideTextViewAndEndTexting];
                    break;
                }
                default:
                    break;
            }

            [self setNeedsDisplay];
            break;
        }

        case Hand:
        case CurveDash:
        case Rectangle:
        case RectangleDash:
        case RectangleFill:
        case Oval:
        case OvalDash:
        case OvalFill:{
            //隐藏文本输入框并且退出文本输入模式
            [self hideTextViewAndEndTexting];

            if(_currentDrafter != nil){ //在边框范围内点击
                BOOL isShape = _currentDrafter.drawType == Hand || _currentDrafter.drawType == CurveDash || _currentDrafter.drawType == Rectangle || _currentDrafter.drawType == RectangleDash  || _currentDrafter.drawType == RectangleFill
                        || _currentDrafter.drawType == Oval || _currentDrafter.drawType == OvalDash || _currentDrafter.drawType == OvalFill;
                if (isShape && !_currentDrafter.isEditing) {
                    _drawStatus = Editing;
                    _currentDrafter.isEditing = YES;
                    self.controlView.hidden = NO;
                    //设置controlView
                    [self updateControlViewWithDrafter:_currentDrafter];
                }else{
                    [self.nextResponder touchesBegan:touches withEvent:event];
                }
            }else { //不在边框范围内点击,退出编辑模式
                _drawStatus = Drawing;
                LWDrafter *editingDrafter = [self getEditingDrafter];
                editingDrafter.isEditing = NO;
                self.controlView.hidden = YES;
                [self.nextResponder touchesBegan:touches withEvent:event];
            }
            break;
        }

        case EmojiTile:
        case ImageTile: {    //表情/图片底纹填充
            //隐藏文本输入框并且退出文本输入模式
            [self hideTextViewAndEndTexting];

            BOOL isTile = _currentDrafter.drawType == EmojiTile || _currentDrafter.drawType == ImageTile;
            if(_currentDrafter != nil && isTile){   //在边框范围内点击

                if(!_currentDrafter.isEditing){ //不处于编辑状态
                    _drawStatus = Editing;
                    _currentDrafter.isEditing = YES;
                    self.controlView.hidden = NO;
                    //设置controlView
                    [self updateControlViewWithDrafter:_currentDrafter];
                }else{
                    [self.nextResponder touchesBegan:touches withEvent:event];
                }
            }else{  //在边框范围外点击
                //设置为绘制模式，并隐藏输入框
                _drawStatus = Drawing;
                _currentDrafter.isEditing = NO;
                self.controlView.hidden = YES;

                //添加一个点
                _currentDrafter = [[LWDrafter alloc] init];
                _currentDrafter.pointArr = [[NSMutableArray alloc] init];
                _currentDrafter.colorIndex = self.freeInkColorIndex;
                _currentDrafter.lineWidth = self.freeInkLinewidth;
                _currentDrafter.tileImageIndex = self.tileImageIndex;
                _currentDrafter.tileImageUrl = self.tileImageUrl;
                _currentDrafter.drawType = self.drawType;
                _currentDrafter.openShadow = self.openShadow;
                //把 _currentDrafter 添加 _curves 曲线集合中
                [_curves addObject:_currentDrafter];
                [_currentDrafter.pointArr addObject:[NSValue valueWithCGPoint:point]];

                [self.nextResponder touchesBegan:touches withEvent:event];
            }
            [self setNeedsDisplay];
            break;
        }

        default:
            [self.nextResponder touchesBegan:touches withEvent:event];
            break;
    }

}

//设置controlView
- (void)updateControlViewWithDrafter:(LWDrafter *)_currentDrafter {
    //设置controlView
    self.controlViewConstX.constant = CGRectGetMinX(_currentDrafter.rect);
    self.controlViewConstY.constant = CGRectGetMinY(_currentDrafter.rect);
    self.controlViewWidth.constant = CGRectGetWidth(_currentDrafter.rect);
    self.controlViewHeight.constant = CGRectGetHeight(_currentDrafter.rect);
    [self.controlView setTransform:CGAffineTransformMakeRotation(_currentDrafter.rotateAngle * M_PI / 180)];
    [self.controlView setNeedsDisplay];
}

//隐藏文本输入框并且退出文本输入模式
- (void)hideTextViewAndEndTexting {
    self.textView.hidden = YES;
    LWDrafter *editingDrafter = [self getTextingDrafter];
    //把当前处于文本输入模式的drafter的isTexting设置为NO,进入绘制模式
    if (editingDrafter != nil) {
        editingDrafter.isTexting = NO;
        editingDrafter.isEditing = NO;
        editingDrafter.text = self.textView.text;
        editingDrafter.rect = self.textView.frame;
        editingDrafter.fontName = self.textView.font.fontName;
        [self.textView resignFirstResponder];
    }
}


//设置文本框，并进入文本输入模式
- (void)setupTextViewWithPoint:(CGPoint)point andDrafter:(LWDrafter *)_currentDrafter {
    //设置textView的样式
    UIColor *color = [UIColor colorWithHexString:Color_Items[(NSUInteger) _currentDrafter.colorIndex]];
    self.textView.textColor = color;
    self.textView.text = _currentDrafter.text;
    self.textView.font = [UIFont fontWithName:_currentDrafter.fontName size:_currentDrafter.lineWidth * 5];
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.cornerRadius = _currentDrafter.lineWidth;
    self.textView.layer.borderColor = color.CGColor;

    //进入文本输入模式,显示textView,并设置它的位置
    self.textView.hidden = NO;
    CGSize textVSize = self.textView.bounds.size;
    if (_currentDrafter.isNew) {
        self.textVConstX.constant = point.x - textVSize.width / 2;
        self.textVConstY.constant = point.y - textVSize.height / 2;
        [self.textView becomeFirstResponder];
    } else {
        self.textVConstX.constant = CGRectGetMinX(_currentDrafter.rect);
        self.textVConstY.constant = CGRectGetMinY(_currentDrafter.rect);
    }

    //旋转
    [self.textView setTransform:CGAffineTransformMakeRotation(_currentDrafter.rotateAngle * M_PI / 180)];
}

//获取正处于编辑状态的drafter
- (LWDrafter *)getEditingDrafter {
    LWDrafter *editingDrafter = nil;
    //遍历_curves，找出正在编辑的path
    for (LWDrafter *draf in _curves) {
        if (draf.isEditing) {
            editingDrafter = draf;
        }
    }
    return editingDrafter;
}

//获取正处于文本输入状态的drafter
- (LWDrafter *)getTextingDrafter {
    LWDrafter *editingDrafter = nil;
    //遍历_curves，找出正在编辑的path
    for (LWDrafter *draf in _curves) {
        if (draf.isTexting) {
            editingDrafter = draf;
        }
    }
    return editingDrafter;
}

//获取正处于编辑或文本输入状态的drafter
- (LWDrafter *)getEditingAndTextingDrafter {
    LWDrafter *editingDrafter = nil;
    //遍历_curves，找出正在编辑的path
    for (LWDrafter *draf in _curves) {
        if (draf.isEditing || draf.isTexting) {
            editingDrafter = draf;
        }
    }
    return editingDrafter;
}


//手势滑动
- (void)onDrag:(UIPanGestureRecognizer *)rec {
    CGPoint beganPoint;
    CGPoint movePoint;
    CGPoint endPoint;

    switch (rec.state) {
        case UIGestureRecognizerStateBegan: {
            beganPoint = [rec locationInView:self];

            if (_drawStatus == Drawing) {
                LWDrafter *currentPath = [[LWDrafter alloc] init];
                currentPath.pointArr = [[NSMutableArray alloc] init];
                currentPath.colorIndex = self.freeInkColorIndex;
                currentPath.lineWidth = self.freeInkLinewidth;
                currentPath.tileImageIndex = self.tileImageIndex;
                currentPath.tileImageUrl = self.tileImageUrl;
                currentPath.openShadow = self.openShadow;
                currentPath.drawType = self.drawType;
                [_curves addObject:currentPath];

                [currentPath.pointArr addObject:[NSValue valueWithCGPoint:beganPoint]];

            }else if(_drawStatus == Editing && _enableEdit){
                LWDrafter *editingDrafter = [self getEditingAndTextingDrafter];
                BOOL isNotType = editingDrafter.drawType != Erase && editingDrafter.drawType != Line && editingDrafter.drawType != LineDash && editingDrafter.drawType != LineArrow;

                CGPoint convertedPoint = [rec locationInView:self.controlView];

                if(isNotType && editingDrafter.isEditing){
                    //判断触摸点是否在旋转按钮范围内
                    CGRect rotateRect = [self.controlView convertRect:self.controlView.rotate.frame toView:self.controlView];
                    CGFloat rDeta = rotateRect.size.width/2 - MIN(self.controlView.frame.size.width/4,self.controlView.frame.size.height/4);
                    BOOL isRotateInside = CGRectContainsPoint(CGRectInset(rotateRect,rDeta,rDeta),convertedPoint);

                    //判断触摸点是否在缩放按钮范围内
                    CGRect controlRect = [self.controlView convertRect:self.controlView.control.frame toView:self.controlView];
                    CGFloat cDeta = controlRect.size.width/2 - MIN(self.controlView.frame.size.width/4,self.controlView.frame.size.height/4);
                    BOOL isControlInside = CGRectContainsPoint(CGRectInset(controlRect,cDeta,cDeta),convertedPoint);

                    //判断触摸点是否在移动范围内
                    CGRect cvBounds = self.controlView.bounds;
                    CGRect movingRect = CGRectInset(cvBounds,cvBounds.size.width/4,cvBounds.size.height/4);
                    BOOL isMovingInside = CGRectContainsPoint(movingRect,convertedPoint);

                    if(isRotateInside){ //如果在旋钮范围内
                        _isRotating = YES;
                        _isControling = NO;
                        _isMoving = NO;
                    }else if(isControlInside){  //在控制按钮范围内
                        _isControling = YES;
                        _isRotating = NO;
                        _isMoving = NO;
                    }else if(isMovingInside){   //在移动范围内
                        _isControling = NO;
                        _isRotating = NO;
                        _isMoving = YES;
                    }

                    return;
                }

            }

            break;
        }
        case UIGestureRecognizerStateChanged: {

            movePoint = [rec locationInView:self];
            if (_drawStatus == Editing && _enableEdit) { //编辑模式
                //移动文本输入框
                LWDrafter *editingDrafter = [self getEditingAndTextingDrafter];
                BOOL isNotType = editingDrafter.drawType != Erase && editingDrafter.drawType != Line && editingDrafter.drawType != LineDash && editingDrafter.drawType != LineArrow && editingDrafter.drawType != Text;

                if (editingDrafter.drawType == Text) {
                    if(_isRotating){
                        //计算角度
                        CGPoint center = CGPointMake(CGRectGetMidX(editingDrafter.rect), CGRectGetMidY(editingDrafter.rect));
                        CGFloat movingAngle = (CGFloat) atan2(movePoint.y - center.y,movePoint.x - center.x);
                        //旋转
                        [self.controlView setTransform:CGAffineTransformMakeRotation(movingAngle)];
                        editingDrafter.rotateAngle = (CGFloat) (movingAngle * 180 / M_PI);

                    }else{
                        //更新controlView
                        [self updateControlViewFrameWithPoint:movePoint drafter:editingDrafter];
                        //更新textView
                        self.textVConstX.constant = movePoint.x - CGRectGetWidth(editingDrafter.rect) / 2;
                        self.textVConstY.constant = movePoint.y - CGRectGetHeight(editingDrafter.rect) / 2;

                        [editingDrafter.pointArr addObject:[NSValue valueWithCGPoint:movePoint]];

                    }

                }else if(isNotType){
                    if(_isRotating){ //旋转控制
                        //计算角度
                        CGPoint center = CGPointMake(CGRectGetMidX(editingDrafter.rect), CGRectGetMidY(editingDrafter.rect));
                        CGFloat movingAngle = (CGFloat) atan2(movePoint.y - center.y,movePoint.x - center.x);
                        //旋转
                        [self.controlView setTransform:CGAffineTransformMakeRotation(movingAngle)];
                        editingDrafter.rotateAngle = (CGFloat) (movingAngle * 180 / M_PI);

                    }else if(_isControling){ //缩放控制
                        CGPoint origin = CGPointMake(CGRectGetMinX(editingDrafter.rect), CGRectGetMinY(editingDrafter.rect));
                        CGFloat sW = (CGFloat) fabs(movePoint.x - origin.x);
                        CGFloat sH = (CGFloat) fabs(movePoint.y - origin.y);
                        editingDrafter.scaleRect = CGRectMake(MIN(movePoint.x,origin.x),MIN(movePoint.y,origin.y),sW,sH);

                        //更新controlView
                        self.controlViewWidth.constant = sW;
                        self.controlViewHeight.constant = sH;
                        self.controlViewConstX.constant = editingDrafter.scaleRect.origin.x;
                        self.controlViewConstY.constant = editingDrafter.scaleRect.origin.y;
                        [self.controlView setNeedsDisplay];
                        if(editingDrafter.drawType != Hand || editingDrafter.drawType != CurveDash){
                            [editingDrafter.pointArr addObject:[NSValue valueWithCGPoint:movePoint]];
                        }
                    }else if(_isMoving) {
                        //更新controlView
                        [self updateControlViewFrameWithPoint:movePoint drafter:editingDrafter];
                        editingDrafter.movePoint = movePoint;
                    }
                }

            } else {  //绘制模式
                LWDrafter *currentPath = [_curves lastObject];
                [currentPath.pointArr addObject:[NSValue valueWithCGPoint:movePoint]];
            }

            [self setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            endPoint = [rec locationInView:self];
            if (_drawStatus == Editing && _enableEdit) { //编辑模式

                _isMoving = NO;
                _isControling = NO;
                _isRotating = NO;

            } else {  //绘制模式
                LWDrafter *currentPath = [_curves lastObject];
                [currentPath.pointArr addObject:[NSValue valueWithCGPoint:endPoint]];
            }

            _isRotating = NO;
            _isControling = NO;
            [self setNeedsDisplay];
            break;
        }
        default:
            break;
    }

}

//更新ControlView
- (void)updateControlViewFrameWithPoint:(CGPoint)movePoint drafter:(LWDrafter *)editingDrafter {
    CGFloat x = movePoint.x - CGRectGetWidth(editingDrafter.rect) / 2;
    CGFloat y = movePoint.y - CGRectGetHeight(editingDrafter.rect) / 2;
    CGFloat width = CGRectGetWidth(editingDrafter.rect);
    CGFloat height = CGRectGetHeight(editingDrafter.rect);
    self.controlViewWidth.constant = width;
    self.controlViewHeight.constant = height;
    self.controlViewConstX.constant = x;
    self.controlViewConstY.constant = y;
    [self.controlView setNeedsDisplay];

    editingDrafter.rect = CGRectMake(x, y, width, height);
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
                case CurveDash:
                case Erase: {
                    [self drawCurveWithPoits:points withDrawer:drafter];
                    break;
                }
                case Line:
                case LineDash:{
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
                case Rectangle:
                case RectangleDash:
                case RectangleFill: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    drafter.rect = CGRectMake(MIN(pt.x, lastPt.x), MIN(pt.y, lastPt.y), (CGFloat) fabs(pt.x - lastPt.x), (CGFloat) fabs(pt.y - lastPt.y));
                    [self drawRectangleWithDrafter:drafter];
                    break;
                }
                case Oval:
                case OvalDash:
                case OvalFill: {
                    CGPoint pt = [points.firstObject CGPointValue];
                    CGPoint lastPt = [points.lastObject CGPointValue];
                    drafter.rect = CGRectMake(MIN(pt.x, lastPt.x), MIN(pt.y, lastPt.y), (CGFloat) fabs(pt.x - lastPt.x), (CGFloat) fabs(pt.y - lastPt.y));
                    [self drawOvalWithDrafter:drafter];
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

                UIImage *tileImage = [self getTileImageWithDrafter:drafter];

                CGFloat width = tileImage.size.width;
                CGFloat height = tileImage.size.height;
                CGSize imgSize = CGSizeMake(height , width);
                if(width > height){
                    imgSize = CGSizeMake(drafter.burshSize.width,drafter.burshSize.height * height/width);
                }else{
                    imgSize = CGSizeMake(drafter.burshSize.width * width/height,drafter.burshSize.height);
                }
                CGRect brushRect = CGRectMake(point.x - imgSize.width / 2, point.y - imgSize.height / 2, imgSize.width, imgSize.height);

                //绘制tileImage
                [tileImage drawInRect:brushRect];
            }

        } else if (drafter.drawType == Text && !drafter.isTexting) {  //绘制文字
            if ((drafter.text != nil || drafter.text != @"") && drafter.rect.size.height != 0 && !drafter.isTexting) {
                [self drawTextWithDrafter:drafter];
            }
        }

    }


}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateControlVWithTextView:textView];
}

- (void)updateControlVWithTextView:(UITextView *)textView {
//    CGPoint point = CGPointMake(CGRectGetMidX(textView.frame), CGRectGetMidY(textView.frame));
//    CGSize textVSize = self.textView.bounds.size;
//    self.textVConstX.constant = point.x - textVSize.width / 2;
//    self.textVConstY.constant = point.y - textVSize.height / 2;
//    self.controlViewWidth.constant = textVSize.width + 6;
//    self.controlViewHeight.constant = textVSize.height + 6;
//    self.controlViewConstX.constant = point.x - (textVSize.width + 6) / 2;
//    self.controlViewConstY.constant = point.y - (textVSize.height + 6) / 2;
}


#pragma mark - 图形绘制方法

//根据drafter获得一张TileImage
- (UIImage *)getTileImageWithDrafter:(LWDrafter *)drafter {
    //获得tileImage
    __block UIImage *tileImage = [UIImage imageNamed:@"luowei"];
    if(drafter.tileImageIndex == 10000){
        return tileImage;
    }
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSShadow *shadow = drafter.shadow;

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

    //旋转UIBezierPath
    [pointsPath rotateDegree:drafter.rotateAngle];
    if(drafter.movePoint.x != 0 || drafter.movePoint.y != 0){
        //移动UIBezierPath
        [pointsPath moveCenterToPoint:drafter.movePoint];
    }
    //缩放
    if(!CGRectEqualToRect(drafter.scaleRect,CGRectZero) && !CGRectEqualToRect(drafter.scaleRect,drafter.rect)){
        AdjustPathToRect(pointsPath,drafter.scaleRect);
    }

    //开启阴影
    if(drafter.openShadow){
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    }

    //如果是虚线类型
    if(drafter.drawType == CurveDash){
        [pointsPath setLineDash: (CGFloat[]){6 * drafter.lineWidth, 2 * drafter.lineWidth} count: 2 phase: 0];
    }
    
    [drafter.color setStroke];
    pointsPath.lineWidth = drafter.lineWidth;
    [pointsPath stroke];


    if(drafter.openShadow){
        CGContextRestoreGState(context);
    }

    //当drafter还没有值时，就设置path的Rect
    if(drafter.rotateAngle == 0){
        drafter.rect = pointsPath.bounds;
    }
    drafter.pathBounds = pointsPath.bounds;
}

//画椭圆
- (void)drawOvalWithDrafter:(LWDrafter *)drafter {
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSShadow *shadow = drafter.shadow;

    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:drafter.rect];

    //旋转UIBezierPath
    [ovalPath rotateDegree:drafter.rotateAngle];
    if(drafter.movePoint.x != 0 || drafter.movePoint.y != 0){
        //移动UIBezierPath
        [ovalPath moveCenterToPoint:drafter.movePoint];
    }

    //开启阴影
    if(drafter.openShadow){
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    }

    //如是填充类型，就填充颜色
    if(drafter.drawType == OvalFill){
        [drafter.color setFill];
        [ovalPath fill];
    }

    //如果是虚线类型
    if(drafter.drawType == OvalDash){
        [ovalPath setLineDash: (CGFloat[]){6 * drafter.lineWidth, 2 * drafter.lineWidth} count: 2 phase: 0];
    }

    [drafter.color setStroke];
    ovalPath.lineWidth = drafter.lineWidth;
    [ovalPath stroke];

    if(drafter.openShadow){
        CGContextRestoreGState(context);
    }

    //设置当前path的Rect
    if(drafter.rotateAngle == 0){
        drafter.rect = ovalPath.bounds;
    }
    drafter.pathBounds = ovalPath.bounds;

}

//画矩形
- (void)drawRectangleWithDrafter:(LWDrafter *)drafter {
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSShadow *shadow = drafter.shadow;

    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:drafter.rect];

    //缩放UIBezierPath
    BOOL needScale = !CGRectEqualToRect(drafter.rect,drafter.scaleRect) && CGRectContainsPoint(drafter.scaleRect,drafter.rect.origin);
    if(needScale){
        AdjustPathToRect(rectanglePath,drafter.scaleRect);
    }

    //旋转UIBezierPath
    [rectanglePath rotateDegree:drafter.rotateAngle];

    if(drafter.movePoint.x != 0 || drafter.movePoint.y != 0){
        //移动UIBezierPath
        [rectanglePath moveCenterToPoint:drafter.movePoint];
    }

    //开启阴影
    if(drafter.openShadow){
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    }

    //如是填充类型，就填充颜色
    if(drafter.drawType == RectangleFill){
        [drafter.color setFill];
        [rectanglePath fill];
    }

    //如果是虚线类型
    if(drafter.drawType == RectangleDash){
        [rectanglePath setLineDash: (CGFloat[]){6 * drafter.lineWidth, 2 * drafter.lineWidth}  count: 2 phase: 0];
    }

    [drafter.color setStroke];
    rectanglePath.lineWidth = drafter.lineWidth;
    [rectanglePath stroke];

    if(drafter.openShadow){
        CGContextRestoreGState(context);
    }

    //设置当前path的Rect
    if(drafter.rotateAngle == 0){
        drafter.rect = rectanglePath.bounds;
    }
    drafter.pathBounds = rectanglePath.bounds;
}

//画直线
- (void)drawLineFromPoint1:(CGPoint)p1 toPoint2:(CGPoint)p2 withDrafter:(LWDrafter *)drafter {
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSShadow *shadow = drafter.shadow;

    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:p1];     //画笔移到第一个点的位置
    [linePath addLineToPoint:p2];      //画一条线到第二个点
    linePath.lineCapStyle = kCGLineCapRound;

    //开启阴影
    if(drafter.openShadow){
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    }

    //如果是虚线类型
    if(drafter.drawType == LineDash){
        [linePath setLineDash: (CGFloat[]){6 * drafter.lineWidth, 2 * drafter.lineWidth} count: 2 phase: 0];
    }
    
    [drafter.color setStroke];
    linePath.lineWidth = drafter.lineWidth;
    [linePath stroke];

    if(drafter.openShadow){
        CGContextRestoreGState(context);
    }
}

//画文字
- (void)drawTextWithDrafter:(LWDrafter *)drafter {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Declarations
    NSString *textContent = drafter.text;
    UIColor *color = drafter.color;
    CGRect rect = drafter.rect;
    CGFloat angle = drafter.rotateAngle;
    NSShadow *shadow = drafter.shadow;

    //// Variable Declarations
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    CGPoint offset = CGPointMake(-rect.size.width / 2.0, -rect.size.height / 2.0);

    //// Text Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, center.x, center.y);
    CGContextRotateCTM(context, angle * M_PI / 180);

    CGRect textRect = CGRectMake(offset.x, offset.y, rect.size.width, rect.size.height);
    {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
        NSMutableParagraphStyle *textStyle = [NSMutableParagraphStyle new];
        textStyle.alignment = NSTextAlignmentLeft;

        NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName:drafter.fontName size:drafter.lineWidth * 5], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: textStyle};

        CGFloat textTextHeight = [textContent boundingRectWithSize:CGSizeMake(textRect.size.width, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin attributes:textFontAttributes context:nil].size.height;
        CGContextSaveGState(context);
        CGContextClipToRect(context, textRect);
        CGRect drawTextRect = CGRectMake(CGRectGetMinX(textRect), CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - textTextHeight) / 2, CGRectGetWidth(textRect), textTextHeight);
        [textContent drawInRect:drawTextRect withAttributes:textFontAttributes];
        CGContextRestoreGState(context);
        CGContextRestoreGState(context);

    }

    CGContextRestoreGState(context);

}

//画图片
- (void)drawImageWithFrame:(CGRect)imageFrame andDrafter:(LWDrafter *)drafter {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();


    //// Declarations
    UIImage *image = [UIImage imageNamed:@"luowei"];

    //// Variable Declarations
    CGPoint center = CGPointMake((CGFloat) (imageFrame.origin.x + imageFrame.size.width / 2.0), (CGFloat) (imageFrame.origin.y + imageFrame.size.height / 2.0));
    CGPoint offset = CGPointMake((CGFloat) (-imageFrame.size.width / 2.0), (CGFloat) (-imageFrame.size.height / 2.0));

    //获得角度
    NSString *key = [NSString stringWithFormat:@"%f,%f", center.x, center.y];
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

    //设置当前path的Rect
    drafter.rect = imageFrame;
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

        //开启阴影
        if(drafter.openShadow){
            CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
        }

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


- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    //绘制虚线框
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor colorWithHexString:@"ff4000"] setStroke];
    rectanglePath.lineWidth = 1;
    CGFloat rectanglePattern[] = {4, 2};
    [rectanglePath setLineDash:rectanglePattern count:2 phase:0];
    [rectanglePath stroke];
}


@end
