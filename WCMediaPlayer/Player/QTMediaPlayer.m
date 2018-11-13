//
//  QTMediaPlayer.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/5.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTMediaPlayer.h"
#import <FreeStreamer/FSAudioController.h>
#import <AVKit/AVKit.h>

@implementation QTMediaItem

- (id)copyWithZone:(NSZone *)zone {
    QTMediaItem *one = self.class.new;
    one.name = self.name;
    one.URL = self.URL;
    one.start = self.start;
    one.outputFileURL = self.outputFileURL;
    return one;
}

- (NSString *)description {
    return [NSString stringWithFormat:@">QTMediaItem: %p\n%@\n%@\n%@", self.name, self.URL, @(self.start), self.outputFileURL];
}

@end

@interface QTMediaPlayer ()

@property (nonatomic, assign) QTMediaPlayerState state;
@property (nonatomic, strong) NSArray<QTMediaItem *> *playlist;
@property (nonatomic, strong) FSAudioController *privPlayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) QTMediaItem *currentItem;
@property (nonatomic, strong) NSDictionary *metaData;
@property (nonatomic, assign) UIBackgroundTaskIdentifier token;

@end

@implementation QTMediaPlayer

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    return [self initWithPlayList:nil];
}

- (instancetype)initWithURL:(NSURL *)URL {
    QTMediaItem *item = QTMediaItem.new;
    item.URL = URL;
    item.name = @"";
    return [self initWithPlayList:@[item]];
}

- (instancetype)initWithPlayList:(NSArray<QTMediaItem *> *)playlist {
    self = [super init];
    if (self) {
        self.playlist = playlist;
        [self setupPrivPlayer];
        [self setupObserver];
    }
    return self;
}

- (void)play {
    if (self.privPlayer.currentPlaylistItem) {
        if (!self.privPlayer.isPlaying) {
            [self configAudioSession];
            [self.privPlayer play];
        }
    } else {
        [self playWithIndex:0];
    }
}

- (void)playWithIndex:(NSInteger)idx {
    if (idx >= self.playlist.count) {
        return;
    }
    [self.privPlayer stop];
    self.metaData = nil;
    QTMediaItem *item = self.playlist[idx];
    self.privPlayer.url = item.URL;
    if (item.outputFileURL) {
        self.privPlayer.activeStream.outputFile = item.outputFileURL;
    }
    [self.privPlayer.activeStream setStrictContentTypeChecking:NO];
    self.privPlayer.activeStream.maxRetryCount = 0;
    NSInteger oldIndex = self.currentIndex;
    self.currentItem = item;
    self.currentIndex = idx;
    if (self.onUpdateIndex) {
        self.onUpdateIndex(self, oldIndex, self.currentIndex);
    }
    [self configAudioSession];
    [self.privPlayer play];
}
- (void)playWithIndexObj:(NSNumber *)idx {
    NSUInteger index = idx.integerValue;
    [self playWithIndex:index];
}

- (void)pause {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playNextItem) object:nil];
    [self.privPlayer pause];
}

- (void)stop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playNextItem) object:nil];
    [self.privPlayer stop];
    [self invalidTimer];
}

- (BOOL)hasNextItem {
    BOOL result = NO;
    switch (self.playMode) {
        case QTMediaPlayModeSingleLoop: case QTMediaPlayModeRandom: case QTMediaPlayModeListLoop:
            result = YES;
            break;
        case QTMediaPlayModeOrder: {
            if (self.currentIndex < self.playlist.count - 1 && self.currentIndex >= 0) {
                result = YES;
            }
        } break;
        default:
            break;
    }
    return result;
}

- (void)playNextItem {
    NSUInteger idx = self.currentIndex;
    switch (self.playMode) {
        case QTMediaPlayModeOrder: {
            idx += 1;
        } break;
        case QTMediaPlayModeSingleLoop: {
        } break;
        case QTMediaPlayModeListLoop: {
            idx += 1;
            if (idx >= self.playlist.count) {
                idx = 0;
            }
        } break;
        case QTMediaPlayModeRandom: {
            idx = (NSUInteger)arc4random_uniform((uint32_t)self.playlist.count);
        } break;
        default:
            break;
    }
    if (idx < self.playlist.count) {
        if (self.gap) {
            [self performSelector:@selector(playWithIndexObj:) withObject:@(idx) afterDelay:self.gap];
        } else {
            [self playWithIndex:idx];
        }
    }
}

- (void)playPreviousItem {
    NSUInteger idx = self.currentIndex;
    switch (self.playMode) {
        case QTMediaPlayModeOrder: {
            if (idx >= 1) {
                idx -= 1;
            }
        } break;
        case QTMediaPlayModeListLoop: {
            if (0 == idx) {
                idx = self.playlist.count;
            }
            idx -= 1;
        } break;
        case QTMediaPlayModeRandom: {
            idx = (NSUInteger)arc4random_uniform((uint32_t)self.playlist.count);
        } break;
        default:
            break;
    }
    if (idx >= 0) {
        [self playWithIndex:idx];
    }
}

