//
//  QTTableViewController.m
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/6.
//  Copyright © 2018 daydream. All rights reserved.
//

#import "QTTableViewController.h"
#import "QTMediaCell.h"

@interface QTTableViewController ()

@end

@implementation QTTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.layouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QTMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    QTMediaItem *item = self.layouts[indexPath.row];
    cell.nameLabel.text = [item.URL.absoluteString componentsSeparatedByString:@"/"].lastObject;
    cell.imgButton.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.f green:arc4random_uniform(256)/255.f blue:arc4random_uniform(256)/255.f alpha:arc4random_uniform(128)/256.f + 0.5];
    
    [cell.imgButton addTarget:self action:@selector(didTapImgButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QTMediaCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - Action
- (void)didTapImgButton:(UIButton *)sender {
    QTMediaCell *cell = (QTMediaCell *)sender.superview.superview;
    [cell.imgButton.imageView startAnimating];
}

@end
