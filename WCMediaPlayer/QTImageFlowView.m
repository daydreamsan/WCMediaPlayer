//
//  QTImageFlowView.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/9.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTImageFlowView.h"
#import <YYKit/YYKit.h>

#define kQTIFOffset         (20.f)
#define kQTIFScreenWidth    (UIScreen.mainScreen.bounds.size.width)
#define kQTIFScreenHeight   (UIScreen.mainScreen.bounds.size.height)
#define kQTIFItemMargin     (1.5f)
#define kQTIFItemWidth      ((kQTIFScreenWidth-kQTIFItemMargin*2)/3.f)
#define kQTIFItemHeight     kQTIFItemWidth
#define kQTIFHeight         kQTIFScreenHeight//((kQTIFItemHeight*4)+kQTIFOffset)

@implementation QTImageCellItem @end

@interface QTImageFlowViewCell ()

@property (nonatomic, strong) NSArray<NSNumber *> *types;
@property (nonatomic, assign) NSInteger currentMode;
@property (nonatomic, assign) NSInteger duration;

@end

@implementation QTImageFlowViewCell
{
    CADisplayLink *_timer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.clipsToBounds = YES;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.imageView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
}

- (void)layout {
    self.imageView.frame = CGRectMake(-50, -50, self.contentView.bounds.size.width + 100, self.contentView.bounds.size.height + 100);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

#pragma mark - Action
- (void)dismiss {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.imageView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)startAnimate {
    NSMutableSet *tmp = [NSMutableSet set];
    do {
        uint32_t r = arc4random_uniform(10000);
        [tmp addObject:@(r)];
    } while (tmp.count < 100);
    
    self.types = tmp.allObjects;
    self.currentMode = self.types.firstObject.integerValue;
    if (!self->_timer) {
        self->_timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerDidFire:)];
        [self->_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self->_timer.frameInterval = 2;
    }
}

- (void)reset {
    [self->_timer invalidate];
    self->_timer = nil;
    self.imageView.transform = CGAffineTransformMakeScale(1.05, 1.05);
}

#pragma mark - Action
- (void)timerDidFire:(NSTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (self.currentMode%4) {
            case 0: {   //scale to 1.2
                if (CGAffineTransformGetScaleX(self.imageView.transform) >= 1.4) {
                    NSInteger idx = [self.types indexOfObject:@(self.currentMode)];
                    idx += 1;
                    idx %= 4;
                    self.currentMode = self.types[idx].integerValue;
                } else {
                    CGAffineTransform transform = self.imageView.transform;
                    transform = CGAffineTransformScale(transform, 1.001, 1.001);
                    self.imageView.transform = transform;
                }
            } break;
            case 1: {   //move to left-top(-50,-50)
                if (CGAffineTransformGetTranslateX(self.imageView.transform) <= -20) {
                    NSInteger idx = [self.types indexOfObject:@(self.currentMode)];
                    idx += 1;
                    idx %= 4;
                    self.currentMode = self.types[idx].integerValue;
                } else {
                    CGAffineTransform transform = self.imageView.transform;
                    transform = CGAffineTransformTranslate(transform, -0.08, -0.08);
                    self.imageView.transform = transform;
                }
            } break;
            case 2: {   //move to right-bottom(+50,+50)
                if (CGAffineTransformGetTranslateX(self.imageView.transform) >= 20) {
                    NSInteger idx = [self.types indexOfObject:@(self.currentMode)];
                    idx += 1;
                    idx %= 4;
                    self.currentMode = self.types[idx].integerValue;
                } else {
                    CGAffineTransform transform = self.imageView.transform;
                    transform = CGAffineTransformTranslate(transform, 0.08, 0.08);
                    self.imageView.transform = transform;
                }
            } break;
            case 3: {   //scale to 0.8
                CGFloat xscale = CGAffineTransformGetScaleX(self.imageView.transform);
                if (xscale <= 1.0) {
                    NSInteger idx = [self.types indexOfObject:@(self.currentMode)];
                    idx += 1;
                    idx %= 4;
                    self.currentMode = self.types[idx].integerValue;
                } else {
                    CGAffineTransform transform = self.imageView.transform;
                    transform = CGAffineTransformScale(transform, 0.999, 0.999);
                    self.imageView.transform = transform;
                }
            } break;
        }
    });
}