- (void)seekToPosition:(QTMediaPosition)position {
    if (position.position == 1.0) {
        float second = self.privPlayer.activeStream.duration.playbackTimeInSeconds;
        position.position = 1-1.f/second;
    }
    FSStreamPosition p = {
        .minute = position.minute,
        .second = position.second,
        .playbackTimeInSeconds = position.playbackTimeInSeconds,
        .position = position.position
    };
    NSLog(@"position: %f", position.position);
    [self.privPlayer.activeStream seekToPosition:p];
}

- (BOOL)isPlaying {
    return self.privPlayer.isPlaying;
}

- (QTMediaPosition)currentPosition {
    FSStreamPosition p = self.privPlayer.activeStream.currentTimePlayed;
    return (QTMediaPosition){
        .minute = p.minute,
        .second = p.second,
        .playbackTimeInSeconds = p.playbackTimeInSeconds,
        .position = p.position
    };
}

- (QTMediaPosition)duration {
    FSStreamPosition p = self.privPlayer.activeStream.duration;
    return (QTMediaPosition){
        .minute = p.minute,
        .second = p.second,
        .playbackTimeInSeconds = p.playbackTimeInSeconds,
        .position = p.position
    };
}

#pragma mark - Private
- (void)setupPrivPlayer {
    self.privPlayer = FSAudioController.new;
    self.privPlayer.automaticAudioSessionHandlingEnabled = NO;
    __weak typeof(self) ws_ = self;
    self.privPlayer.onMetaDataAvailable = ^(NSDictionary *metadata) {
        __strong typeof(ws_) sf_ = ws_;
        sf_.metaData = metadata;
        if (sf_.onMetaDataAvailable) {
            sf_.onMetaDataAvailable(sf_, metadata);
        }
    };
    self.privPlayer.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
        __strong typeof(ws_) sf_ = ws_;
        if (sf_.onFailed) {
            sf_.onFailed(sf_, error, errorDescription);
        }
        if (sf_.autoSkipBadMediaItem) {
            [sf_ skip];
        }
    };
    self.privPlayer.onStateChange = ^(FSAudioStreamState state) {
        __strong typeof(ws_) sf_ = ws_;
        if (sf_.onChangeState) {
            sf_.onChangeState(sf_, (QTMediaPlayerState)sf_.state, (QTMediaPlayerState)state);
        }
        sf_.state = (QTMediaPlayerState)state;
        if (state == kFsAudioStreamPlaybackCompleted) {
            [sf_ skip];
        }
        if (sf_.autoUpdateProgress) {
            switch (state) {
                case kFsAudioStreamFailed:
                case kFsAudioStreamPaused:
                case kFsAudioStreamStopped:
                case kFsAudioStreamPlaybackCompleted:
                case kFsAudioStreamRetryingFailed:
                case kFsAudioStreamSeeking: {
                    [sf_ invalidTimer];
                } break;
                case kFsAudioStreamPlaying: {
                    [sf_ startTimer];
                } break;
                default:
                    break;
            }
        }
    };
}

- (void)invalidTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startTimer {
    if (!_timer) {
        [self.timer fire];
    }
}

- (NSTimer *)timer {
    if (_timer) {
        return _timer;
    }
    _timer = [NSTimer timerWithTimeInterval:1.f/10 target:self selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    return _timer;
}

- (void)skip {
    switch (self.playMode) {
        case QTMediaPlayModeOrder: {
            if ([self hasNextItem]) {
                [self playNextItem];
            }
        } break;
        case QTMediaPlayModeSingleLoop: case QTMediaPlayModeListLoop: case QTMediaPlayModeRandom: {
            [self playNextItem];
        } break;
        default:
            break;
    }
}

- (void)setupObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Action
- (void)timerDidFire:(NSTimer *)sender {
    FSStreamPosition position = self.privPlayer.activeStream.currentTimePlayed;
    QTMediaPosition p = {
        .minute = position.minute,
        .second = position.second,
        .playbackTimeInSeconds = position.playbackTimeInSeconds,
        .position = position.position
    };
    if (self.onUpdateProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.onUpdateProgress(self, p);
        });
    }
}

#pragma mark - Noti
- (void)didReceiveEnterBackgroundNotification:(NSNotification *)noti {
    self.token = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"qt_audio_background_task" expirationHandler:^{
        if (self.token != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.token];
            self.token = UIBackgroundTaskInvalid;
        }
    }];
}
- (void)didReceiveBecomeActiveNotification:(NSNotification *)noti {
    if (self.token != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.token];
        self.token = UIBackgroundTaskInvalid;
    }
}

- (void)configAudioSession {
    if (self.autoHandleAudioSession) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        BOOL success = [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        if (!error && success) {
            success = [session setCategory:AVAudioSessionCategoryPlayback error:&error];
            if (!error && success) {
                
            } else {
                NSAssert(NO, @"音频服务类别设置失败");
            }
        } else {
            NSAssert(NO, @"音频服务激活失败");
        }
    }
}

@end
