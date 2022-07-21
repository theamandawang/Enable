//
//  ErrorHandler.m
//  Enable
//
//  Created by Amanda Wang on 7/12/22.
//

#import "ErrorHandler.h"

@implementation ErrorHandler
Reachability *internetReachable;

+ (void) showAlertFromViewController: (UIViewController* _Nonnull)vc title: (NSString *) title message: (NSString * _Nonnull) message  completion: (void (^ _Nonnull)(void))completion{
    if(vc.presentedViewController){
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
@end
