//
//  QTScrollLabel.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/9.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTScrollLabel.h"

static NSInteger kPrivateTag = 1000;

#define kQTSLDefaultFont(x) [UIFont fontWithName:@"HelveticaNeue-Thin" size:(x)]
#define kQTSLInterval   50.f

@interface QTScrollLabel ()

@property (nonatomic, strong) UILabel *headLabel;
@property (nonatomic, strong) UILabel *tailLabel;
@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation QTScrollLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    self.textColor = UIColor.whiteColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

- (UIFont *)font {
    if (_font) {
        return _font;
    }
    _font = kQTSLDefaultFont(23);
    return _font;
}

- (void)setText:(NSString *)text {
    _text = text.copy;
    self.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self configLabels];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    UILabel *head = (UILabel *)[self viewWithTag:kPrivateTag];
    UILabel *tail = (UILabel *)[self viewWithTag:kPrivateTag + 1];
    head.textColor = textColor;
    tail.textColor = textColor;
}

- (void)startScroll {
    CGSize textSize = [self textSize];
    if (textSize.width > self.bounds.size.width) {
        if (!self.link) {
            self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(didFire:)];
            [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            self.link.frameInterval = 2;
        }
    } else {
        [self endScroll];
    }
}

- (void)endScroll {
    if (self.link) {
        [self.link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.link invalidate];
        self.link = nil;
    }
}

- (void)configLabels {
    CGSize textSize = [self textSize];
    UILabel *head = (UILabel *)[self viewWithTag:kPrivateTag];
    UILabel *tail = (UILabel *)[self viewWithTag:kPrivateTag + 1];
    if (!head) {
        head = [self labelWithTag:kPrivateTag];
        [self addSubview:head];
    } else {
        head.text = self.text;
        [head sizeToFit];
    }
    if (textSize.width > self.bounds.size.width) {
        if (!tail) {
            tail = [self labelWithTag:kPrivateTag + 1];
            [self addSubview:tail];
        } else {
            tail.text = self.text;
        }
    } else {
        tail.text = nil;
    }
    if (textSize.width > self.bounds.size.width) {
        head.frame = CGRectMake(0, 0, head.frame.size.width, self.bounds.size.height);
        tail.frame = CGRectMake(head.frame.size.width + kQTSLInterval, 0, tail.frame.size.width, self.bounds.size.height);
    } else {
        head.center = CGPointMake(self.bounds.size.width/2.f, self.bounds.size.height/2.f);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Action
- (void)didFire:(CADisplayLink *)sender {
    UILabel *head = (UILabel *)[self viewWithTag:kPrivateTag];
    __block CGFloat x = self.bounds.origin.x;
    CGFloat y = self.bounds.origin.y;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (x > kQTSLInterval + head.frame.size.width) {
            x = 0;
        }
        self.bounds = CGRectMake(x + 1, y, w, h);
    });
}

- (UILabel *)labelWithTag:(NSInteger)tag {
    UILabel * tail = UILabel.new;
    tail.text = self.text;
    tail.font = self.font?:kQTSLDefaultFont(23);
    tail.textAlignment = NSTextAlignmentCenter;
    tail.tag = tag;
    tail.textColor = self.textColor;
    tail.shadowOffset = CGSizeMake(1, 1);
    tail.shadowColor = UIColor.lightGrayColor;
    [tail sizeToFit];
    return tail;
}

- (CGSize)textSize {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(1, 1);
    shadow.shadowColor = UIColor.lightGrayColor;
    CGSize size = [self.text boundingRectWithSize:CGSizeMake(HUGE, self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font, NSShadowAttributeName:shadow} context:nil].size;
    return size;
}

@end
