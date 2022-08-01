//
//  ShimmerView.h
//  Enable
//
//  Created by Amanda Wang on 8/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShimmerView : UIView
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *profilePlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
- (void) setSubviewColor:(UIColor *) color;
@end

NS_ASSUME_NONNULL_END
