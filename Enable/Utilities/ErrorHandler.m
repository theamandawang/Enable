//
//  ErrorHandler.m
//  Enable
//
//  Created by Amanda Wang on 7/12/22.
//

#import "ErrorHandler.h"
#import "LoadingViewController.h"
@implementation ErrorHandler
Reachability *internetReachable;

+ (void) showAlertFromViewController: (UIViewController* _Nonnull)vc title: (NSString *) title message: (NSString * _Nonnull) message  completion: (void (^ _Nonnull)(void))completion{
    if ([vc.navigationController.visibleViewController isKindOfClass:[UIAlertController class]]) {
        return;
    }
    else if ([vc.navigationController.visibleViewController isKindOfClass:[LoadingViewController class]]){
        [vc.navigationController dismissViewControllerAnimated:YES completion:^{
            [ErrorHandler testInternetConnection:vc];
        }];
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
                                    }];
    [alert addAction:closeAction];
    [vc presentViewController:alert animated:YES completion:^{
        if(completion){
            completion();
        }
    }];
}


#pragma mark - Reachability
+ (void)testInternetConnection: (UIViewController* _Nonnull)vc {
    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    internetReachable.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"Connected to network");
    };

    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ErrorHandler showAlertFromViewController:vc title:@"No network" message:@"Connect to network!" completion:^{
            }];
        });
    };

    [internetReachable startNotifier];
}

#pragma mark - Loading
+ (void) startLoading: (UIViewController * _Nonnull) vc {
    if(vc.presentedViewController){
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoadingViewController * loadingVC = [storyboard instantiateViewControllerWithIdentifier:@"LoadingViewController"];
    [vc.navigationController presentViewController:loadingVC animated:NO completion:^{
    }];
}

+ (void) endLoading: (UIViewController * _Nonnull) vc {
    [vc.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
