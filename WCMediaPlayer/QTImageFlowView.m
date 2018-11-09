//
//  QTImageFlowView.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/9.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTImageFlowView.h"

#define kQTIFOffset         (20.f)
#define kQTIFScreenWidth    (UIScreen.mainScreen.bounds.size.width)
#define kQTIFScreenHeight   (UIScreen.mainScreen.bounds.size.height)
#define kQTIFItemMargin     1.f
#define kQTIFItemWidth      ((kQTIFScreenWidth-kQTIFItemMargin*2)/3.f)
#define kQTIFItemHeight     kQTIFItemWidth
#define kQTIFHeight         kQTIFScreenHeight//((kQTIFItemHeight*4)+kQTIFOffset)

@implementation QTImageCellItem @end

@implementation QTImageFlowViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.imageView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    [self.imageView addTarget:self action:@selector(didClickImage:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layout {
    self.imageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

#pragma mark - Action
- (void)didClickImage:(UIButton *)sender {
    NSLog(@"xx");
}

- (void)dismiss {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.imageView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

@end

@interface QTImageFlowView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIVisualEffectView *effectView;

@end

@implementation QTImageFlowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"click me");
    QTImageCellItem *item = self.layouts[indexPath.item];
    QTImageFlowViewCell *cell = (QTImageFlowViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
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
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.effectView.effect = effect;
        self.collectionView.frame = CGRectMake(0, kQTIFOffset, kQTIFScreenWidth, kQTIFHeight-kQTIFOffset);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)dismiss {
    NSArray<QTImageFlowViewCell *> *cells = self.collectionView.visibleCells;
    [cells enumerateObjectsUsingBlock:^(QTImageFlowViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj dismiss];
    }];
    [UIView animateWithDuration:1 delay:0.6 usingSpringWithDamping:1.f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.effectView.effect = nil;
        self.collectionView.frame = CGRectMake(0, -kQTIFHeight, kQTIFScreenWidth, kQTIFHeight);
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
    [self dismiss];
}

@end
