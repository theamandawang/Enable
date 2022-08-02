//
//  ReviewShimmerView.h
//  Enable
//
//  Created by Amanda Wang on 8/1/22.
//

#import <UIKit/UIKit.h>
#import "BaseShimmerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReviewShimmerView : BaseShimmerView

@property (weak, nonatomic) IBOutlet UIView *shimmeringContentView;

- (void) setup;

@end

NS_ASSUME_NONNULL_END
