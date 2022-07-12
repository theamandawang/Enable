//
//  ReviewByLocationViewController.h
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "UserProfile.h"
NS_ASSUME_NONNULL_BEGIN

@interface ReviewByLocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString * POI_idStr;
@end

NS_ASSUME_NONNULL_END
