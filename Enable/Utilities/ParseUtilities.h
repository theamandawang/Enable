//
//  ParseUtilities.h
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import "Parse/Parse.h"
#import "UserProfile.h"
#import "Review.h"
#import "Location.h"
@interface ParseUtilities : NSObject

#pragma mark User Signup/Login/Logout
//user login
+ (void) logInWithEmail :(NSString* _Nonnull)email  password : (NSString* _Nonnull)password vc:(UIViewController * _Nonnull) vc completion:(void (^ _Nonnull)(void))completion;

//user signup
+ (void) signUpWithEmail : (NSString * _Nonnull) email password: (NSString * _Nonnull) password vc:(UIViewController * _Nonnull) vc completion:(void (^_Nonnull)(void))completion;

//log out

+ (void) logOutWithVC:(UIViewController *_Nonnull) vc withCompletion:(void (^_Nonnull)(void))completion ;


#pragma mark UserProfile
//get user profile
+ (void) getCurrentUserProfileWithVC: (UIViewController * _Nonnull) vc withCompletion:(void (^_Nonnull)(UserProfile * _Nullable profile))completion;
+ (void) getUserProfileFromID: (id _Nonnull) userProfileID vc: (UIViewController * _Nonnull) vc withCompletion: (void (^_Nonnull)(UserProfile * _Nullable profile))completion;


#pragma mark Review
+ (void) getReviewFromID: (id _Nonnull) reviewID vc: (UIViewController * _Nonnull) vc withCompletion: (void (^_Nonnull)(Review * _Nullable review))completion;
+ (void) getReviewsByLocation: (Location * _Nonnull) location vc: (UIViewController * _Nonnull) vc withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews)) completion;

#pragma mark Location
+ (void) getLocationFromPOI_idStr: (NSString * _Nonnull) POI_idStr vc: (UIViewController * _Nonnull) vc withCompletion: (void (^_Nonnull)(Location * _Nullable location))completion;


#pragma mark Posting
+ (void) postLocationWithPOI_idStr: (NSString * _Nonnull) POI_idStr coordinates: (PFGeoPoint * _Nonnull) coordinates name: (NSString * _Nonnull) name address: (NSString * _Nonnull) address vc: (UIViewController * _Nonnull) vc completion: (void (^_Nonnull)(Location * _Nullable location))completion;
+ (void) postReviewWithLocation:(Location * _Nonnull) location rating: (int) rating title: (NSString * _Nonnull) title description: (NSString * _Nonnull) description vc: (UIViewController * _Nonnull) vc completion: (void (^_Nonnull)(void))completion;

@end

