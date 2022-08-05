//
//  MainNavigationViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/29/22.
//

#import "MainNavigationViewController.h"
#import "ThemeTracker.h"
#import "Constants.h"
@interface MainNavigationViewController ()

@end

@implementation MainNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    NSString * status;
    status = [[ThemeTracker sharedTheme] getStatusBarColor];
    if([status isEqualToString:kDarkStatusBar]){
        return UIStatusBarStyleDarkContent;
    } else if ([status isEqualToString:kLightStatusBar]){
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

@end
