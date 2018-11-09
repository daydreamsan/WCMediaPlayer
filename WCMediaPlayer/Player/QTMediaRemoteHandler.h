//
//  QTMediaRemoteHandler.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/7.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTPlayerInterface.h"
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, QTHandleOptions) {
    QTHandlePlay            = 1L<<0,     //开始播放
    QTHandlePause           = 1L<<1,     //暂停
    QTHandleTogglePlayPause = 1L<<2,     //播放与暂停翻转
    QTHandleNext            = 1L<<3,     //下一曲
    QTHandlePreviouse       = 1L<<4,     //上一曲
    QTHandleAll             =   QTHandlePlay            |
                                QTHandlePause           |
                                QTHandleTogglePlayPause |
                                QTHandleNext            |
                                QTHandlePreviouse
};

@interface QTMediaNowInfo : NSObject

@property (nonatomic, strong) UIImage *artwork;     //插图
@property (nonatomic, assign) NSInteger elapse;     //已过去多久
@property (nonatomic, assign) NSInteger duration;   //总时长
@property (nonatomic, copy  ) NSString *title;      //名称
@property (nonatomic, copy  ) NSString *artist;     //艺术家

@end

@interface QTMediaRemoteHandler : NSObject

@property (nonatomic, assign, readonly) QTHandleOptions options;
@property (nonatomic, strong, readonly) id<QTPlayerInterface> player;

- (instancetype)initWithOptions:(QTHandleOptions)ops player:(id<QTPlayerInterface>)player;
- (void)updateNowInfo:(QTMediaNowInfo *)info;
- (void)reset;

@end
