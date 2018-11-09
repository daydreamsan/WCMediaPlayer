//
//  QTCarveLabel.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/8.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTCarveLabel.h"

@implementation QTCarveLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.font = self.font;
    label.text = self.text;
    label.textAlignment = self.textAlignment;
    label.backgroundColor = self.backgroundColor;
    [label.layer drawInContext:ctx];
    CGContextRestoreGState(ctx);
}

@end
