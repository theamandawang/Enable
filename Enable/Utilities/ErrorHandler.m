//
//  ErrorHandler.m
//  Enable
//
//  Created by Amanda Wang on 7/12/22.
//

#import "ErrorHandler.h"

@implementation ErrorHandler
+ (void) showAlertFromViewController: (UIViewController* _Nonnull)vc title: (NSString *) title message: (NSString * _Nonnull) message  completion: (void (^ _Nonnull)(void))completion{
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
@end
