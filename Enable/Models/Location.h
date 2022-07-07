//
//  Location.h
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "Parse/Parse.h"
@interface Location : PFObject<PFSubclassing>

@property float rating;
@property (nonatomic, strong) NSString * _Nonnull POI_idStr;
@property (nonatomic, strong) PFObject * _Nonnull coordinates;
@end