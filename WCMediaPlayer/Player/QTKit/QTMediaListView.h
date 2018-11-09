//
//  QTMediaListView.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/7.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTMediaPlayer.h"

@interface QTMediaListViewCell : UITableViewCell

@end

@interface QTMediaListView : UIView

@property (nonatomic, strong) NSArray<QTMediaItem *> *layouts;

@end
