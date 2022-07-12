//
//  ProfileViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileViewController.h"
#import "ParseUtilities.h"

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
        [ParseUtilities getUserProfileFromID:self.userProfileID vc: self withCompletion:^(UserProfile * _Nullable userProfile) {
                self.profileView.userProfile = userProfile;
                [self.profileView reloadUserData];
        }];
    } else {
        [ParseUtilities getCurrentUserProfileWithVC: self withCompletion:^(UserProfile * _Nullable profile) {
            self.profileView.userProfile = profile;
            [self.profileView reloadUserData];
        }];
    }
    

}

- (IBAction)didTapLogout:(id)sender {
    [ParseUtilities logOutWithVC: self withCompletion:^{
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    } ];
}

@end
