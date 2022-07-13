//
//  ErrorHandler.h
//  Enable
//
//  Created by Amanda Wang on 7/12/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
//TODO: handle errors with network connection https://stackoverflow.com/questions/1083701/how-can-i-check-for-an-active-internet-connection-on-ios-or-macos
@protocol ViewErrorHandle
- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion;
@end
@interface ErrorHandler : NSObject
+ (void) showAlertFromViewController: (UIViewController* _Nonnull)vc title: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion;
@end

NS_ASSUME_NONNULL_END
