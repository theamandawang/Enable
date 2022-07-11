//
//  ProfileViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profileView.userProfile = self.userProfile;
    [self.profileView reloadUserData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) logOutWithCompletion:(void (^_Nonnull)(void))completion{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(!error) {
            completion();
        } else {
            //TODO: handle errors
            NSLog(@"%@", error.localizedDescription);
        }

    }];
}
- (IBAction)didTapLogout:(id)sender {
    [self logOutWithCompletion:^{
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }];
}

@end
