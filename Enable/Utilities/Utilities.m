//
//  Utilities.m
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
@implementation Utilities
#pragma mark Image -> PFFileObject
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.jpeg" data:imageData];
}

/* each function now provides a dictionary to the completion block
    the dictionary will contain
        - title
        - message (localizedDescription)
        - code
 */
const int kCustomizedErrorCode = 0;
const int kMaxRadius = 50;
const int kZoomOutRadius = 20;
#pragma mark User Signup/Login/Logout
+ (void) logInWithEmail :(NSString* _Nonnull)email  password : (NSString* _Nonnull)password completion:(void (^ _Nonnull)(NSDictionary  * _Nullable  error))completion{
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser* user, NSError* error){
            if(!error){
                completion(nil);
            } else {
                NSLog(@"Fail logIn %@", error.localizedDescription);
                NSDictionary * errorDict = @{@"title" : @"Failed to log in",
                                             @"message" : error.localizedDescription,
                                             @"code" : [NSNumber numberWithLong:error.code]};
                completion(errorDict);
            }
    }];
}
+ (void) signUpWithEmail : (NSString * _Nonnull) email password: (NSString * _Nonnull) password completion:(void (^_Nonnull)(NSDictionary  * _Nullable  error))completion{
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
                    completion(nil);
                } else {
                    NSLog(@"Fail save UserProfile (in signUp) %@", saveError.localizedDescription);
                    NSDictionary * errorDict = @{@"title" : @"Failed to sign up",
                                                 @"message" : saveError.localizedDescription,
                                                 @"code" : [NSNumber numberWithLong:saveError.code]};
                    completion(errorDict);
                }
            }];
        } else {
            NSLog(@"Fail signUp %@", error.localizedDescription);
            NSDictionary * errorDict = @{@"title" : @"Failed to sign up",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(errorDict);
        }
    }];
}

+ (void) logOutWithCompletion:(void (^_Nonnull)(NSDictionary  * _Nullable  error))completion{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(!error) {
            completion(nil);
        } else {
            NSLog(@"Fail logOut %@", error.localizedDescription);
            NSDictionary * errorDict = @{@"title" : @"Failed to log out",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(errorDict);
        }

    }];
}


#pragma mark UserProfile
+ (void) getCurrentUserProfileWithCompletion:(void (^_Nonnull)(UserProfile * _Nullable profile, NSDictionary  * _Nullable  error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    if(![PFUser currentUser]){
        NSDictionary * errorDict = @{@"title" : @"Failed to get the current user",
                                     @"message" : @"No user signed in",
                                     @"code" : [NSNumber numberWithInt: kCustomizedErrorCode]};
        completion(nil, errorDict);
        return;
    }
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(error){
            NSLog(@"Fail getCurrentUserProfile %@", error.localizedDescription);
            NSDictionary * errorDict = @{@"title" : @"Failed to get the current user",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
        } else {
            if(userProfile){
                completion((UserProfile *) userProfile, nil);
            }
            else{
                NSLog(@"no user found!");
                completion(nil, nil);
            }
        }
    }];
}


+ (void) getUserProfileFromID: (id _Nonnull) userProfileID withCompletion: (void (^_Nonnull)(UserProfile * _Nullable profile, NSDictionary  * _Nullable  error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    [query getObjectInBackgroundWithId:userProfileID block:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(!error){
            completion((UserProfile *) userProfile, nil);

        } else {
            NSDictionary * errorDict = @{@"title" : @"Failed to get the user",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
            NSLog(@"Fail getUserProfileFromID %@", error.localizedDescription);
        }
    }];
}

#pragma mark Review

+ (void) getReviewFromID: (id _Nonnull) reviewID withCompletion: (void (^_Nonnull)(Review * _Nullable review, NSDictionary * _Nullable error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query getObjectInBackgroundWithId:reviewID block:^(PFObject * _Nullable dbReview, NSError * _Nullable error) {
        if(!error){
            if(dbReview){
                completion((Review *) dbReview, nil);
            } else {
                NSDictionary * errorDict = @{@"title" : @"No review found",
                                             @"message" : @"This review doesn't exist",
                                             @"code" : [NSNumber numberWithInt: kCustomizedErrorCode]};
                completion(nil, errorDict);
            }
        } else {
            NSDictionary * errorDict = @{@"title" : @"Failed to get the review",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
            NSLog(@"Fail getReviewFromID %@", error.localizedDescription);
        }

    }];
}

+ (void) getReviewsByLocation: (Location * _Nonnull) location withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews, NSDictionary * _Nullable error)) completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    //TODO: infinite scroll
    query.limit = 20;
    [query whereKey:@"locationID" equalTo:location];
    [query addDescendingOrder:@"likes"];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            completion((NSMutableArray<Review *> *) objects, nil);
        } else {
            NSDictionary * errorDict = @{@"title" : @"Failed to get reviews",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
            NSLog(@"Fail getReviewsByLocation %@", error.localizedDescription);
        }
    }];
}

