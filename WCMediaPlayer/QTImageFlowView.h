//
//  QTImageFlowView.h
//  WCMediaPlayer
//
//  Created by 齐江涛 on 2018/11/9.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QTImageCellItem : NSObject

@property (nonatomic, copy  ) NSString *imageName;
@property (nonatomic, strong) NSURL *bigImageURL;
@property (nonatomic, strong) UIImage *image;

@end

@interface QTImageFlowViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *imageView;

@end

@interface QTImageFlowView : UIView

@property (nonatomic, strong) NSArray<QTImageCellItem *> *layouts;
@property (nonatomic, copy  ) void (^didTapImageCallback)(NSIndexPath *idxpath, QTImageFlowViewCell *cell, QTImageCellItem *item);

- (void)showInView:(UIView *)sview;

@end

