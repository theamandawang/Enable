//
//  EnableBaseViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/22/22.
//

#import "EnableBaseViewController.h"
#import "Reachability.h"
@interface EnableBaseViewController ()
@property (strong, nonatomic) UIActivityIndicatorView * activityView;
@property (strong, nonatomic) Reachability *internetReachable;

@end

@implementation EnableBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    [self testInternetConnection];
}

#pragma mark - Show Errors
- (void) showAlert: (NSString *) title message: (NSString * _Nonnull) message  completion: (void (^ _Nullable)(void))completion{
    if (self.presentedViewController) {
        return;
    }
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:(UIAlertControllerStyleAlert)
                     ];
    UIAlertAction *closeAction = [UIAlertAction
                                   actionWithTitle:@"Close"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * _Nonnull action) {
                                    if(completion)
                                        completion();
                                    }];
    [alert addAction:closeAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Loading
- (void) startLoading {
    [self.view.subviews setValue:@0.2 forKeyPath:@"alpha"];
    self.activityView.center = self.view.center;
    [self.activityView setHidesWhenStopped:YES];
    [self.view addSubview:self.activityView];
    [self.activityView setAlpha:1.0];
    [self.view setUserInteractionEnabled:NO];
    [self.activityView startAnimating];
}

- (void) endLoading {
    [self.view setUserInteractionEnabled:YES];
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
    [self.view.subviews setValue:@1.0 forKeyPath:@"alpha"];
}

#pragma mark - Reachability
- (void)testInternetConnection {
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];

    __weak typeof(self) weakSelf = self;
    self.internetReachable.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"Connected to network");
    };

    self.internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlert:@"No network" message:@"Connect to network!" completion:nil];
        });
    };

    [self.internetReachable startNotifier];
}
@end
