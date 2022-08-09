//
//  ResultsView.h
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Review.h"
#import "UserProfile.h"
#import "Parse/PFImageView.h"
#import "HCSStarRatingView/HCSStarRatingView.h"

NS_ASSUME_NONNULL_BEGIN


@protocol ResultsViewDelegate
@required
- (void) addLikeFromUserProfile: (UserProfile*) currentProfile review: (Review *) review;
- (void) removeLikeFromReview: (Review*) review currentUser: (UserProfile *) currentProfile;
- (void) toLogin;
@optional
- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion;
- (void) toProfile: (id) userProfileID;
@end


@interface ResultsView : UIView
@property (weak, nonatomic) id<ResultsViewDelegate> delegate;
@property (strong, nonatomic) Review *review;
@property (strong, nonatomic) UserProfile * currentProfile;
@property (strong, nonatomic) UserProfile * userProfile;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *measurementLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) HCSStarRatingView *starRatingView;

@property bool liked;

- (void) presentReview: (Review * _Nullable) review byUser: (UserProfile * _Nonnull) profile;
@end

NS_ASSUME_NONNULL_END
