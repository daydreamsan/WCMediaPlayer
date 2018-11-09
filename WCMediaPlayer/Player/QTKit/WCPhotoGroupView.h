//
//  WCPhotoGroupView.h
//  vcistudent
//
//  Created by 齐江涛 on 2018/11/8.
//  Copyright © 2018 daydream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit/YYKit.h>

/// Single picture's info.
@interface WCPhotoGroupItem : NSObject

@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nonatomic, strong) NSURL *largeImageURL;
@property (nonatomic, strong) UIImage *image;

@end

/// Used to show a group of images.
/// One-shot.
@interface WCPhotoGroupView : UIView

@property (nonatomic, readonly) NSArray<WCPhotoGroupItem *> *groupItems;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL blurEffectBackground; ///< Default is YES

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGroupItems:(NSArray<WCPhotoGroupItem *> *)groupItems;

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)container
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;

@end
