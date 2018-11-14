//
//  ViewController.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/5.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "ViewController.h"
#import "QTSlider.h"
#import "QTMediaPlayer.h"
#import <AVKit/AVKit.h>
#import "QTTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "QTMediaRemoteHandler.h"
#import "QTShadowView.h"
#import "QTMediaListView.h"
#import "QTSplashView.h"
#import "QTScrollLabel.h"
#import "QTImageFlowView.h"
#import <YYKit/YYKit.h>
#import "WCPhotoGroupView.h"
#import <WechatAuthSDK.h>
#import <WXApi.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@property (nonatomic, strong) QTMediaPlayer *stream;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet QTScrollLabel *songNameView;
@property (weak, nonatomic) IBOutlet QTSlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIImageView *songImageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) NSArray<QTMediaItem *> *songs;
@property (nonatomic, strong) NSArray<NSString *> *backgroundImages;
@property (weak, nonatomic) IBOutlet UIButton *playmodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (nonatomic, assign) QTMediaPlayMode playMode;
@property (nonatomic, strong) QTMediaRemoteHandler *handler;
@property (nonatomic, assign) float arc;

@end

@implementation ViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self prepareSongs];
    [self prepareStream];
    [self configRemoteControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.songImageView.layer.cornerRadius == 0) {
        self.indicator.center = CGPointMake(self.playButton.frame.size.width/2.f, self.playButton.frame.size.height/2.f);
        self.songImageView.layer.cornerRadius = self.songImageView.frame.size.width/2.f;
        self.songImageView.layer.masksToBounds = YES;
        self.songImageView.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor;
        self.songImageView.layer.borderWidth = 4.f;
    }
}

- (void)setupUI {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    QTSplashView *splash = QTSplashView.new;
    [splash show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [splash dismiss];
    });
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.playButton addSubview:self.indicator];
    self.indicator.hidden = YES;
    [self.playmodeBtn addTarget:self action:@selector(didTapPlayMode:) forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) ws = self;
    self.progressSlider.onEndTracing = ^(QTSlider *slider) {
        __strong typeof(ws) sf = ws;
        if (!slider.isTracking) {
            float rate = slider.value;
            QTMediaPosition position = {
                .position = rate
            };
            [sf.stream seekToPosition:position];
        }
    };
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.shadowView.layer;
    CGColorRef c1 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.].CGColor;
    CGColorRef c2 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    gradientLayer.colors = @[(__bridge id)c1, (__bridge id)c2];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);
    
    self.songImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.songImageView addGestureRecognizer:tap];
}

