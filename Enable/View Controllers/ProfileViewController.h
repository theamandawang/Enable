//
//  ProfileViewController.h
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "ProfileView.h"
#import "UserProfile.h"
#import "EnableBaseViewController.h"
#import "ResultsView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : EnableBaseViewController <ResultsViewDelegate, ProfileViewDelegate>
@property (weak, nonatomic) IBOutlet ProfileView *profileView;
@property (strong, nonatomic) id userProfileID;
@property (strong, nonatomic) UserProfile * currentProfile;
@end

NS_ASSUME_NONNULL_END
