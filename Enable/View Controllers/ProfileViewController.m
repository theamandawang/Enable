//
//  ProfileViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileViewController.h"
#import "Utilities.h"

@interface ProfileViewController() <ResultsViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@end

@implementation ProfileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLoading];
    if(self.userProfileID){
        [self.logOutButton setHidden:YES];
    }
    [self getCurrentProfile:^{
        [self getUserProfile];
        [self endLoading];
    }];
}
- (void) getUserProfile {
    if(self.userProfileID){
        [Utilities getUserProfileFromID:self.userProfileID withCompletion:^(UserProfile * _Nullable userProfile, NSError * _Nullable error) {
            if(error){
                [self showAlert:@"Failed to get user" message:error.localizedDescription completion:nil];
            } else {
                self.profileView.delegate = self;
                self.profileView.userProfile = userProfile;
                [self getReviewsByUserProfile:userProfile];
                [self.profileView reloadUserData];

            }
        }];
    } else {
        self.profileView.delegate = self;
        self.profileView.userProfile = self.currentProfile;
        [self getReviewsByUserProfile:self.currentProfile];
        [self.profileView reloadUserData];
    }

}

- (void) getCurrentProfile: (void (^ _Nonnull) (void)) completion {
    [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to get current user" message:error.localizedDescription completion:nil];
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
            [self showAlert:@"Failed to get reviews by user" message:error.localizedDescription completion:nil];
        } else {
            self.profileView.reviews = reviews;
            [self.profileView reloadUserData];

        }
    }];
}

- (IBAction)didTapLogout:(id)sender {
    [Utilities logOutWithCompletion:^(NSError * _Nullable error){
        if(error){
            [self showAlert:@"Failed to log out" message:error.localizedDescription completion:nil];
        } else {
            [self.navigationController popToRootViewControllerAnimated:TRUE];

        }
    } ];
}
#pragma mark - ResultsViewDelegate
- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion{
    [self showAlert:title message:message completion:completion];
}
- (void) addLikeFromUserProfile:(UserProfile *)currentProfile review:(Review *)review{
    [Utilities addLikeToReview:review fromUserProfile:currentProfile completion:^(NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to like" message:error.localizedDescription completion:nil];
        }
    }];
}
- (void) removeLikeFromReview:(Review *)review currentUser:(UserProfile *)currentProfile{
    [Utilities removeLikeFromReview:review fromUserProfile:currentProfile completion:^(NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to unlike" message:error.localizedDescription completion:nil];
        }
    }];
}
- (void) toLogin{
    [self performSegueWithIdentifier:@"profileToLogin" sender:nil];
}

@end
