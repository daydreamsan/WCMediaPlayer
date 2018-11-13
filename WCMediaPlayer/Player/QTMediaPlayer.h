//
//  QTMediaPlayer.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/5.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTPlayerInterface.h"

@interface QTMediaItem : NSObject<NSCopying>

@property (nonatomic, copy  ) NSString *name;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, assign) NSTimeInterval start; //开始位置
@property (nonatomic, copy  ) NSURL *outputFileURL; //输出文件的fileURL地址, 默认为nil, 表示不进行边播边下

@end

@class QTMediaPlayer;

typedef NS_ENUM(NSInteger, QTMediaPlayMode) {
    QTMediaPlayModeOrder        = 0,    //顺序播放
    QTMediaPlayModeSingleLoop   = 1,    //单曲循环
    QTMediaPlayModeListLoop     = 2,    //列表循环
    QTMediaPlayModeRandom       = 3,    //随机播放
};

/**
 播放器状态改变时执行该回调

 @param player 播放器
 @param oldState 旧状态
 @param freshState 新状态
 */
typedef void(^QTChangeStateCallback)(QTMediaPlayer *player, QTMediaPlayerState oldState, QTMediaPlayerState freshState);

/**
 播放失败时的回调

 @param player 播放器
 @param ecode 错误码
 @param edesc 错误描述
 */
typedef void(^QTFailedCallback)(QTMediaPlayer *player, NSInteger ecode, NSString *edesc);

/**
 进度回调

 @param player 播放器
 @param position 当前播放位置
 */
typedef void(^QTUpdateProgressCallback)(QTMediaPlayer *player, QTMediaPosition position);

/**
 列表播放时, 当播放索引有变化时进行回调

 @param player 播放器
 @param oldIndex 之前的播放器索引
 @param freshIndex 当前的播放器索引
 */
typedef void(^QTUpdateIndexCallback)(QTMediaPlayer *player, NSUInteger oldIndex, NSUInteger freshIndex);

/**
 从音频信息中获取元信息成功后的回调, 这些信息包括但不限于艺术家名称，歌曲名称，作曲，时长等信息

 @param player 播放器
 @param medaInfo 信息字典
 */
typedef void(^QTMetaDataAvailableCallback)(QTMediaPlayer *player, NSDictionary *medaInfo);

/**
 音频播放器
 
 支持PCM\MP3\AAC等格式
 支持状态机控制
 支持后台播放
 支持远程控制
 支持边播边下
 时间回调精度为1/60s
 自动处理AVSession
 */
@interface QTMediaPlayer : NSObject<QTPlayerInterface>

/**
 播放状态, 外部可通过KVO来跟踪该状态的变化
 */
@property (nonatomic, assign, readonly) QTMediaPlayerState state;

/**
 播放模式. 默认为顺序播放
 */
@property (nonatomic, assign) QTMediaPlayMode playMode;

/**
 当前播放QTMediaItem的索引
 */
@property (nonatomic, assign, readonly) NSUInteger currentIndex;

/**
 当前正在播放的QTMediaItem
 */
@property (nonatomic, strong, readonly) QTMediaItem *currentItem;

/**
 当前正在播放的QTMediaItem的播放位置
 */
@property (nonatomic, assign, readonly) QTMediaPosition currentPosition;

/**
 当前正在播放的QTMediaItem的时长信息
 */
@property (nonatomic, assign, readonly) QTMediaPosition duration;

/**
 两个曲目之间的时间间隔, 以秒为单位. 默认为0
 */
@property (nonatomic, assign) NSTimeInterval gap;

@property (nonatomic, copy  ) QTChangeStateCallback onChangeState;
@property (nonatomic, copy  ) QTUpdateProgressCallback onUpdateProgress;
@property (nonatomic, copy  ) QTUpdateIndexCallback onUpdateIndex;
@property (nonatomic, copy  ) QTFailedCallback onFailed;
@property (nonatomic, copy  ) QTMetaDataAvailableCallback onMetaDataAvailable;

/**
 该字段可能为Nil.
 */
@property (nonatomic, strong, readonly) NSDictionary *metaData;

//TODO: 1. 缓冲进度更新的回调

/**
 自动回调播放进度, 默认为NO
 */
@property (nonatomic, assign) BOOL autoUpdateProgress;

/**
 是否自动配置Session， 默认为NO
 */
@property (nonatomic, assign) BOOL autoHandleAudioSession;

/**
 是否自动跳过无效的MediaItem.
 YES - 进行错误回调, 并根据当前播放模式自动寻找下一个可用的item
 NO  - 进行错误回调. 播放过程中断
 默认为NO.
 */
@property (nonatomic, assign) BOOL autoSkipBadMediaItem;

/**
 播放列表, 外部不应直接修改该字段以及其中的元素
 */
@property (nonatomic, strong, readonly) NSArray<QTMediaItem *> *playlist;

- (instancetype)initWithPlayList:(NSArray<QTMediaItem *> *)playlist;

- (void)play;
- (void)playWithIndex:(NSInteger)idx;
- (void)pause;
- (void)stop;
- (void)playNextItem;
- (void)playPreviousItem;
- (void)seekToPosition:(QTMediaPosition)position;

/**
 当前是否在进行播放, NO-未播放， YES-正在播放
 此值使用真实的播放状态, 当播放状态为:QTMediaPlayerStatePlaying或QTMediaPlayerStateEndOfFile时
 表示在播放中, 否则，表示未进行播放.
 另外, 该方法不受`gap`属性的影响。例如:列表循环播放模式下gap=10时, 在上一曲播放结束后，会有10s的等待时间
 在这10s中的任何时候访问该方法，都会得到NO
 @return 状态值
 */
- (BOOL)isPlaying;

@end
