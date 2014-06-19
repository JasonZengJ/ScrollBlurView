//
//  ScrollBlurView.m
//  ScrollBlurView
//
//  Created by jason on 6/19/14.
//  Copyright (c) 2014 jason. All rights reserved.
//

#import "ScrollBlurView.h"
#import "UIColor+Extension.h"
#import <Accelerate/Accelerate.h>

#define MiddleYPosition 223


@interface ScrollBlurView ()

@property(nonatomic) CGPoint      beginPosition;
@property(nonatomic) CGPoint      stopPostion;
@property(nonatomic) CGFloat      yPosition;
@property(nonatomic) CGFloat      pi;
@property(nonatomic) CGFloat      duration;
@property(nonatomic) CGFloat      swipeCondition;
@property(nonatomic) BOOL         isAnimationReset;
@property(nonatomic) UIButton    *swipeDownBtn;
@property(nonatomic) UIView      *blurView;
@property(nonatomic) UIImageView *blurImageView;
@property(nonatomic) CGFloat      viewHeight;
@property(nonatomic) CGFloat      viewWidth;

@end

@implementation ScrollBlurView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Init
        self.backgroundColor = [UIColor colorWithHex:0x212121 alpha:0.7];
        
        _viewHeight          = frame.size.height;
        _viewWidth           = frame.size.width;
        _swipeDownBtn        = [[UIButton alloc] initWithFrame:CGRectMake(140, 5, 40, 40) ];
        
        [_swipeDownBtn setBackgroundImage:[UIImage imageNamed:@"anchor.png"] forState:UIControlStateNormal];
        [_swipeDownBtn addTarget:self action:@selector(swipeInit:) forControlEvents:UIControlEventTouchDown];
        
        UIPanGestureRecognizer *panGR  = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeView:) ];
        panGR.minimumNumberOfTouches   = 1;
        panGR.maximumNumberOfTouches   = 1;
        
        [_swipeDownBtn addGestureRecognizer:panGR];
        
        [self addSubview:_swipeDownBtn];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

- (void)addBlurView:(UIView*)view withRadius:(CGFloat)radius
{
    UIImage *captureImage   = [self captureView:view];
    UIImage *blurImage      = [self blurImage:captureImage WithRadius:radius];
    _blurImageView          = [[UIImageView alloc] initWithImage:blurImage];
    _blurImageView.frame    = CGRectMake(0, -_viewHeight,_viewWidth , _viewHeight);
    _blurView               = [[UIView alloc] initWithFrame:CGRectMake(0, _viewHeight , _viewWidth,0 )];
    _blurView.clipsToBounds = YES;
    [_blurView addSubview:_blurImageView];
    [self.superview addSubview:_blurView];
    [self.superview bringSubviewToFront:self];
}

- (UIImage *)blurImage:(UIImage *)image WithRadius:(CGFloat)blurRadius
{
    if ((blurRadius < 0.0f) || (blurRadius > 1.0f)) {
        blurRadius = 0.5f;
    }
    int boxSize = (int)(blurRadius * 100);
    boxSize    -= (boxSize % 2) + 1;
    
    CGImageRef rawImage = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error  error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
    CFDataRef inBitmapData       = CGDataProviderCopyData(inProvider);
    
    inBuffer.width     = CGImageGetWidth(rawImage);
    inBuffer.height    = CGImageGetHeight(rawImage);
    inBuffer.rowBytes  = CGImageGetBytesPerRow(rawImage);
    inBuffer.data      = (void *)CFDataGetBytePtr(inBitmapData);
    pixelBuffer        = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
    
    outBuffer.data     = pixelBuffer;
    outBuffer.width    = CGImageGetWidth(rawImage);
    outBuffer.height   = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error for convolution %ld",error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx           = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(image.CGImage));
    CGImageRef imageRef        = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage       = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (UIImage *)captureView:(UIView *)view
{
    UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextFillRect(ctx, [UIScreen mainScreen].bounds);
    [view.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)animateDownWithDuration:(NSTimeInterval)duration
{
    
    [UIView animateWithDuration:duration animations:^(){
        _blurView.frame      = CGRectMake(0,   _viewHeight, _viewWidth, _viewHeight);
        _blurImageView.frame = CGRectMake(0, - _viewHeight, _viewWidth, _viewHeight);
        self.frame           = CGRectMake(0,   _viewHeight, _viewWidth, _viewHeight);
    }];
    
}

- (void)animateUpWithDuration:(NSTimeInterval)duration
{
    
    [UIView animateWithDuration:duration animations:^(){
        _blurView.frame      = CGRectMake(0,   20, _viewWidth, _viewHeight);
        _blurImageView.frame = CGRectMake(0, - 20, _viewWidth, _viewHeight);
        self.frame           = CGRectMake(0,   20, _viewWidth, _viewHeight);
    }];
    
}

- (void)swipeView:(UIPanGestureRecognizer*)sender{
    
    CGPoint currentPosition = [sender locationInView:self.superview];
    if(currentPosition.y == _beginPosition.y) return;
    CGFloat currentPI = (currentPosition.x - _beginPosition.x)/currentPosition.y;
    NSLog(@"rotate:%f",currentPI);
    
    if (-1.30 < currentPI && currentPI < 1.30) {
        _swipeDownBtn.transform = CGAffineTransformMakeRotation(- currentPI);
        _pi = currentPI;
    }
    if (currentPosition.y > _yPosition) {
        CGFloat y            = currentPosition.y -  _beginPosition.y;
        self.frame           = CGRectMake(0,  y, _viewWidth, _viewHeight);
        _blurView.frame      = CGRectMake(0,  y, _viewWidth, _viewHeight);
        _blurImageView.frame = CGRectMake(0, -y, _viewWidth, _viewHeight);
        
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        _duration         = 0.4;
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        _stopPostion = self.frame.origin;
        
        [self animation:_duration target:self  completion:@selector(swipeAnimate:) animation:^(){
            _swipeDownBtn.transform = CGAffineTransformMakeRotation(_pi);
        }];
        
        if(_stopPostion.y > MiddleYPosition){
            [self animateDownWithDuration:0.4];
        }else{
            [self animateUpWithDuration:0.4];
        }
    }
    NSLog(@"Begin Position:(%f,%f) Current Position:(%f,%f)",_beginPosition.x,_beginPosition.y,currentPosition.x,currentPosition.y);
    
}

- (void)swipeInit:(UIButton *)sender{
    
    _beginPosition    = CGPointMake(_swipeDownBtn.frame.origin.x +30, _swipeDownBtn.frame.origin.y + 43 );
    _yPosition        = _beginPosition.y + 20;
    _duration         = 0.4;
    _isAnimationReset = YES;
    NSLog(@"begin duration:%f",_duration);
    
}

- (void)swipeAnimate:(id)sender{
    
    NSLog(@"pi:%f,duration:%f",_pi,_duration);
    _swipeCondition = _pi * 100;
    if ((-1.0 < _swipeCondition && _swipeCondition < 1.0 ) || _isAnimationReset) {
        return;
    }
    _pi       *= -0.8;
    _duration *= 0.9;
    [self animation:_duration target:self completion:@selector(swipeAnimate:) animation:^(){
        _swipeDownBtn.transform = CGAffineTransformMakeRotation(_pi);
    }];
    
    
}

- (void)animation:(NSTimeInterval)duration target:(id)target completion:(SEL)action animation:(void (^)())animationBlock
{
    _isAnimationReset = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:target];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    animationBlock();
    [UIView setAnimationDidStopSelector:action];
    [UIView commitAnimations];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
