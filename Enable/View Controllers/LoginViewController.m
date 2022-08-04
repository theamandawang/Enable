//
//  LoginViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "LoginViewController.h"
#import "UserProfile.h"
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passLabel;

@end
@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTheme];
}

//TODO: automatically scroll up when keyboard opens
//https://stackoverflow.com/questions/13161666/how-do-i-scroll-the-uiscrollview-when-the-keyboard-appears

- (void)navigateBack {
    [[ThemeTracker sharedTheme] getTheme];
    [self endLoading];
    [self.navigationController popViewControllerAnimated:NO];
}

- (BOOL)isEmail:(NSString *)email{
    // taken from user 93sauu
    // https://stackoverflow.com/questions/42664046/regex-for-email-validation-in-objective-c
    
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

#pragma mark - IBAction
- (IBAction)didTapSignUp:(id)sender {
    [self startLoading];
    [self testInternetConnection];
    if([self isEmail:self.emailTextField.text] && ![self.passTextField.text isEqualToString:@""]){
        [Utilities signUpWithEmail:self.emailTextField.text password:self.passTextField.text completion:^(NSError * _Nullable error) {
            if(error){
                [self endLoading];
                [self showAlert:@"Failed to sign up" message:error.localizedDescription completion:nil];
            } else {
                [self navigateBack];
            }
        }];
    } else {
        [self endLoading];
        [self showAlert:@"Invalid email/password" message:@"Not a valid email" completion:nil];
    }
    
}

- (IBAction)didTapLogin:(id)sender {
    [self startLoading];
    [self testInternetConnection];
    [Utilities logInWithEmail: self.emailTextField.text password:self.passTextField.text completion:^(NSError * _Nullable error) {
        if(error){
            [self endLoading];
            [self showAlert:@"Failed to login" message:error.localizedDescription completion:nil];
        } else {
            [[ThemeTracker sharedTheme] removeCustomTheme];
            [self navigateBack];
        }
        
    }];
}

- (IBAction)didTapView:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Setup
- (void) setupTheme {
    [self setupMainTheme];
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [self.contentView setBackgroundColor: [singleton getBackgroundColor]];
    [self.view setTintColor: [singleton getAccentColor]];
    
    [self.passTextField setBackgroundColor: [singleton getSecondaryColor]];
    [self.emailTextField setBackgroundColor: [singleton getSecondaryColor]];

    [self.passTextField setTextColor: [singleton getLabelColor]];
    [self.emailTextField setTextColor: [singleton getLabelColor]];
    
    [self.loginLabel setTextColor: [singleton getLabelColor]];
    [self.emailLabel setTextColor: [singleton getLabelColor]];
    [self.passLabel setTextColor: [singleton getLabelColor]];
}
@end
