//
//  QTAutoScrollLabel.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/7.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QTAutoScrollLabel : UIView

@property (nonatomic, copy  ) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;

@end

NS_ASSUME_NONNULL_END
