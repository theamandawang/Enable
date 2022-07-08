//
//  ProfileViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "ProfileView.h"
@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet ProfileView *profileView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error.localizedDescription);
        } else {
            if(users){
                self.profileView.user = users[0];
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
- (IBAction)didTapLogout:(id)sender {
    NSLog(@"click logout");
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(!error){
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"mainNav"];
            sceneDelegate.window.rootViewController = navController;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

@end