+ (void) getReviewsByUserProfile: (UserProfile * _Nonnull) profile withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews, NSDictionary * _Nullable error)) completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    //TODO: infinite scroll
    query.limit = 20;
    [query whereKey:@"userProfileID" equalTo:profile];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            completion((NSMutableArray<Review *> *) objects, nil);
        } else {
            NSDictionary * errorDict = @{@"title" : @"Failed to get reviews",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
            NSLog(@"Fail getReviewsByUserProfileID %@", error.localizedDescription);
        }
    }];
}



#pragma mark Location

+ (void) getLocationFromPOI_idStr: (NSString * _Nonnull) POI_idStr withCompletion: (void (^_Nonnull)(Location * _Nullable location, NSDictionary * _Nullable error))completion{
    PFQuery * query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"POI_idStr" equalTo:POI_idStr];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable dbLocation, NSError * _Nullable error) {
        if(!error){
            completion((Location *)dbLocation, nil);
        } else {
            NSLog(@"Fail getLocationFromPOI_idStr %@", error.localizedDescription);
            NSDictionary * errorDict = @{@"title" : @"Failed to get the location",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
        }
    }];
}

+ (void) getLocationsFromLocation: (CLLocationCoordinate2D) location corner: (CLLocationCoordinate2D) corner withCompletion: (void (^_Nonnull)(NSArray<Location *> * _Nullable locations, NSDictionary * _Nullable error))completion{
    PFQuery * query = [PFQuery queryWithClassName:@"Location"];
    PFGeoPoint * farRightCorner = [PFGeoPoint geoPointWithLatitude:corner.latitude longitude:corner.longitude];
    PFGeoPoint * point = [PFGeoPoint geoPointWithLatitude:location.latitude longitude:location.longitude];
    double radius = [point distanceInMilesTo:farRightCorner];
    if(radius > kMaxRadius) {
        return;
    }
    if(radius > kZoomOutRadius) {
        [query addDescendingOrder:@"rating"];
        [query addDescendingOrder:@"reviewCount"];
        query.limit = 5;
    }
    [query whereKey:@"coordinates" nearGeoPoint:point withinMiles:radius];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Location *> * _Nullable dbLocations, NSError * _Nullable error) {
        if(!error){
            completion(dbLocations, nil);
        } else {
            NSLog(@"Fail getLocationsFromLatitude longitude %@", error.localizedDescription);
            NSDictionary * errorDict = @{@"title" : @"Failed to get the location",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
        }
    }];
}
+ (bool) shouldUpdateLocation: (GMSProjection * _Nonnull) prevProjection currentRegion: (GMSVisibleRegion) currentRegion radius: (double) radius prevRadius: (double) prevRadius {
    if([prevProjection containsCoordinate: currentRegion.farRight] && [prevProjection containsCoordinate: currentRegion.farLeft] && [prevProjection containsCoordinate: currentRegion.nearRight] && [prevProjection containsCoordinate: currentRegion.nearLeft]){
        if(radius > kMaxRadius) {
            return false;
        }
        else if ((prevRadius > kZoomOutRadius && radius < kZoomOutRadius ) || (prevRadius > kMaxRadius && radius < kMaxRadius)) {
            return true;
        } else {
            return false;
        }
    }
    return true;
}

#pragma mark Posting
+ (void) postLocationWithPOI_idStr: (NSString * _Nonnull) POI_idStr coordinates: (PFGeoPoint * _Nonnull) coordinates name: (NSString * _Nonnull) name address: (NSString * _Nonnull) address completion: (void (^_Nonnull)(Location * _Nullable location, NSDictionary * _Nullable error))completion {
    Location *location = [[Location alloc] initWithClassName:@"Location"];
    location.rating = 0;
    location.reviewCount = 0;
    location.POI_idStr = POI_idStr;
    location.coordinates = coordinates;
    location.name = name;
    location.address = address;

    [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(!error){
            if(succeeded){
                completion(location, nil);
            }
        } else {
            NSLog(@"Fail postLocationWithPOI_idStr %@", error.localizedDescription);
            NSDictionary * errorDict = @{@"title" : @"Failed to post this location",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
        }
    }];
}

