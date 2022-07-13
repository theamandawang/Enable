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
    [self getUserProfile];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) getUserProfile {
    if(self.userProfileID){
        [Utilities getUserProfileFromID:self.userProfileID withCompletion:^(UserProfile * _Nullable userProfile, NSDictionary * _Nullable error) {
            if(error){
                [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
                }];
            } else {
                self.profileView.userProfile = userProfile;
                [self.profileView reloadUserData];
            }
        }];
    } else {
        [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSDictionary * _Nullable error) {
            if(error){
                [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
                }];
            } else {
                self.profileView.userProfile = profile;
                [self.profileView reloadUserData];
            }
        }];
    }
    

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
