//
//  ParseUtilities.m
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "ParseUtilities.h"
#import <UIKit/UIKit.h>
#import "ErrorHandler.h"
@implementation ParseUtilities

#pragma mark User Signup/Login/Logout
+ (void) logInWithEmail :(NSString* _Nonnull)email  password : (NSString* _Nonnull)password vc:(UIViewController * _Nonnull) vc completion:(void (^ _Nonnull)(void))completion{
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser* user, NSError* error){
            if(!error){
                completion();
            } else {
                NSLog(@"Fail logIn %@", error.localizedDescription);
                [ErrorHandler showAlertFromViewController:vc title:@"Failed to log in" message:error.localizedDescription completion:^{
                }];
            }
    }];
}
+ (void) signUpWithEmail : (NSString * _Nonnull) email password: (NSString * _Nonnull) password vc:(UIViewController * _Nonnull) vc completion:(void (^_Nonnull)(void))completion{
    PFUser *user = [PFUser user];
    user.username = email;
    user.password = password;
    UserProfile * userProfile = [[UserProfile alloc] initWithClassName:@"UserProfile"];
    userProfile.username = @"Anonymous User";
    userProfile.email = email;
    
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            userProfile.userID = [PFUser currentUser];
            [userProfile saveInBackgroundWithBlock:^(BOOL saveSucceeded, NSError * _Nullable saveError) {
                if(!saveError){
                    completion();
                } else {
                    NSLog(@"Fail save UserProfile (in signUp) %@", saveError.localizedDescription);
                    [ErrorHandler showAlertFromViewController:vc title:@"Failed to sign up" message:error.localizedDescription completion:^{
                    }];
                }
            }];
        } else {
            NSLog(@"Fail signUp %@", error.localizedDescription);
            [ErrorHandler showAlertFromViewController:vc title:@"Failed to sign up" message:error.localizedDescription completion:^{
            }];
        }
    }];
    
}

+ (void) logOutWithVC:(UIViewController *_Nonnull) vc withCompletion:(void (^_Nonnull)(void))completion{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(!error) {
            completion();
        } else {
            NSLog(@"Fail logOut %@", error.localizedDescription);
            [ErrorHandler showAlertFromViewController:vc title:@"Failed to log out" message:error.localizedDescription completion:^{
            }];
        }

    }];
}


#pragma mark UserProfile
+ (void) getCurrentUserProfileWithVC: (UIViewController * _Nonnull) vc withCompletion:(void (^_Nonnull)(UserProfile * _Nullable profile))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    if(![PFUser currentUser]){
        completion(nil);
        return;
    }
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:vc title:@"Failed to find the current user" message:error.localizedDescription completion:^{
            }];
            NSLog(@"Fail getCurrentUserProfile %@", error.localizedDescription);
            completion(nil);
        } else {
            if(userProfile){
                completion((UserProfile *) userProfile);
            }
            else{
                NSLog(@"no user found!");
                completion(nil);
            }
        }
    }];
}


+ (void) getUserProfileFromID: (id _Nonnull) userProfileID vc: (UIViewController * _Nonnull) vc withCompletion: (void (^_Nonnull)(UserProfile * _Nullable profile))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    [query getObjectInBackgroundWithId:userProfileID block:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(!error){
            completion((UserProfile *) userProfile);

        } else {
            [ErrorHandler showAlertFromViewController:vc title:@"Failed to get user profiles" message:error.localizedDescription completion:^{
            }];
            NSLog(@"Fail getUserProfileFromID %@", error.localizedDescription);
        }
    }];
}

#pragma mark Review

+ (void) getReviewFromID: (id _Nonnull) reviewID vc: (UIViewController * _Nonnull) vc withCompletion: (void (^_Nonnull)(Review * _Nullable review))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query getObjectInBackgroundWithId:reviewID block:^(PFObject * _Nullable dbReview, NSError * _Nullable error) {
        if(!error){
            completion((Review *) dbReview);
        } else {
            NSLog(@"Fail getReviewFromID %@", error.localizedDescription);
            [ErrorHandler showAlertFromViewController:vc title:@"Failed to get reviews" message:error.localizedDescription completion:^{
            }];
        }
        
    }];
}

