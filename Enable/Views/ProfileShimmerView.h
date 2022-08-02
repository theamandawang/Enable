//
//  ProfileShimmerView.h
//  Enable
//
//  Created by Amanda Wang on 8/2/22.
//

#import "BaseShimmerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileShimmerView : BaseShimmerView
@property (weak, nonatomic) IBOutlet UIView *shimmeringContentView;

- (void) setup;
@end

NS_ASSUME_NONNULL_END
