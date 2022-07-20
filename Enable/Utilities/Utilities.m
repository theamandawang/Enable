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

const int kCustomizedErrorCode = 0;
const int kMaxRadius = 50;
const int kZoomOutRadius = 20;
#pragma mark User Signup/Login/Logout
+ (void) logInWithEmail :(NSString* _Nonnull)email  password : (NSString* _Nonnull)password completion:(void (^ _Nonnull)(NSError  * _Nullable  error))completion{
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser* user, NSError* error){
            if(!error){
                completion(nil);
            } else {
                NSLog(@"Fail logIn %@", error.localizedDescription);
                completion(error);
            }
    }];
}
+ (void) signUpWithEmail : (NSString * _Nonnull) email password: (NSString * _Nonnull) password completion:(void (^_Nonnull)(NSError  * _Nullable  error))completion{
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
                    completion(saveError);
                }
            }];
        } else {
            NSLog(@"Fail signUp %@", error.localizedDescription);
            completion(error);
        }
    }];
}

+ (void) logOutWithCompletion:(void (^_Nonnull)(NSError  * _Nullable  error))completion{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(!error) {
            completion(nil);
        } else {
            NSLog(@"Fail logOut %@", error.localizedDescription);
            completion(error);
        }

    }];
}


#pragma mark UserProfile
+ (void) getCurrentUserProfileWithCompletion:(void (^_Nonnull)(UserProfile * _Nullable profile, NSError  * _Nullable  error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    if(![PFUser currentUser]){
        NSError * error = [[NSError alloc] initWithDomain:@"CustomError" code:kCustomizedErrorCode userInfo:@{NSLocalizedDescriptionKey : @"No user signed in"}];
        completion(nil, error);
        return;
    }
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(error){
            NSLog(@"Fail getCurrentUserProfile %@", error.localizedDescription);
            completion(nil, error);
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


+ (void) getUserProfileFromID: (id _Nonnull) userProfileID withCompletion: (void (^_Nonnull)(UserProfile * _Nullable profile, NSError  * _Nullable  error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    [query getObjectInBackgroundWithId:userProfileID block:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(!error){
            completion((UserProfile *) userProfile, nil);

        } else {
            completion(nil, error);
            NSLog(@"Fail getUserProfileFromID %@", error.localizedDescription);
        }
    }];
}

#pragma mark Review

+ (void) getReviewFromID: (id _Nonnull) reviewID withCompletion: (void (^_Nonnull)(Review * _Nullable review, NSError * _Nullable error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    [query getObjectInBackgroundWithId:reviewID block:^(PFObject * _Nullable dbReview, NSError * _Nullable error) {
        if(!error){
            if(dbReview){
                completion((Review *) dbReview, nil);
            } else {
                completion(nil, error);
            }
        } else {
            completion(nil, error);
            NSLog(@"Fail getReviewFromID %@", error.localizedDescription);
        }

    }];
}

+ (void) getReviewsByLocation: (Location * _Nonnull) location withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews, NSError * _Nullable error)) completion{
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
            completion(nil, error);
            NSLog(@"Fail getReviewsByLocation %@", error.localizedDescription);
        }
    }];
}

+ (void) getReviewsByUserProfile: (UserProfile * _Nonnull) profile withCompletion: (void (^ _Nonnull) (NSMutableArray<Review *> * _Nullable reviews, NSError * _Nullable error)) completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Review"];
    //TODO: infinite scroll
    query.limit = 20;
    [query whereKey:@"userProfileID" equalTo:profile];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            completion((NSMutableArray<Review *> *) objects, nil);
        } else {
            completion(nil, error);
            NSLog(@"Fail getReviewsByUserProfileID %@", error.localizedDescription);
        }
    }];
}



#pragma mark Location

+ (void) getLocationFromPOI_idStr: (NSString * _Nonnull) POI_idStr withCompletion: (void (^_Nonnull)(Location * _Nullable location, NSError * _Nullable error))completion{
    PFQuery * query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"POI_idStr" equalTo:POI_idStr];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable dbLocation, NSError * _Nullable error) {
        if(!error){
            completion((Location *)dbLocation, nil);
        } else {
            NSLog(@"Fail getLocationFromPOI_idStr %@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}

+ (void) getLocationsFromLocation: (CLLocationCoordinate2D) location corner: (CLLocationCoordinate2D) corner withCompletion: (void (^_Nonnull)(NSArray<Location *> * _Nullable locations, NSError * _Nullable error))completion{
    PFQuery * query = [PFQuery queryWithClassName:@"Location"];
    PFGeoPoint * farRightCorner = [PFGeoPoint geoPointWithLatitude:corner.latitude longitude:corner.longitude];
    PFGeoPoint * point = [PFGeoPoint geoPointWithLatitude:location.latitude longitude:location.longitude];
    double radius = [point distanceInMilesTo:farRightCorner];
    if(radius > kMaxRadius) {
        radius = kMaxRadius;
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
            completion(nil, error);
        }
    }];
}
+ (bool) shouldUpdateLocation: (GMSProjection * _Nonnull) prevProjection currentRegion: (GMSVisibleRegion) currentRegion radius: (double) radius prevRadius: (double) prevRadius {
    // if the current camera view contains the previous
    if([prevProjection containsCoordinate: currentRegion.farRight] && [prevProjection containsCoordinate: currentRegion.farLeft] && [prevProjection containsCoordinate: currentRegion.nearRight] && [prevProjection containsCoordinate: currentRegion.nearLeft]){
        // i.e. prevRadius = 70 -> radius = 60 should not cause a refetch
        if(radius > kMaxRadius) {
            return false;
        }
        // i.e. prevRadius = 30 and radius = 10 or prevRadius = 60 and radius = 40, then refetch
        else if ((prevRadius > kZoomOutRadius && radius <= kZoomOutRadius ) || (prevRadius >= kMaxRadius && radius < kMaxRadius)) {
            return true;
        } else {
            return false;
        }
    }
    // otherwise, current camera view isn't in the previously fetched
    return true;
}

#pragma mark Posting
+ (void) postLocationWithPOI_idStr: (NSString * _Nonnull) POI_idStr coordinates: (PFGeoPoint * _Nonnull) coordinates name: (NSString * _Nonnull) name address: (NSString * _Nonnull) address completion: (void (^_Nonnull)(Location * _Nullable location, NSError * _Nullable error))completion {
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
            completion(nil, error);
        }
    }];
}
+ (double) calculateNewAverage: (double) currAvg withRating: (int) rating numReviews: (int) numReviews{
    return (currAvg * numReviews + rating) / (numReviews + 1);
}

