//
//  LoadingViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/20/22.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()
@property UIActivityIndicatorView * activityIndicator;
@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setAlpha:0.8];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.frame = CGRectMake(40.0, 20.0, 100.0, 100.0);
    self.activityIndicator.center = self.view.center;
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view setAlpha:1.0];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
}
@end
