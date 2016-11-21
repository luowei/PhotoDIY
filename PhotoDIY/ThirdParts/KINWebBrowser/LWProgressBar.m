//
//  LWProgressBar.m
//  union
//
//  Created by apple on 16/5/6.
//  Copyright © 2016年 wodedata.com. All rights reserved.
//

#import "LWProgressBar.h"

@interface LWProgressBar ()

@property(nonatomic, strong) NSTimer *progressTimer;

@end

@implementation LWProgressBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.progressView];
    }
    return self;
}

- (void)progressUpdate:(CGFloat)progress {
    if (!_isLoading) { return; }
    
    if (progress == 1) {
        if (CGRectGetWidth(self.frame) > 0) {
            [self finishProgress];
        }
    } else {
        _progress = progress;
        [self initProgressTimer];
    }
}

- (void)setProgressZero {
    [self deallocProgressTimer];
//    _progressView.width = 0;
    [self setWidth:0 forView:_progressView];
}

- (void)initProgressTimer {
    if (!_progressTimer || !_progressTimer.isValid) {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(progressTimerAction:) userInfo:nil repeats:YES];
    }
}

- (void)finishProgress {
    [self deallocProgressTimer];
    NSTimeInterval inter = .2;
    if (_progressView.frame.size.width < CGRectGetWidth(self.frame) * 0.5) {
        inter = .3;
    }
    
    if (_progressView.frame.size.width > 0) {
        [UIView animateWithDuration:inter animations:^{
            [self setWidth:CGRectGetWidth(self.frame) forView:_progressView]; //先滑到最后再消失
        } completion:^(BOOL finished) {
            [self setWidth:0 forView:_progressView];
        }];
    }
}

- (void)deallocProgressTimer {
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (void)progressTimerAction:(NSTimer *)timer {
    if (!_isLoading) {
        [self finishProgress];
        return;
    }
    
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat progressWidth = viewWidth * 0.005; //千分之五,4s钟走完
    CGFloat currentProgressWidth = _progressView.frame.size.width;
    CGFloat currentProgress = currentProgressWidth / viewWidth;
    
    if (currentProgress < _progress) {
        //当前的进度比真实进度慢，快速加载
        progressWidth = viewWidth * 0.01;
    }
    
    if (currentProgressWidth < viewWidth * 0.98) {
        //到达99%的时候等待网页进度
        [self setWidth:currentProgressWidth + progressWidth forView:_progressView];
    } else {
        if (!_isLoading) {
            [self finishProgress];
        }
    }
}

#pragma mark - Getter

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        _progressView.backgroundColor = [UIColor whiteColor];
    }
    return _progressView;
}

- (void)setWidth:(CGFloat)width forView:(UIView *)view{
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}


@end
