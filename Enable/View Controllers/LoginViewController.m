//
//  LoginViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "UserProfile.h"
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
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

// allow iCloud Keychain ? for future development.
- (void)navigateToProfile {
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (void) signUpWithEmail : (NSString *) email password: (NSString *) password completion:(void (^_Nonnull)(void))completion{
    PFUser *user = [PFUser user];
    user.username = email;
    user.password = password;
    UserProfile * userProfile = [[UserProfile alloc] initWithClassName:@"UserProfile"];
    userProfile.username = @"Anonymous User";
    userProfile.email = email;
        
    if([self isEmail:email]){
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                userProfile.userID = [PFUser currentUser];
                [userProfile saveInBackgroundWithBlock:^(BOOL saveSucceeded, NSError * _Nullable saveError) {
                    if(!saveError){
                        completion();
                    } else {
                        //TODO: error handle
                        NSLog(@"%@", saveError.localizedDescription);
                    }
                }];
            } else {
                //TODO: error handle
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    } else {
        //TODO: error handle
        NSLog(@"NOT AN EMAIL !!!!!!!!!!!!!");
    }
}
- (IBAction)didTapSignUp:(id)sender {
    [self signUpWithEmail:self.emailTextField.text password:self.passTextField.text completion:^{
        [self navigateToProfile];
    }];
}
- (void) logInWithEmail :(NSString*)email  password : (NSString*)password completion:(void (^_Nonnull)(void))completion{
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser* user, NSError* error){
            if(!error){
                completion();
            } else {
                //TODO: error handle
                NSLog(@"%@", error.localizedDescription);
            }
    }];
}

- (IBAction)didTapLogin:(id)sender {
    [self logInWithEmail: self.emailTextField.text password:self.passTextField.text completion:^{
        [self navigateToProfile];
    }];
}
- (BOOL)isEmail:(NSString *)email{
    NSString *emailRegEx =
     @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
     @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
     @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
     @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
     @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
     @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
     @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [predicate evaluateWithObject:email];
}
- (IBAction)didEndEditingEmail:(id)sender {
    if([self.emailTextField.text isEqualToString: @""]){
        NSLog(@"must enter email");
    } else if(![self isEmail:self.emailTextField.text]){
        NSLog(@"not a valid email!");
    }
}
- (IBAction)didTapView:(id)sender {
    [self.view endEditing:YES];
}
@end
