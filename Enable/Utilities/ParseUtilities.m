//
//  ParseUtilities.m
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "ParseUtilities.h"
@implementation ParseUtilities
#pragma mark Image -> PFFileObject
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.jpeg" data:imageData];
}
#pragma mark User Signup/Login/Logout
+ (void) logInWithEmail :(NSString* _Nonnull)email  password : (NSString* _Nonnull)password completion:(void (^ _Nonnull)(void))completion{
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser* user, NSError* error){
            if(!error){
                completion();
            } else {
                //TODO: error handle
                NSLog(@"Fail logIn %@", error.localizedDescription);
            }
    }];
}
+ (void) signUpWithEmail : (NSString * _Nonnull) email password: (NSString * _Nonnull) password completion:(void (^_Nonnull)(void))completion{
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
                    //TODO: error handle
                    NSLog(@"Fail save UserProfile (in signUp) %@", saveError.localizedDescription);
                }
            }];
        } else {
            //TODO: error handle
            NSLog(@"Fail signUp %@", error.localizedDescription);
        }
    }];
    
}

+ (void) logOutWithCompletion:(void (^_Nonnull)(void))completion{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(!error) {
            completion();
        } else {
            //TODO: handle errors
            NSLog(@"Fail logOut %@", error.localizedDescription);
        }

    }];
}


#pragma mark UserProfile
+ (void) getCurrentUserProfileWithCompletion:(void (^_Nonnull)(UserProfile * _Nullable profile))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    if(![PFUser currentUser]){
        completion(nil);
        return;
    }
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(error){
            //TODO: error handle
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


+ (void) getUserProfileFromID: (id _Nonnull) userProfileID withCompletion: (void (^_Nonnull)(UserProfile * _Nullable profile))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    [query getObjectInBackgroundWithId:userProfileID block:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(!error){
            completion((UserProfile *) userProfile);

        } else {
            NSLog(@"Fail getUserProfileFromID %@", error.localizedDescription);
        }
    }];
}

#pragma mark Review

+ (void) getReviewFromID: (id _Nonnull) reviewID withCompletion: (void (^_Nonnull)(Review * _Nullable review))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query getObjectInBackgroundWithId:reviewID block:^(PFObject * _Nullable dbReview, NSError * _Nullable error) {
        if(!error){
            completion((Review *) dbReview);
        } else {
            //TODO: error handle
            NSLog(@"Fail getReviewFromID %@", error.localizedDescription);
        }
        
    }];
}

+ (void) getReviewsByLocation: (Location * _Nonnull) location withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews)) completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    //TODO: figure out how to deal with query limits? infinite scroll ? how to do this lol.
    query.limit = 20;
    [query whereKey:@"locationID" equalTo:location];
    [query orderByDescending:@"likes"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            completion((NSMutableArray<Review *> *) objects);
        } else {
            //TODO: error handle
            NSLog(@"Fail getReviewsByLocation %@", error.localizedDescription);
        }
    }];
}



#pragma mark Location

+ (void) getLocationFromPOI_idStr: (NSString * _Nonnull) POI_idStr withCompletion: (void (^_Nonnull)(Location * _Nullable location))completion{
    PFQuery * query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"POI_idStr" equalTo:POI_idStr];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable dbLocation, NSError * _Nullable error) {
        if(!error){
            completion((Location *)dbLocation);
        } else {
            NSLog(@"Fail getLocationFromPOI_idStr %@", error.localizedDescription);
            completion(nil);
        }
    }];
}

#pragma mark Posting
+ (void) postLocationWithPOI_idStr: (NSString * _Nonnull) POI_idStr coordinates: (PFGeoPoint * _Nonnull) coordinates name: (NSString * _Nonnull) name address: (NSString * _Nonnull) address completion: (void (^_Nonnull)(Location * _Nullable location))completion {
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
            NSLog(@"Fail postLocationWithPOI_idStr %@", error.localizedDescription);
        }
    }];
}

+ (void) postReviewWithLocation:(Location * _Nonnull) location rating: (int) rating title: (NSString * _Nonnull) title description: (NSString * _Nonnull) description images: (NSArray<PFFileObject *> * _Nullable) images completion: (void (^_Nonnull)(void))completion{
    [ParseUtilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile) {
        Review *review = [[Review alloc] initWithClassName:@"Review"];
        review.userProfileID = profile;
        review.title = title;
        review.reviewText = description;
        review.rating = rating;
        review.locationID = location;
        review.images = images;
        
        [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error){
                if(succeeded){
                    NSLog(@"Successful post review");
                    completion();
                } else {
                    //TODO: implement error check
                    NSLog(@"Fail saveReviewInBackground (in Post Review) %@", error.localizedDescription);
                }
            }
            else {
                //TODO: implement error check
                NSLog(@"Fail getCurrentUserProfile (in Post Review) %@", error.localizedDescription);
            }
        }];
    }];
}
    
#pragma mark Image from URL

+ (void) getImageFromURL: (NSURL * _Nonnull)imageURL withCompletion: (void (^_Nonnull)(UIImage * _Nullable image))completion{
    NSURLRequest *request=[NSURLRequest requestWithURL:imageURL];
}
@end
