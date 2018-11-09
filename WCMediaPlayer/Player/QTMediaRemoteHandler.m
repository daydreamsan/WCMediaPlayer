//
//  QTMediaRemoteHandler.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/7.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTMediaRemoteHandler.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation QTMediaNowInfo @end

@implementation QTMediaRemoteHandler

- (void)dealloc {
    [self reset];
}

- (instancetype)initWithOptions:(QTHandleOptions)ops player:(id<QTPlayerInterface>)player {
    if (self = [super init]) {
        _options = ops;
        _player = player;
        [self configRemoteControl];
    }
    return self;
}

- (void)updateNowInfo:(QTMediaNowInfo *)info {
    NSMutableDictionary *nowInfo = @{}.mutableCopy;
    if (info.title) {
        [nowInfo setValue:info.title forKey: MPMediaItemPropertyTitle];
    }
    UIImage *image = info.artwork;
    if (image) {
        MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        [nowInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
    }
    [nowInfo setObject:@(info.elapse) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [nowInfo setObject:@(info.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    if (info.artist) {
        [nowInfo setObject:info.artist forKey:MPMediaItemPropertyArtist];
    }
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowInfo];
}

- (void)reset {
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
    [center.playCommand setEnabled:NO];
    [center.playCommand removeTarget:self];
    [center.stopCommand setEnabled:YES];
    [center.stopCommand removeTarget:self];
    [center.nextTrackCommand setEnabled:NO];
    [center.nextTrackCommand removeTarget:self];
    [center.previousTrackCommand setEnabled:NO];
    [center.previousTrackCommand removeTarget:self];
    [center.changePlaybackRateCommand setEnabled:NO];
    [center.changePlaybackRateCommand removeTarget:self];
    if (@available(iOS 9.1, *)) {
        [center.changePlaybackPositionCommand setEnabled:NO];
    }
    if (@available(iOS 9.1, *)) {
        [center.changePlaybackPositionCommand removeTarget:self];
    }
}

#pragma mark - Private
- (void)configRemoteControl {
    [self reset];
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
    __weak typeof(self) ws_ = self;
    if (self.options & QTHandlePlay) {
        [center.playCommand setEnabled:YES];
        [center.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            __strong typeof(ws_) sf_ = ws_;
            [sf_.player pause];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
    if (self.options & QTHandlePause) {
        [center.pauseCommand setEnabled:YES];
        [center.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            __strong typeof(ws_) sf_ = ws_;
            [sf_.player pause];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
    if (self.options & QTHandleTogglePlayPause) {
        [center.togglePlayPauseCommand setEnabled:YES];
        [center.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            __strong typeof(ws_) sf_ = ws_;
            [sf_.player pause];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
    if (self.options & QTHandleNext) {
        [center.nextTrackCommand setEnabled:YES];
        [center.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            __strong typeof(ws_) sf_ = ws_;
            [sf_.player playNextItem];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
    if (self.options & QTHandlePreviouse) {
        [center.previousTrackCommand setEnabled:YES];
        [center.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            __strong typeof(ws_) sf_ = ws_;
            [sf_.player playPreviousItem];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
}

@end
