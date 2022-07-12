//
//  GoogleUtilities.m
//  Enable
//
//  Created by Amanda Wang on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "ErrorHandler.h"
#import "GoogleUtilities.h"

@implementation GoogleUtilities

static GMSPlacesClient * placesClient = nil;

+ (void) initializePlacesClient{
    if(!placesClient){
        placesClient = [[GMSPlacesClient alloc] init];
    }
}


+ (void) getPlaceDataFromPOI_idStr:(NSString * _Nonnull)POI_idStr withFields: (GMSPlaceField) fields withVC: (UIViewController * ) vc withCompletion: (void (^_Nonnull)(GMSPlace * _Nullable place)) completion{
    [self initializePlacesClient];
    [placesClient fetchPlaceFromPlaceID:POI_idStr placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"An error occurred %@", [error localizedDescription]);
            [ErrorHandler showAlertFromViewController:vc title:@"Error getting location from Google" message:[error localizedDescription] completion:^{
            }];
            return;
        }
        if (place != nil) {
            completion(place);
        }
    }];
    
}



@end
