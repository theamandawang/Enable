//
//  MainNavigationViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/29/22.
//

#import "MainNavigationViewController.h"
#import "ThemeTracker.h"
@interface MainNavigationViewController ()

@end

@implementation MainNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    NSString * status = [ThemeTracker sharedTheme].colorSet[@"StatusBar"];
    if([status isEqualToString:@"Default"]){
        return UIStatusBarStyleDefault;
    } else if ([status isEqualToString:@"Light"]){
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDarkContent;
}

@end
