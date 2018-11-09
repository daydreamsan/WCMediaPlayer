//
//  QTAutoScrollLabel.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/7.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTAutoScrollLabel.h"

@interface QTAutoScrollLabel()

@property (nonatomic, strong) UIScrollView *scroll;

@end

@implementation QTAutoScrollLabel

- (void)sizeToFit {
    [super sizeToFit];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [super sizeThatFits:size];
    return s;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
}

@end
