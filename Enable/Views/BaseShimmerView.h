//
//  BaseShimmerView.h
//  Enable
//
//  Created by Amanda Wang on 8/1/22.
//

#import <UIKit/UIKit.h>
#import "FBShimmeringView.h"
NS_ASSUME_NONNULL_BEGIN

@interface BaseShimmerView : UIView

@property (strong, nonatomic) FBShimmeringView *shimmeringView;
@property (weak, nonatomic) UIView *baseShimmeringContentView;
- (instancetype) initWith: (NSString *)nibName;
- (void) setBG:(UIColor *)bacgroundColor FG:(UIColor *)foregroundColor;
- (void) setup: (UIView *)contentView;
@end

NS_ASSUME_NONNULL_END
