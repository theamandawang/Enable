//
//  ComposeViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ComposeViewController
UITapGestureRecognizer *tapGesture;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapGesture];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



// prevents the scroll view from swallowing up the touch event of child buttons



// method to hide keyboard when user taps on a scrollview
-(void)hideKeyboard
{
    [self.scrollView endEditing:YES];
}
@end
