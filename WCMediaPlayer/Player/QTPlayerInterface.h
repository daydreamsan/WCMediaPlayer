//
//  QTPlayerInterface.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/7.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    unsigned minute;
    unsigned second;
    float playbackTimeInSeconds;
    float position;
} QTMediaPosition;

/**
 播放器状态
 */
typedef NS_ENUM(NSInteger, QTMediaPlayerState) {
    QTMediaPlayerStateRetrievingURL     = 0,    //该状态下会获取URL并做格式检测
    QTMediaPlayerStateStopped           = 1,    //停止状态
    QTMediaPlayerStateBuffering         = 2,    //缓冲态, 可以根据此状态进行UI loading的显示
    QTMediaPlayerStatePlaying           = 3,    //播放态
    QTMediaPlayerStatePaused            = 4,    //暂停态。当调用`- (void)pause；`后会进入此状态, 再次调用`- (void)pause;` 方法后才会退出该状态
    QTMediaPlayerStateSeeking           = 5,    //该状态表明正在寻找播放时间点
    QTMediaPlayerStateEndOfFile         = 6,    //该状态表明当前URL下的所有数据均已缓冲完毕
    QTMediaPlayerStateFailed            = 7,    //播放失败. eg. URL不合法, 或HTTP响应格式不合法, 或不支持的音频格式(比如:不支持wav).
    QTMediaPlayerStateRetryingStarted   = 8,    //重试开始
    QTMediaPlayerStateRetryingSucceeded = 9,    //重试成功
    QTMediaPlayerStateRetryingFailed    = 10,   //重试失败
    QTMediaPlayerStatePlaybackCompleted = 11,   //播放完成
    QTMediaPlayerStateUnknownState      = 12    //未知状态
};

@protocol QTPlayerInterface <NSObject>

@property (nonatomic, assign, readonly) QTMediaPlayerState state;
- (void)play;
- (void)pause;
- (void)stop;
- (void)playNextItem;
- (void)playPreviousItem;
- (void)seekToPosition:(QTMediaPosition)position;
- (BOOL)isPlaying;

@end