#pragma mark - Action
- (void)didFire:(CADisplayLink *)sender {}
- (void)didTap:(UITapGestureRecognizer *)tap {
    QTImageFlowView *flow = [[QTImageFlowView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    flow.layouts = [self imageCellItems];
    [flow showInView:self.view];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    @weakify(self)
    flow.didTapImageCallback = ^(NSIndexPath *idxpath, QTImageFlowViewCell *cell, QTImageCellItem *item) {
        @strongify(self)
        NSMutableArray *tmp = @[].mutableCopy;
        WCPhotoGroupItem *one = [WCPhotoGroupItem new];
        one.image = item.image;
        one.thumbView = cell;
        one.largeImageSize = item.image.size;
        [tmp addObject:one];
        WCPhotoGroupView *groupView = [[WCPhotoGroupView alloc] initWithGroupItems:tmp];
        [groupView presentFromImageView:cell toContainer:self.view animated:YES completion:^{

        }];
    };
}

- (void)didTapPlayMode:(UIButton *)btn {
    self.playMode += 1;
    self.playMode %= 4;
    NSString *imgname = @[@"顺序播放", @"单曲循环", @"列表循环", @"随机"][self.playMode];
    [btn setImage:[UIImage imageNamed:imgname] forState:UIControlStateNormal];
    self.stream.playMode = self.playMode;
}

- (IBAction)didTapPlay:(UIButton *)sender {
    if (self.stream.isPlaying) {
        [self.stream pause];
        [self configPlayButtonWithState:0];
    } else {
        if (self.stream.currentPosition.position) {
            [self.stream pause];
        } else {
            [self playWithIndex:0];
        }
        [self configPlayButtonWithState:1];
    }
}

- (void)playWithIndex:(NSInteger)idx {
    [self.stream play];
}
- (IBAction)didTapListButton:(UIButton *)sender {
    CGSize size = UIScreen.mainScreen.bounds.size;
    QTMediaListView *listView = [[QTMediaListView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    listView.layouts = self.songs;
    listView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:listView];
}

- (IBAction)didTapPrevious:(UIButton *)sender {
    [self.stream playPreviousItem];
}

- (IBAction)didTapNext:(UIButton *)sender {
    [self.stream playNextItem];
}

- (IBAction)didChageSliderValue:(UISlider *)sender {}

- (NSURL *)destinationWithFilename:(NSString *)name {
    NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *soundPath = [doc stringByAppendingPathComponent:@"sound"];
    BOOL isDir = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:soundPath isDirectory:&isDir];
    if (exist && !isDir) {
        [[NSFileManager defaultManager] removeItemAtPath:soundPath error:nil];
    } else if (!exist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:soundPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    soundPath = [soundPath stringByAppendingPathComponent:name];
    NSURL *url = [NSURL fileURLWithPath:soundPath];
    return url;
}

- (void)configPlayButtonWithState:(BOOL)isplaying {
    if (isplaying) {
        [self.playButton setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    }
}

- (void)setArc:(float)arc {
    _arc = arc;
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveLinear animations:^{
        self.songImageView.transform = CGAffineTransformMakeRotation(arc);
        self.backgroundImageView.transform = self.songImageView.transform;
    } completion:nil];
}

#pragma mark - Private
- (void)prepareSongs {
    NSMutableArray *songsM = @[].mutableCopy;
    NSMutableArray *bgs = @[].mutableCopy;
    for (NSInteger i = 0; i < 21; i++) {
        NSString *bg = [NSString stringWithFormat:@"背景%ld.jpg", i%10];
        NSString *name = [NSString stringWithFormat:@"%02ld.mp3", (long)i];
        name = [NSString stringWithFormat:@"%02ld.mp3", (long)i];
        name = [@"http://192.168.1.155:8888/Resource/" stringByAppendingString:name];
        [bgs addObject:bg];
        
        QTMediaItem *item = QTMediaItem.new;
        item.name = @(i).stringValue;
        item.URL = [NSURL URLWithString:name];
        item.start = 0;
        [songsM addObject:item];
    }
    self.songs = songsM;
    self.backgroundImages = bgs;
}

- (void)prepareStream {
    self.stream = [[QTMediaPlayer alloc] initWithPlayList:self.songs];
    self.stream.autoUpdateProgress = YES;
    self.stream.autoHandleAudioSession = YES;
    self.stream.autoSkipBadMediaItem = YES;
    __weak typeof(self) self_ = self;
    self.stream.onChangeState = ^(QTMediaPlayer *player, QTMediaPlayerState oldState, QTMediaPlayerState freshState) {
        __strong typeof(self_) strongself = self_;
        NSLog(@"onStateChange: %@ ---  %@", @(oldState), @(freshState));
        switch (freshState) {
            case QTMediaPlayerStateBuffering: {
                strongself.indicator.hidden = NO;
                [strongself.indicator startAnimating];
            } break;
            case QTMediaPlayerStateFailed: {
                strongself.indicator.hidden = YES;
                [strongself.indicator stopAnimating];
                [strongself configPlayButtonWithState:0];
            } break;
            case QTMediaPlayerStatePaused: {
                strongself.indicator.hidden = YES;
                [strongself.indicator stopAnimating];
                [strongself configPlayButtonWithState:0];
            } break;
            case QTMediaPlayerStatePlaying: {
                strongself.indicator.hidden = YES;
                [strongself.indicator stopAnimating];
                [strongself configPlayButtonWithState:1];
            } break;
            case QTMediaPlayerStateRetryingStarted: {
                strongself.indicator.hidden = NO;
                [strongself.indicator startAnimating];
            } break;
            case QTMediaPlayerStateRetryingFailed: {
                [strongself.indicator stopAnimating];
                strongself.indicator.hidden = YES;
            } break;
            case QTMediaPlayerStateStopped: {
                strongself.indicator.hidden = YES;
                [strongself.indicator stopAnimating];
                [strongself configPlayButtonWithState:0];
            } break;
            case QTMediaPlayerStateEndOfFile: {
                NSLog(@"文件缓冲结束");
            } break;
            case QTMediaPlayerStatePlaybackCompleted: {
                NSLog(@"playback completed: %@", @(freshState));
            } break;
            default:
                NSLog(@"其它状态： %@", @(freshState));
                break;
        }
    };
    self.stream.onFailed = ^(QTMediaPlayer *player, NSInteger ecode, NSString *edesc) {
        NSLog(@"我播放失败了: %@ - %@ - %@", @(ecode), edesc, player.currentItem);
    };
    self.stream.onUpdateProgress = ^(QTMediaPlayer *player, QTMediaPosition position) {
        __strong typeof(self_) strongself = self_;
        if (!strongself.progressSlider.isTracking) {
            [strongself.progressSlider setValue:position.position animated:YES];
        }
        strongself.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", player.duration.minute, player.duration.second];
        strongself.elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", player.currentPosition.minute, player.currentPosition.second];
        [strongself configNowInfo];
        strongself.arc += 0.01f;
    };
    self.stream.onUpdateIndex = ^(QTMediaPlayer *player, NSUInteger oldIndex, NSUInteger freshIndex) {
        __strong typeof(self_) strongself = self_;
        [strongself configNowInfo];
        [strongself configSongImage];
        strongself.arc = 0;
        strongself.songNameView.text = @"";
        [strongself.songNameView endScroll];
    };
    self.stream.onMetaDataAvailable = ^(QTMediaPlayer *player, NSDictionary *medaInfo) {
        __strong typeof(self_) strongself = self_;
        [strongself configNowInfo];
        [strongself configSongImage];
        [strongself configSongName];
    };
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QTTableViewController *vc = (QTTableViewController *)segue.destinationViewController;
    vc.layouts = self.songs;
}

- (void)configRemoteControl {
    self.handler = [[QTMediaRemoteHandler alloc] initWithOptions:QTHandleAll player:self.stream];
    [self configNowInfo];
}

- (void)configNowInfo {
    NSString *imgname = self.backgroundImages[self.stream.currentIndex % self.backgroundImages.count];
    imgname = [imgname stringByReplacingOccurrencesOfString:@"." withString:@"-small."];
    UIImage *img = [UIImage imageNamed:imgname];
    QTMediaNowInfo *info = QTMediaNowInfo.new;
    info.duration = self.stream.duration.playbackTimeInSeconds;
    info.elapse = self.stream.currentPosition.playbackTimeInSeconds;
    info.artwork = img;
    NSString *name = self.songs[self.stream.currentIndex].name;
    NSString *songname = self.stream.metaData[@"MPMediaItemPropertyTitle"];
    NSString *artist = self.stream.metaData[@"MPMediaItemPropertyArtist"];
    info.title = songname?:name;
    info.artist = artist?:@"未知";
    [self.handler updateNowInfo:info];
}

- (void)configSongImage {
    NSString *imgname = self.backgroundImages[self.stream.currentIndex % self.backgroundImages.count];
    imgname = [imgname stringByReplacingOccurrencesOfString:@"." withString:@"-small."];
    UIImage *img = [UIImage imageNamed:imgname];
    [UIView transitionWithView:self.songImageView duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.songImageView.image = img;
    } completion:^(BOOL finished) {
        
    }];
    [UIView transitionWithView:self.backgroundImageView duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.backgroundImageView.image = img;
    } completion:nil];
}

- (void)configSongName {
    NSString *songname = self.stream.metaData[@"MPMediaItemPropertyTitle"];
    NSString *artist = self.stream.metaData[@"MPMediaItemPropertyArtist"];
    self.stream.currentItem.name = songname;
    self.songNameView.text = [NSString stringWithFormat:@"%@--%@", songname.length?songname:@"", artist.length?artist:@""];
    [self.songNameView startScroll];
}

- (NSArray<QTImageCellItem *> *)imageCellItems {
    NSMutableArray *tmp = @[].mutableCopy;
    for (NSInteger i = 0; i < 20; i++) {
        NSString *name = [NSString stringWithFormat:@"背景%@-small.jpg", @(i)];
        QTImageCellItem *item = QTImageCellItem.new;
        item.image = [UIImage imageNamed:name];
        [tmp addObject:item];
        NSLog(@"iname: %@", name);
    }
    return tmp;
}

- (void)gotoShare {
    if (![WXApi registerApp:@"wx75115e72c42fcd99"]) {
        NSLog(@"share error");
        return;
    }
    WXMediaMessage *msg = [WXMediaMessage message];
    msg.title = @"title";
    
    WXImageObject *imgObj = [WXImageObject object];
    imgObj.imageData = [UIImage imageNamed:@"背景12-small.jpg"].imageDataRepresentation;
    msg.mediaObject = imgObj;
    [msg setThumbImage:[UIImage imageNamed:@"上一首"]];
    SendMessageToWXReq *req = [SendMessageToWXReq new];
    req.bText = NO;
    req.message = msg;
    req.text = @"this is share";
    req.scene = 0;
    [WXApi sendReq:req];
}

@end
