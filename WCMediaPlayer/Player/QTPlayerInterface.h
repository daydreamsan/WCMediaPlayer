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

@protocol QTPlayerInterface <NSObject>

- (void)play;
- (void)pause;
- (void)stop;
- (void)playNextItem;
- (void)playPreviousItem;
- (void)seekToPosition:(QTMediaPosition)position;
- (BOOL)isPlaying;

@end
