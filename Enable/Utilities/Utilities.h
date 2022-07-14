//
//  Utilities.h
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import "Parse/Parse.h"
#import "UserProfile.h"
#import "Review.h"
#import "Location.h"
#import <GooglePlaces/GooglePlaces.h>
@interface Utilities : NSObject
#pragma mark Image -> PFFileObject
+ (PFFileObject *_Nullable)getPFFileFromImage: (UIImage * _Nullable)image;

#pragma mark User Signup/Login/Logout
//user login
+ (void) logInWithEmail :(NSString* _Nonnull)email  password : (NSString* _Nonnull)password completion:(void (^ _Nonnull)(NSDictionary  * _Nullable  error))completion;
//user signup
+ (void) signUpWithEmail : (NSString * _Nonnull) email password: (NSString * _Nonnull) password completion:(void (^_Nonnull)(NSDictionary  * _Nullable  error))completion;

//log out
+ (void) logOutWithCompletion:(void (^_Nonnull)(NSDictionary  * _Nullable  error))completion;


#pragma mark UserProfile
//get user profile
+ (void) getCurrentUserProfileWithCompletion:(void (^_Nonnull)(UserProfile * _Nullable profile, NSDictionary  * _Nullable  error))completion;
+ (void) getUserProfileFromID: (id _Nonnull) userProfileID withCompletion: (void (^_Nonnull)(UserProfile * _Nullable profile, NSDictionary  * _Nullable  error))completion;


#pragma mark Review
+ (void) getReviewFromID: (id _Nonnull) reviewID withCompletion: (void (^_Nonnull)(Review * _Nullable review, NSDictionary * _Nullable error))completion;
+ (void) getReviewsByLocation: (Location * _Nonnull) location withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews, NSDictionary * _Nullable error)) completion;

#pragma mark Location
+ (void) getLocationFromPOI_idStr: (NSString * _Nonnull) POI_idStr withCompletion: (void (^_Nonnull)(Location * _Nullable location, NSDictionary * _Nullable error))completion;


#pragma mark Posting
+ (void) postLocationWithPOI_idStr: (NSString * _Nonnull) POI_idStr coordinates: (PFGeoPoint * _Nonnull) coordinates name: (NSString * _Nonnull) name address: (NSString * _Nonnull) address completion: (void (^_Nonnull)(Location * _Nullable location, NSDictionary * _Nullable error))completion;
+ (void) postReviewWithLocation:(Location * _Nonnull) location rating: (int) rating title: (NSString * _Nonnull) title description: (NSString * _Nonnull) description images: (NSArray<PFFileObject *> * _Nullable) images completion: (void (^_Nonnull)(NSDictionary * _Nullable error))completion;


#pragma mark Like
+ (void) addLikeToReview: (Review * _Nonnull) review fromUserProfile: (UserProfile * _Nonnull) profile completion: (void (^_Nonnull)(NSDictionary * _Nullable error))completion;
+ (void) removeLikeFromReview: (Review * _Nonnull) review fromUserProfile: (UserProfile * _Nonnull) profile completion: (void (^_Nonnull)(NSDictionary * _Nullable error))completion;
+ (void) isLikedbyUser: (UserProfile * _Nonnull) profile  review:(Review * _Nonnull) review completion: (void (^_Nonnull)(bool liked, NSDictionary * _Nullable error))completion;

#pragma mark Google
+ (void) getPlaceDataFromPOI_idStr:(NSString * _Nonnull)POI_idStr withFields: (GMSPlaceField) fields withCompletion: (void (^_Nonnull)(GMSPlace * _Nullable place, NSDictionary * _Nullable error)) completion;
@end
