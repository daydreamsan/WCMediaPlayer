//
//  QTMediaListView.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/7.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTMediaListView.h"

#define kQTMLTopMargin  20.f
#define kDeviceWidth    (UIScreen.mainScreen.bounds.size.width)
#define kDeviceHeight   (UIScreen.mainScreen.bounds.size.height)
#define kRandom(x)      (arc4random_uniform((x)))

@implementation QTMediaListViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1.f/UIScreen.mainScreen.scale)];
        line.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.2];
        line.tag = 1000;
        [self.contentView addSubview:line];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIView *line = [self.contentView viewWithTag:1000];
    line.frame = CGRectMake(20, self.contentView.frame.size.height-1/UIScreen.mainScreen.scale, self.contentView.frame.size.width-20, 1/UIScreen.mainScreen.scale);
}

@end

@interface QTMediaListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation QTMediaListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackground:)];
        [self addGestureRecognizer:tap];
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self addSubview:self.effectView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kQTMLTopMargin, kDeviceWidth, 0) style:UITableViewStylePlain];
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 20)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
        [self.tableView registerClass:[QTMediaListViewCell class] forCellReuseIdentifier:NSStringFromClass([QTMediaListViewCell class])];
        UIBlurEffect *e = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        self.tableView.separatorEffect = e;
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.effectView.contentView addSubview:self.tableView];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    self.frame = CGRectMake(0, newSuperview.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = CGRectMake(0, newSuperview.frame.size.height-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.effectView.frame = CGRectMake(0, self.bounds.size.height/3, self.bounds.size.width, self.bounds.size.height * 2 / 3.f);
    self.tableView.frame = CGRectMake(0, kQTMLTopMargin, self.effectView.bounds.size.width, self.effectView.bounds.size.height-kQTMLTopMargin);
}

#pragma mark - Action
- (void)didTapBackground:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, self.superview.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.layouts.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QTMediaListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QTMediaListViewCell.class)];
    cell.backgroundColor = [UIColor colorWithRed:kRandom(256)/255.f green:kRandom(256)/255.f blue:kRandom(256)/255.f alpha:kRandom(128)/255.f+0.5];
    cell.backgroundColor = UIColor.clearColor;
    cell.contentView.backgroundColor = UIColor.clearColor;
    cell.backgroundView.backgroundColor = UIColor.clearColor;
    cell.textLabel.textColor = UIColor.whiteColor;
    QTMediaItem *item = self.layouts[indexPath.row];
    cell.textLabel.text = item.name?:@"未知";
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    return cell;
}

- (void)setLayouts:(NSArray<QTMediaItem *> *)layouts {
    _layouts = layouts;
    [self.tableView reloadData];
}

@end
