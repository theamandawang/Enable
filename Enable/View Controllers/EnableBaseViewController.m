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
    [self setupActivityIndicator];
    [self testInternetConnection];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(setupTheme)
            name:kThemeNotificationName object:nil];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
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
    [self.view setUserInteractionEnabled:NO];
    [self hideSubviews:YES];
    [self.activityView setHidden:NO];
    [self.activityView startAnimating];
}

- (void) endLoading {
    [self hideSubviews:NO];
    [self.activityView stopAnimating];
    [self.view setUserInteractionEnabled:YES];
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

#pragma mark - Theme
- (void) setupMainTheme {
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [self.activityView setColor: [singleton getLabelColor]];
    [self.navigationController.navigationBar setBarTintColor: [singleton getSecondaryColor]];
    [self.navigationController.navigationBar setTintColor: [singleton getAccentColor]];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjects:@[[singleton getLabelColor]] forKeys:@[NSForegroundColorAttributeName]]];
    [self.view setBackgroundColor:[singleton getBackgroundColor]];
    [self setNeedsStatusBarAppearanceUpdate];
}
#pragma mark - Private

- (void)setupActivityIndicator {
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.activityView setHidesWhenStopped:YES];
    [self.view addSubview:self.activityView];
    
    [self.activityView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.activityView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.activityView.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.activityView.heightAnchor constraintEqualToConstant:40].active = YES;
}

- (void)hideSubviews: (BOOL)hidden {
    for (UIView* view in self.view.subviews) {
        [view setHidden:hidden];
    }
}
@end
