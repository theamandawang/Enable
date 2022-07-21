//
//  ProfileViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileViewController.h"
#import "Utilities.h"
#import "ErrorHandler.h"

@interface ProfileViewController()
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@end

@implementation ProfileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [ErrorHandler testInternetConnection:self];
    [ErrorHandler startLoading:self.view];
    if(self.userProfileID){
        [self.logOutButton setHidden:YES];
    }
    [self getCurrentProfile:^{
        [self getUserProfile];
        [ErrorHandler endLoading:self.view];
    }];
}
- (void) getUserProfile {
    if(self.userProfileID){
        [Utilities getUserProfileFromID:self.userProfileID withCompletion:^(UserProfile * _Nullable userProfile, NSError * _Nullable error) {
            if(error){
                [ErrorHandler showAlertFromViewController:self title:@"Failed to get user" message:error.localizedDescription completion:^{
                }];
            } else {
                self.profileView.userProfile = userProfile;
                [self getReviewsByUserProfile:userProfile];
                [self.profileView reloadUserData];

            }
        }];
    } else {
        self.profileView.userProfile = self.currentProfile;
        [self getReviewsByUserProfile:self.currentProfile];
        [self.profileView reloadUserData];
    }

}

- (void) getCurrentProfile: (void (^ _Nonnull) (void)) completion {
    [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:@"Failed to get current user" message:error.localizedDescription completion:^{
            }];
        } else {
            self.currentProfile = profile;
            self.profileView.currentProfile = profile;
            completion();
        }
    }];
}

- (void) getReviewsByUserProfile: (UserProfile *) userProfile {
    [Utilities getReviewsByUserProfile:userProfile withCompletion:^(NSMutableArray<Review *> * _Nullable reviews, NSError * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:@"Failed to get reviews by user" message:error.localizedDescription completion:^{
            }];
        } else {
            // TODO: handle reviews by this user profile

        }
    }];
}

- (IBAction)didTapLogout:(id)sender {
    [Utilities logOutWithCompletion:^(NSError * _Nullable error){
        if(error){
            [ErrorHandler showAlertFromViewController:self title:@"Failed to log out" message:error.localizedDescription completion:^{
            }];
        } else {
            [self.navigationController popToRootViewControllerAnimated:TRUE];

        }
    } ];
}

@end
