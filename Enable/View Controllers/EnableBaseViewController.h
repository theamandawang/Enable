//
//  EnableBaseViewController.h
//  Enable
//
//  Created by Amanda Wang on 7/22/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnableBaseViewController : UIViewController
@property (strong, nonatomic) NSDictionary * themes;
- (void) showAlert: (NSString *) title message: (NSString * _Nonnull) message  completion: (void (^ _Nullable)(void))completion;
- (void) startLoading;
- (void) endLoading;
- (void) testInternetConnection;

@end

NS_ASSUME_NONNULL_END
