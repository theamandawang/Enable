//
//  ResultsView.h
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Review.h"
#import "UserProfile.h"

NS_ASSUME_NONNULL_BEGIN


@protocol ResultsViewDelegate
- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion;
- (void) toProfile: (id) userProfileID;
- (void) addLikeFromUserProfile: (UserProfile*) currentProfile review: (Review *) review;
- (void) removeLikeFromReview: (Review*) review currentUser: (UserProfile *) currentProfile;
- (void) toLogin;
@end


@interface ResultsView : UIView
@property (weak, nonatomic) id<ResultsViewDelegate> delegate;
@property (strong, nonatomic) Review *review;
@property (strong, nonatomic) UserProfile * currentProfile;
@property (strong, nonatomic) UserProfile * userProfile;
@property bool liked;
- (void) presentReview: (Review * _Nullable) review byUser: (UserProfile * _Nonnull) profile;
@end

NS_ASSUME_NONNULL_END
