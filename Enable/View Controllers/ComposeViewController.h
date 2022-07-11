//
//  ComposeViewController.h
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "UserProfile.h"
NS_ASSUME_NONNULL_BEGIN

@interface ComposeViewController : UIViewController
@property (strong, nonatomic) Location * location;
@property bool locationValid;
@property (strong, nonatomic) UserProfile * userProfile;

@end

NS_ASSUME_NONNULL_END