@end

@interface QTImageFlowView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) NSMutableSet *set;

@end

@implementation QTImageFlowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.set = [NSMutableSet set];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:nil];
    [self addSubview:self.effectView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tap];
    UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
    layout.minimumLineSpacing = kQTIFItemMargin;
    layout.minimumInteritemSpacing = kQTIFItemMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(kQTIFItemWidth, kQTIFItemHeight);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kQTIFScreenWidth, kQTIFHeight) collectionViewLayout:layout];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:QTImageFlowViewCell.class forCellWithReuseIdentifier:NSStringFromClass(QTImageFlowViewCell.class)];
    [self.effectView.contentView addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.layouts.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QTImageFlowViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(QTImageFlowViewCell.class) forIndexPath:indexPath];
    QTImageCellItem *item = self.layouts[indexPath.item];
    [cell.imageView setImage:item.image forState:UIControlStateNormal];
    cell.imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell reset];
    [cell startAnimate];
    [cell.imageView addTarget:self action:@selector(didClickImage:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.set containsObject:@(indexPath.item)] ) {
        [self.set addObject:@(indexPath.item)];
        cell.transform = CGAffineTransformMakeTranslation(0, 60);
        [UIView animateWithDuration:0.8 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)didClickImage:(UIButton *)sender {
    QTImageFlowViewCell *cell =(QTImageFlowViewCell *) sender.superview.superview;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    QTImageCellItem *item = self.layouts[indexPath.item];
    if (self.didTapImageCallback) {
        self.didTapImageCallback(indexPath, cell, item);
    }
}

- (void)setLayouts:(NSArray<QTImageCellItem *> *)layouts {
    _layouts = layouts;
    [self.collectionView reloadData];
}

- (void)showInView:(UIView *)sview {
    self.frame = CGRectMake(0, 0, sview.bounds.size.width, sview.bounds.size.height);
    self.effectView.effect = nil;
    self.effectView.frame = CGRectMake(0, 0, kQTIFScreenWidth, kQTIFHeight);
    self.collectionView.frame = CGRectMake(0, -kQTIFHeight, kQTIFScreenWidth, kQTIFHeight-kQTIFOffset);
    [sview addSubview:self];
    [self.collectionView reloadData];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.effectView.effect = effect;
        self.collectionView.frame = CGRectMake(0, kQTIFOffset, kQTIFScreenWidth, kQTIFHeight-kQTIFOffset);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)dismissWithDirection:(BOOL)isTop {
    NSArray<QTImageFlowViewCell *> *cells = self.collectionView.visibleCells;
    [cells enumerateObjectsUsingBlock:^(QTImageFlowViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj dismiss];
    }];
    [UIView animateWithDuration:1 delay:0.6 usingSpringWithDamping:1.f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.effectView.effect = nil;
        if (isTop) {
            self.collectionView.frame = CGRectMake(0, -kQTIFHeight, kQTIFScreenWidth, kQTIFHeight);
        } else {
            self.collectionView.top = kScreenHeight;
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.effectView.frame = CGRectMake(0, 0, kQTIFScreenWidth, kQTIFHeight);
    self.collectionView.frame = CGRectMake(0, kQTIFOffset, kQTIFScreenWidth, kQTIFHeight-kQTIFOffset);
}

#pragma mark - Action
- (void)didTap:(UITapGestureRecognizer *)tap {
    [self dismissWithDirection:1];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -100) {
        if (!scrollView.tracking) {
            [self dismissWithDirection:0];
        }
    }
}

@end
