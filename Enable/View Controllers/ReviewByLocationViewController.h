//
//  ReviewByLocationViewController.h
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "ResultsView.h"
#import "EnableBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
@protocol ReviewByLocationViewControllerDelegate
- (void) setGMSCameraCoordinatesWithLatitude: (CLLocationDegrees) latitude longitude: (CLLocationDegrees) longitude;
@end


@interface ReviewByLocationViewController : EnableBaseViewController <UITableViewDataSource, UITableViewDelegate, ResultsViewDelegate>
@property (weak, nonatomic) id<ReviewByLocationViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString * POI_idStr;
@end

NS_ASSUME_NONNULL_END
