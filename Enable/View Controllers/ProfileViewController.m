//
//  ProfileViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "ProfileView.h"
@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet ProfileView *profileView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //TODO: implement what is below in a prepareforsegue instead
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error.localizedDescription);
        } else {
            if(user){
                self.profileView.user = (UserProfile *)user;
                [self.profileView reloadUserData];
            }
            else{
                NSLog(@"no user found!");
            }
        }
    }];
    // Do any additional setup after loading the view.
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
