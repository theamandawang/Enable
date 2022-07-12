//
//  GoogleUtilities.h
//  Enable
//
//  Created by Amanda Wang on 7/12/22.
//


#import <GooglePlaces/GooglePlaces.h>
#import <UIKit/UIKit.h>

@interface GoogleUtilities : NSObject
+ (void) getPlaceDataFromPOI_idStr:(NSString * _Nonnull)POI_idStr withFields: (GMSPlaceField) fields withVC:(UIViewController* _Nonnull) vc withCompletion: (void (^_Nonnull)(GMSPlace * _Nullable place)) completion;
@end
