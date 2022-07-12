//
//  ErrorHandler.h
//  Enable
//
//  Created by Amanda Wang on 7/12/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ErrorHandler : NSObject
+ (void) showAlertFromViewController: (UIViewController* _Nonnull)vc title: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion;
@end

NS_ASSUME_NONNULL_END
