//
//  QTSplashView.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/8.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTSplashView.h"
#import "QTCarveLabel.h"
#import "QTShadowView.h"

#define kQTSVHeight     (UIScreen.mainScreen.bounds.size.height*2/4.f)
#define kQTSVTopMargin  ((UIScreen.mainScreen.bounds.size.height)-kQTSVHeight)

@interface QTSplashView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *sloganLabel;
@property (nonatomic, strong) QTShadowView *gradientView;

@end

@implementation QTSplashView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
        self.imageView.image = [UIImage imageNamed:@"s1.jpg"];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        QTShadowView *shadow = [QTShadowView new];
        CAGradientLayer *gradient = (CAGradientLayer *)shadow.layer;
        self.gradientView = shadow;
        CGColorRef c1 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor;
        CGColorRef c2 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        CGColorRef c3 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
        CGColorRef c4 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
        CGColorRef c5 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;
        CGColorRef c6 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;

        gradient.colors = @[(__bridge id)c1, (__bridge id)c2, (__bridge id)c3, (__bridge id)c4, (__bridge id)c5, (__bridge id)c6];
        gradient.locations = @[@0.1, @0.3, @0.4, @0.5, @0.7, @1];
        gradient.startPoint = CGPointMake(0.5, 0);
        gradient.endPoint = CGPointMake(0.5, 1);
        gradient.frame = CGRectMake(0, kQTSVTopMargin, UIScreen.mainScreen.bounds.size.width, kQTSVHeight);
        self.gradientView.alpha = 0;
        [self.imageView.layer addSublayer:gradient];
        
        self.sloganLabel = [[UILabel alloc] initWithFrame:gradient.frame];
        self.sloganLabel.textColor = [UIColor whiteColor];
        self.sloganLabel.textAlignment = NSTextAlignmentCenter;
        self.sloganLabel.font = [UIFont fontWithName:@"Zapfino" size:30.];
        self.sloganLabel.text = @"crazy for music";
        self.sloganLabel.alpha = 0;
        [self addSubview:self.sloganLabel];
    }
    return self;
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    self.sloganLabel.transform = CGAffineTransformMakeTranslation(0, 20);
    [UIView animateWithDuration:1 animations:^{
        self.gradientView.alpha = 1;
        self.sloganLabel.alpha = 1;
        self.sloganLabel.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    CGAffineTransform transform = CGAffineTransformMakeScale(1.1, 1.1);
    transform = CGAffineTransformTranslate(transform, 0, -20);
    [UIView animateWithDuration:2 animations:^{
        self.imageView.transform = transform;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.2 animations:^{
            self.alpha = 0;
            self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 10, 1);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

@end
