//
//  ShimmerView.h
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

- (void) set:(UIColor *)bacgroundColor and:(UIColor *)foregroundColor;

@end

@interface ShimmerView : BaseShimmerView

//@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (weak, nonatomic) IBOutlet UIView *shimmeringContentView;

- (void) setup;

@end

NS_ASSUME_NONNULL_END
