//
//  QTSlider.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/6.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTSlider.h"

@implementation QTSlider

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configSlider];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configSlider];
    }
    return self;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    return [super beginTrackingWithTouch:touch withEvent:event];
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event {
    return [super continueTrackingWithTouch:touch withEvent:event];
}
- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.onEndTracing) {
            self.onEndTracing(self);
        }
    });
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect r = [super thumbRectForBounds:bounds trackRect:rect value:value];
    r = CGRectInset(r, r.size.width/3.f, r.size.height/3.f);
    return r;
}

- (void)configSlider {
    CGSize size = CGSizeMake(10, 10);
    UIImage *img = [self.class imageWithColor:[UIColor whiteColor] size:size];
    img = [self imageWithRoundedCornerRadius:size.height/2.f image:img];
    [self setThumbImage:img forState:UIControlStateNormal];
    [self setThumbImage:img forState:UIControlStateHighlighted];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithRoundedCornerRadius:(CGFloat)radius image:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGRect bounds =CGRectMake(0, 0, image.size.width, image.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius:radius] addClip];
    [image drawInRect:bounds];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
