//
//  ProfileViewController.h
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
#import "EnableBaseViewController.h"
#import "ResultsView.h"
#import "ProfileTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : EnableBaseViewController <ResultsViewDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ProfileDelegate>
@property (strong, nonatomic) id userProfileID;
@property (strong, nonatomic) UserProfile * currentProfile;
@end

NS_ASSUME_NONNULL_END