+ (void) getReviewsByLocation: (Location * _Nonnull) location vc: (UIViewController * _Nonnull) vc withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews)) completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    //TODO: figure out how to deal with query limits? infinite scroll ? how to do this lol.
    query.limit = 20;
    [query whereKey:@"locationID" equalTo:location];
    [query orderByDescending:@"likes"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            completion((NSMutableArray<Review *> *) objects);
        } else {
            [ErrorHandler showAlertFromViewController:vc title:@"Failed to get reviews" message:error.localizedDescription completion:^{
            }];
            NSLog(@"Fail getReviewsByLocation %@", error.localizedDescription);
        }
    }];
}



#pragma mark Location

+ (void) getLocationFromPOI_idStr: (NSString * _Nonnull) POI_idStr vc: (UIViewController * _Nonnull) vc withCompletion: (void (^_Nonnull)(Location * _Nullable location))completion{
    PFQuery * query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"POI_idStr" equalTo:POI_idStr];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable dbLocation, NSError * _Nullable error) {
        if(!error){
            completion((Location *)dbLocation);
        } else {
            NSLog(@"Fail getLocationFromPOI_idStr %@", error.localizedDescription);
            if(!(error.code == 101)){
                [ErrorHandler showAlertFromViewController:vc title:@"Failed to get location" message:error.localizedDescription completion:^{
                }];
            }
            completion(nil);
        }
    }];
}

#pragma mark Posting
+ (void) postLocationWithPOI_idStr: (NSString * _Nonnull) POI_idStr coordinates: (PFGeoPoint * _Nonnull) coordinates name: (NSString * _Nonnull) name address: (NSString * _Nonnull) address vc: (UIViewController * _Nonnull) vc completion: (void (^_Nonnull)(Location * _Nullable location))completion {
    Location *location = [[Location alloc] initWithClassName:@"Location"];
    location.rating = 0;
    location.POI_idStr = POI_idStr;
    location.coordinates = coordinates;
    location.name = name;
    location.address = address;
    
    [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(!error){
            if(succeeded){
                completion(location);
            }
        } else {
            [ErrorHandler showAlertFromViewController:vc title:@"Failed to add location" message:error.localizedDescription completion:^{
            }];
            NSLog(@"Fail postLocationWithPOI_idStr %@", error.localizedDescription);
        }
    }];
}

+ (void) postReviewWithLocation:(Location * _Nonnull) location rating: (int) rating title: (NSString * _Nonnull) title description: (NSString * _Nonnull) description vc: (UIViewController * _Nonnull) vc completion: (void (^_Nonnull)(void))completion{
    [ParseUtilities getCurrentUserProfileWithVC: vc withCompletion:^(UserProfile * _Nullable profile) {
        Review *review = [[Review alloc] initWithClassName:@"Review"];
        review.userProfileID = profile;
        review.title = title;
        review.reviewText = description;
        review.rating = rating;
        review.locationID = location;
        review.images = nil;
        review.likes = 0;
        
        [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error){
                if(succeeded){
                    NSLog(@"Successful post review");
                    completion();
                } else {
                    [ErrorHandler showAlertFromViewController:vc title:@"Failed to post review" message:error.localizedDescription completion:^{
                    }];
                    NSLog(@"Fail saveReviewInBackground (in Post Review) %@", error.localizedDescription);
                }
            }
            else {
                [ErrorHandler showAlertFromViewController:vc title:@"Failed to post review" message:error.localizedDescription completion:^{
                }];
                NSLog(@"Fail getCurrentUserProfile (in Post Review) %@", error.localizedDescription);
            }
        }];
    }];
}
@end
