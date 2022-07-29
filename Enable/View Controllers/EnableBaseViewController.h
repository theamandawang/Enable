//
//  EnableBaseViewController.h
//  Enable
//
//  Created by Amanda Wang on 7/22/22.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "ThemeTracker.h"
NS_ASSUME_NONNULL_BEGIN

@interface EnableBaseViewController : UIViewController
- (void) showAlert: (NSString *) title message: (NSString * _Nonnull) message  completion: (void (^ _Nullable)(void))completion;
- (void) startLoading;
- (void) endLoading;
- (void) testInternetConnection;
- (void) setupTheme;
- (void) setupMainTheme;

@end

NS_ASSUME_NONNULL_END
