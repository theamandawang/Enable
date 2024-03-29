//
//  Review.h
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "Parse/Parse.h"
#import "Location.h"
#import "UserProfile.h"
@interface Review : PFObject<PFSubclassing>

@property (nonatomic, strong) UserProfile * _Nonnull userProfileID;
@property int rating;
@property (nonatomic, strong) NSString * _Nonnull title;
@property (nonatomic, strong) NSString * _Nonnull reviewText;
@property (nonatomic, strong) Location *_Nonnull locationID;
@property int likes;
@property (nonatomic, strong) NSArray<PFFileObject *> *_Nullable images;
@property (nonatomic, strong) NSString *_Nullable measuredItem;
@property float measurement;
@property (nonatomic, strong, readonly) PFRelation<UserProfile *> * _Nonnull userLikes;
@end
