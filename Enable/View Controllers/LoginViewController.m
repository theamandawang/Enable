//
//  LoginViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "LoginViewController.h"
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

- (IBAction)didTapSignUp:(id)sender {
    PFUser *user = [PFUser user];
    user.email = self.emailTextField.text;
    user.username = self.userTextField.text;
    user.password = self.passTextField.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self didTapLogin:nil];
        } else {
            NSLog(@"👿👿👿👿 doesn't work");
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (IBAction)didTapLogin:(id)sender {
    NSLog(@"logging in");
}
- (IBAction)didTapView:(id)sender {
    [self.view endEditing:YES];
}

@end
