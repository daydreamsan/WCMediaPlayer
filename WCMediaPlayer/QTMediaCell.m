//
//  QTMediaCell.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/6.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTMediaCell.h"

@implementation QTMediaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgButton.imageView.animationImages = @[
                                                 [UIImage imageNamed:@"line01"],
                                                 [UIImage imageNamed:@"line02"],
                                                 [UIImage imageNamed:@"line03"],
                                                 [UIImage imageNamed:@"line04"],
                                                 ];
    self.imgButton.adjustsImageWhenHighlighted = NO;
    self.imgButton.imageView.animationDuration = 0.8;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {}

@end
