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
#import "CloudThemes.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
@interface Utilities : NSObject
#pragma mark Image -> PFFileObject
+ (PFFileObject *_Nullable)getPFFileFromImage: (UIImage * _Nullable)image;

#pragma mark User Signup/Login/Logout
+ (void) logInWithEmail :(NSString* _Nonnull)email  password : (NSString* _Nonnull)password completion:(void (^ _Nonnull)(NSError  * _Nullable  error))completion;
+ (void) signUpWithEmail : (NSString * _Nonnull) email password: (NSString * _Nonnull) password completion:(void (^_Nonnull)(NSError  * _Nullable  error))completion;
+ (void) logOutWithCompletion:(void (^_Nonnull)(NSError  * _Nullable  error))completion;


#pragma mark UserProfile
+ (void) getCurrentUserProfileWithCompletion:(void (^_Nonnull)(UserProfile * _Nullable profile, NSError  * _Nullable  error))completion;
+ (void) getUserProfileFromID: (id _Nonnull) userProfileID withCompletion: (void (^_Nonnull)(UserProfile * _Nullable profile, NSError  * _Nullable  error))completion;
+ (void) updateUserProfile: (UserProfile * _Nonnull) userProfile withUser: (NSString * _Nullable) username withImage: (UIImage * _Nullable) image withCompletion: (void (^_Nonnull)(NSError  * _Nullable  error))completion;
+ (void) updateUserProfile: (UserProfile * _Nonnull) userProfile withTheme : (NSString * _Nonnull) theme withCustom: (NSDictionary<NSString *, UIColor *> * _Nullable) customDict withCompletion: (void (^_Nullable) (NSError * _Nullable error)) completion;

#pragma mark Review
+ (void) getReviewFromID: (id _Nonnull) reviewID withCompletion: (void (^_Nonnull)(Review * _Nullable review, NSError * _Nullable error))completion;
+ (void) getReviewsByLocation: (Location * _Nonnull) location withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews, NSError * _Nullable error)) completion;
+ (void) getReviewsByUserProfile: (UserProfile * _Nonnull) profile withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews, NSError * _Nullable error)) completion;


#pragma mark Location
+ (void) getLocationFromID: (id _Nonnull ) locationID withCompletion: (void (^_Nonnull)(Location * _Nullable location, NSError * _Nullable error))completion;
+ (void) getLocationFromPOI_idStr: (NSString * _Nonnull) POI_idStr withCompletion: (void (^_Nonnull)(Location * _Nullable location, NSError * _Nullable error))completion;
+ (void) getLocationsFromLocation: (CLLocationCoordinate2D) location corner: (CLLocationCoordinate2D) corner withCompletion: (void (^_Nonnull)(NSArray<Location *> * _Nullable locations, NSError * _Nullable error))completion;
#pragma mark Posting
+ (void) postLocationWithPOI_idStr: (NSString * _Nonnull) POI_idStr coordinates: (PFGeoPoint * _Nonnull) coordinates name: (NSString * _Nonnull) name address: (NSString * _Nonnull) address completion: (void (^_Nonnull)(Location * _Nullable location, NSError * _Nullable error))completion;
+ (void) postReviewWithLocation:(Location * _Nonnull) location rating: (int) rating title: (NSString * _Nonnull) title description: (NSString * _Nonnull) description images: (NSArray<UIImage *> * _Nullable) images measurement: (float) measurement measuredItem: (NSString * _Nullable) measuredItem completion: (void (^_Nonnull)(NSError * _Nullable error))completion;
+ (bool) shouldUpdateLocation: (GMSProjection * _Nonnull) prevProjection currentRegion: (GMSVisibleRegion) currentRegion radius: (double) radius prevRadius: (double) prevRadius;

#pragma mark Like
+ (void) addLikeToReview: (Review * _Nonnull) review fromUserProfile: (UserProfile * _Nonnull) profile completion: (void (^_Nonnull)(NSError * _Nullable error))completion;
+ (void) removeLikeFromReview: (Review * _Nonnull) review fromUserProfile: (UserProfile * _Nonnull) profile completion: (void (^_Nonnull)(NSError * _Nullable error))completion;
+ (void) isLikedbyUser: (UserProfile * _Nonnull) profile  review:(Review * _Nonnull) review completion: (void (^_Nonnull)(bool liked, NSError * _Nullable error))completion;

#pragma mark Google
+ (void) getPlaceDataFromPOI_idStr:(NSString * _Nonnull)POI_idStr withFields: (GMSPlaceField) fields withCompletion: (void (^_Nonnull)(GMSPlace * _Nullable place, NSError * _Nullable error)) completion;

#pragma mark - Cloud themes
+ (void) getCloudThemesWithCompletion: (void (^_Nonnull)(NSDictionary <NSString *, NSDictionary<NSString *, NSString *> *> * _Nullable cloudThemes, NSError * _Nullable error)) completion;

@end
