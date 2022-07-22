//
//  LoginViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "LoginViewController.h"
#import "Utilities.h"
#import "UserProfile.h"
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}
//TODO: automatically scroll up when keyboard opens
//https://stackoverflow.com/questions/13161666/how-do-i-scroll-the-uiscrollview-when-the-keyboard-appears

// TODO: consider allowing iCloud Keychain for future development.
- (void)navigateBack {
    [self endLoading];

    [self.navigationController popViewControllerAnimated:NO];
}
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
        [self showAlert:@"Invalid username/password" message:@"Not a valid email" completion:nil];
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