+ (void) postReviewWithLocation:(Location * _Nonnull) location rating: (int) rating title: (NSString * _Nonnull) title description: (NSString * _Nonnull) description images: (NSArray<UIImage *> * _Nullable) images completion: (void (^_Nonnull)(NSDictionary * _Nullable error))completion{
    NSMutableArray<PFFileObject *> * parseFiles = [[NSMutableArray alloc] init];
    for(UIImage * img in images){
        [parseFiles addObject: [Utilities getPFFileFromImage:img]];
    }
    [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSDictionary * _Nullable error) {
        Review *review = [[Review alloc] initWithClassName:@"Review"];
        if(error){
            completion(error);
            return;
        } else {
            
            [location incrementKey:@"reviewCount" byAmount:[NSNumber numberWithInt:1]];
            [location setRating: (location.rating * (location.reviewCount - 1) + rating) / location.reviewCount];
            [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error){
                    NSDictionary * errorDict = @{@"title" : @"Failed to increment location reviews",
                                                 @"message" : error.localizedDescription,
                                                 @"code" : [NSNumber numberWithLong:error.code]};
                    completion(errorDict);
                    return;
                } else if (!succeeded) {
                    NSDictionary * errorDict = @{@"title" : @"Failed to increment location reviews",
                                                 @"message" : @"Did not succeed",
                                                 @"code" : [NSNumber numberWithInt:kCustomizedErrorCode]};
                    completion(errorDict);
                    return;
                } else if (succeeded) {
                    review.userProfileID = profile;
                    review.title = title;
                    review.reviewText = description;
                    review.rating = rating;
                    review.locationID = location;
                    review.images = (NSArray *)parseFiles;
                    review.likes = 0;
                    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(!error){
                            if(succeeded){
                                NSLog(@"Successful post review");
                                completion(nil);
                            } else {
                                NSLog(@"Fail saveReviewInBackground (in Post Review) couldn't save.");
                                NSDictionary * errorDict = @{@"title" : @"Failed to post review",
                                                             @"message" : @"Couldn't save review in background",
                                                             @"code" : [NSNumber numberWithInt: kCustomizedErrorCode]};
                                completion(errorDict);
                            }
                        }
                        else {
                            NSLog(@"Fail getCurrentUserProfile (in Post Review) %@", error.localizedDescription);
                            NSDictionary * errorDict = @{@"title" : @"Failed to post review",
                                                         @"message" : error.localizedDescription,
                                                         @"code" : [NSNumber numberWithLong:error.code]};
                            completion(errorDict);
                        }
                    }];
                }
            }];
        }
    }];
}


#pragma mark Like

+ (void) addLikeToReview: (Review * _Nonnull) review fromUserProfile: (UserProfile * _Nonnull) profile completion: (void (^_Nonnull)(NSDictionary * _Nullable error))completion {
    [review.userLikes addObject:profile];
    [review incrementKey:@"likes" byAmount:[NSNumber numberWithInt:1]];
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            NSDictionary * errorDict = @{@"title" : @"Failed to like post",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(errorDict);
        } else if (!succeeded) {
            NSDictionary * errorDict = @{@"title" : @"Failed to like post",
                                         @"message" : @"Unable to like",
                                         @"code" : [NSNumber numberWithInt:kCustomizedErrorCode]};
            completion(errorDict);
        }
    }];
}

+ (void) removeLikeFromReview: (Review * _Nonnull) review fromUserProfile: (UserProfile * _Nonnull) profile completion: (void (^_Nonnull)(NSDictionary * _Nullable error))completion {
    [review.userLikes removeObject:profile];
    [review incrementKey:@"likes" byAmount:[NSNumber numberWithInt:-1]];

    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            NSDictionary * errorDict = @{@"title" : @"Failed to unlike post",
                                         @"message" : error.localizedDescription,
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(errorDict);
        } else if (!succeeded) {
            NSDictionary * errorDict = @{@"title" : @"Failed to unlike post",
                                         @"message" : @"Unable to unlike",
                                         @"code" : [NSNumber numberWithInt:kCustomizedErrorCode]};
            completion(errorDict);
        }
    }];
}
+ (void) isLikedbyUser: (UserProfile * _Nonnull) profile  review:(Review * _Nonnull) review completion: (void (^_Nonnull)(bool liked, NSDictionary * _Nullable error))completion{
    PFRelation * relation = review.userLikes;
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray<UserProfile *> * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSDictionary * errorDict = @{@"title" : @"Failed to unlike post",
                                         @"message" : @"Unable to unlike",
                                         @"code" : [NSNumber numberWithInt:kCustomizedErrorCode]};
            completion(false, errorDict);
        } else {
            if(objects){
                for(int i = 0; i < objects.count; i++){
                    if([objects[i].objectId isEqualToString: profile.objectId]){
                        completion(true, nil);
                        return;
                    }
                }
            }
            completion(false, nil);
        }
    }];
}

#pragma mark Google
static GMSPlacesClient * placesClient = nil;

+ (void) initializePlacesClient{
    if(!placesClient){
        placesClient = [[GMSPlacesClient alloc] init];
    }
}

+ (void) getPlaceDataFromPOI_idStr:(NSString * _Nonnull)POI_idStr withFields: (GMSPlaceField) fields withCompletion: (void (^_Nonnull)(GMSPlace * _Nullable place, NSDictionary * _Nullable error)) completion{
    [self initializePlacesClient];
    [placesClient fetchPlaceFromPlaceID:POI_idStr placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"An error occurred %@", [error localizedDescription]);
            NSDictionary * errorDict = @{@"title" : @"Failed to get Place data",
                                         @"message" : [error localizedDescription],
                                         @"code" : [NSNumber numberWithLong:error.code]};
            completion(nil, errorDict);
            return;
        }
        if (place != nil) {
            completion(place, nil);
        }
    }];

}

@end
