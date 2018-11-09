//
//  QTScrollLabel.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/9.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QTScrollLabel : UIView

@property (nonatomic, copy  ) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

- (void)startScroll;
- (void)endScroll;

@end

NS_ASSUME_NONNULL_END
