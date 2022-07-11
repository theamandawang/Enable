//
//  ProfileView.h
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
NS_ASSUME_NONNULL_BEGIN

@interface ProfileView : UIView
@property(weak, nonatomic) UserProfile *userProfile;
- (void) reloadUserData;
@end

NS_ASSUME_NONNULL_END
