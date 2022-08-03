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
    NSString * status;
    if([[ThemeTracker sharedTheme].theme isEqualToString:@"Custom"]){
        status = [ThemeTracker sharedTheme].colorSet[@"StatusBar"];
    } else {
        status = [ThemeTracker sharedTheme].plist[@"StatusBar"];
    }
    if([status isEqualToString:@"Dark"]){
        return UIStatusBarStyleDarkContent;
    } else if ([status isEqualToString:@"Light"]){
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

@end
