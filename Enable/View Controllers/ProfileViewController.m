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
    if(self.userProfileID){
        [self.logOutButton setHidden:YES];
    }
    [self getCurrentProfile:^{
        [self getUserProfile];
    }];
}
- (void) getUserProfile {
    if(self.userProfileID){
        [Utilities getUserProfileFromID:self.userProfileID withCompletion:^(UserProfile * _Nullable userProfile, NSDictionary * _Nullable error) {
            if(error){
                [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
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
    [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSDictionary * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
            }];
        } else {
            self.currentProfile = profile;
            self.profileView.currentProfile = profile;
            completion();
        }
    }];
}

- (void) getReviewsByUserProfile: (UserProfile *) userProfile {
    [Utilities getReviewsByUserProfile:userProfile withCompletion:^(NSMutableArray<Review *> * _Nullable reviews, NSDictionary * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
            }];
        } else {
            // TODO: handle reviews by this user profile

        }
    }];
}

- (IBAction)didTapLogout:(id)sender {
    [Utilities logOutWithCompletion:^(NSDictionary * _Nullable error){
        if(error){
            [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
            }];
        } else {
            [self.navigationController popToRootViewControllerAnimated:TRUE];

        }
    } ];
}

@end
