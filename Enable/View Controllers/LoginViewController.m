//
//  LoginViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "LoginViewController.h"
#import "Utilities.h"
#import "ErrorHandler.h"
#import "UserProfile.h"
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [ErrorHandler testInternetConnection:self];

}
//TODO: automatically scroll up when keyboard opens
//https://stackoverflow.com/questions/13161666/how-do-i-scroll-the-uiscrollview-when-the-keyboard-appears

// TODO: consider allowing iCloud Keychain for future development.
- (void)navigateBack {
    [ErrorHandler endLoading:self];
    [self.navigationController popViewControllerAnimated:TRUE];
}
- (IBAction)didTapSignUp:(id)sender {
    [ErrorHandler startLoading:self];
    if([self isEmail:self.emailTextField.text] && ![self.passTextField.text isEqualToString:@""]){
        [Utilities signUpWithEmail:self.emailTextField.text password:self.passTextField.text completion:^(NSError * _Nullable error) {
            if(error){
                [ErrorHandler endLoading:self];
                [ErrorHandler showAlertFromViewController:self title:@"Failed to sign up" message:error.localizedDescription completion:^{
                }];
            } else {
                [self navigateBack];
            }
        }];
    } else {
        [ErrorHandler endLoading:self];
        [ErrorHandler showAlertFromViewController:self title:@"Invalid username/password" message:@"Not a valid email" completion:^{
        }];
    }
    
}

- (IBAction)didTapLogin:(id)sender {
    [ErrorHandler startLoading:self];
    [ErrorHandler testInternetConnection:self];
    [Utilities logInWithEmail: self.emailTextField.text password:self.passTextField.text completion:^(NSError * _Nullable error) {
        if(error){
            [ErrorHandler endLoading:self];
            [ErrorHandler showAlertFromViewController:self title:@"Failed to login" message:error.localizedDescription completion:^{
            }];
        } else {
            [self navigateBack];
        }
        
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
