//
//  ProfileView.h
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
#import "Review.h"
#import "ResultsView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ProfileView : UIView <UITableViewDelegate, UITableViewDataSource>
@property(strong, nonatomic) UserProfile *userProfile;
@property(strong, nonatomic) UserProfile *currentProfile;
@property (strong, nonatomic) NSArray<Review *> * reviews;
@property (weak, nonatomic) id<ResultsViewDelegate> delegate;
- (void) reloadUserData;
@end

NS_ASSUME_NONNULL_END
