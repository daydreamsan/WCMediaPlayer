//
//  QTShadowView.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/7.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTShadowView.h"

@implementation QTShadowView

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    return self;
}

@end
