//
//  QTTableViewController.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/6.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTMediaPlayer.h"

@interface QTTableViewController : UITableViewController

@property (nonatomic, strong) NSArray<QTMediaItem *> *layouts;

@end