+ (void) postReviewWithLocation:(Location * _Nonnull) location rating: (int) rating title: (NSString * _Nonnull) title description: (NSString * _Nonnull) description images: (NSArray<UIImage *> * _Nullable) images completion: (void (^_Nonnull)(NSError * _Nullable error))completion{
    NSMutableArray<PFFileObject *> * parseFiles = [[NSMutableArray alloc] init];
    for(UIImage * img in images){
        [parseFiles addObject: [Utilities getPFFileFromImage:img]];
    }
    [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable profileError) {
        Review *review = [[Review alloc] initWithClassName:@"Review"];
        if(profileError){
            completion(profileError);
            return;
        } else {
            [location setRating: [Utilities calculateNewAverage:location.rating withRating:rating numReviews:location.reviewCount]];
            [location incrementKey:@"reviewCount" byAmount:[NSNumber numberWithInt:1]];
            [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable locationError) {
                if(locationError){
                    completion(locationError);
                    return;
                } else if (!succeeded) {
                    NSError * customError = [[NSError alloc] initWithDomain:@"CustomError" code:kCustomizedErrorCode userInfo:@{NSLocalizedDescriptionKey : @"Did not increment location reviews"}];
                    completion(customError);
                    return;
                } else if (succeeded) {
                    review.userProfileID = profile;
                    review.title = title;
                    review.reviewText = description;
                    review.rating = rating;
                    review.locationID = location;
                    review.images = (NSArray *)parseFiles;
                    review.likes = 0;
                    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable reviewError) {
                        if(!reviewError){
                            if(succeeded){
                                NSLog(@"Successful post review");
                                completion(nil);
                            } else {
                                NSLog(@"Fail saveReviewInBackground (in Post Review) couldn't save.");
                                NSError * customError = [[NSError alloc] initWithDomain:@"CustomError" code:kCustomizedErrorCode userInfo:@{NSLocalizedDescriptionKey : @"Did not save review"}];
                                completion(customError);
                            }
                        }
                        else {
                            completion(reviewError);
                        }
                    }];
                }
            }];
        }
    }];
}


#pragma mark Like

+ (void) addLikeToReview: (Review * _Nonnull) review fromUserProfile: (UserProfile * _Nonnull) profile completion: (void (^_Nonnull)(NSError * _Nullable error))completion {
    [review.userLikes addObject:profile];
    [review incrementKey:@"likes" byAmount:[NSNumber numberWithInt:1]];
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            completion(error);
        } else if (!succeeded) {
            NSError * customError = [[NSError alloc] initWithDomain:@"CustomError" code:kCustomizedErrorCode userInfo:@{NSLocalizedDescriptionKey : @"Did not like"}];
            completion(customError);
        }
    }];
}

+ (void) removeLikeFromReview: (Review * _Nonnull) review fromUserProfile: (UserProfile * _Nonnull) profile completion: (void (^_Nonnull)(NSError * _Nullable error))completion {
    [review.userLikes removeObject:profile];
    [review incrementKey:@"likes" byAmount:[NSNumber numberWithInt:-1]];

    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            completion(error);
        } else if (!succeeded) {
            NSError * customError = [[NSError alloc] initWithDomain:@"CustomError" code:kCustomizedErrorCode userInfo:@{NSLocalizedDescriptionKey : @"Did not unlike"}];
            completion(customError);
        }
    }];
}
+ (void) isLikedbyUser: (UserProfile * _Nonnull) profile  review:(Review * _Nonnull) review completion: (void (^_Nonnull)(bool liked, NSError * _Nullable error))completion{
    PFRelation * relation = review.userLikes;
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray<UserProfile *> * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            completion(false, error);
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

+ (void) getPlaceDataFromPOI_idStr:(NSString * _Nonnull)POI_idStr withFields: (GMSPlaceField) fields withCompletion: (void (^_Nonnull)(GMSPlace * _Nullable place, NSError * _Nullable error)) completion{
    [self initializePlacesClient];
    [placesClient fetchPlaceFromPlaceID:POI_idStr placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"An error occurred %@", [error localizedDescription]);
            completion(nil, error);
            return;
        }
        if (place != nil) {
            completion(place, nil);
        }
    }];

}

@end
