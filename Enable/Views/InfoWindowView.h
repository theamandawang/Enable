//
//  InfoWindowView.h
//  Enable
//
//  Created by Amanda Wang on 7/20/22.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView/HCSStarRatingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface InfoWindowView : UIView
@property (strong, nonatomic) HCSStarRatingView *starRatingView;
@property (strong, nonatomic) UILabel *placeNameLabel;
@end

NS_ASSUME_NONNULL_END
