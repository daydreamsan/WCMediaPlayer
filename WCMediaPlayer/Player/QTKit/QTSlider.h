//
//  QTSlider.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/6.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QTSlider : UISlider

@property (nonatomic, copy  ) void (^onEndTracing)(QTSlider *slider);

@end
