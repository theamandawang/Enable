//
//  CloudThemes.h
//  Enable
//
//  Created by Amanda Wang on 8/5/22.
//


#import "Parse/Parse.h"
@interface CloudThemes : PFObject<PFSubclassing>

@property (nonatomic, strong) NSDictionary <NSString *, NSDictionary<NSString *, NSString *> *> * themes;

@end
