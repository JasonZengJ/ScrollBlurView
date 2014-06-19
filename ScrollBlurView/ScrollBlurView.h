//
//  ScrollBlurView.h
//  ScrollBlurView
//
//  Created by jason on 6/19/14.
//  Copyright (c) 2014 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollBlurView : UIView

- (void)animateUpWithDuration:(NSTimeInterval)duration;
- (void)addBlurView:(UIView*)view withRadius:(CGFloat)radius;
@end
