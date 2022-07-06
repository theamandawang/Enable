//
//  LoginViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "SceneDelegate.h"
#import "HomeViewController.h"
#import "Parse/Parse.h"
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
- (void)navigateToProfile {
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"mainNav"];
    sceneDelegate.window.rootViewController = navController;
    [navController.topViewController performSegueWithIdentifier:@"signedIn" sender:nil];
}
- (IBAction)didTapSignUp:(id)sender {
    PFUser *user = [PFUser user];
    user.email = self.emailTextField.text;
    user.username = self.userTextField.text;
    user.password = self.passTextField.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self navigateToProfile];
        } else {
            NSLog(@"👿👿👿👿 doesn't work");
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (IBAction)didTapLogin:(id)sender {
    PFUser *user = [PFUser user];
    user.email = self.emailTextField.text;
    user.username = self.userTextField.text;
    user.password = self.passTextField.text;
    PFQuery *query = [PFUser query];
        [query whereKey:@"email" equalTo:self.emailTextField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (objects.count > 0) {
                PFObject *object = [objects objectAtIndex:0];
                NSString *username = [object objectForKey:@"username"];
                [PFUser logInWithUsernameInBackground:username password:self.passTextField.text block:^(PFUser* user, NSError* error){
                    if(!error){
                        NSLog(@"success");
                        [self navigateToProfile];
                    } else {
                        
                    }
                    
                }];
            }else{
                NSLog(@"nothing found");
            }
        }];
}
- (IBAction)didTapView:(id)sender {
    [self.view endEditing:YES];
}

@end
