//
//  UIColor+view.m
//  ScrollBlurView
//
//  Created by jason on 6/19/14.
//  Copyright (c) 2014 jason. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor *)colorWithHex:(uint)hex alpha:(CGFloat)alpha
{
    int red,green,blue;
    
    blue  = (hex  & 0x0000FF);
    green = ((hex & 0x00FF00) >> 8);
    red   = ((hex & 0xFF0000) >> 16);
    
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
    
}

@end
