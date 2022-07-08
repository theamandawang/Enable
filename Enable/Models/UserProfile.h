//
//  UserProfile.h
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "Parse/Parse.h"
@interface UserProfile : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser * _Nonnull userID;
@property (nonatomic, strong) NSString * _Nonnull email;
@property (nonatomic, strong) NSString * _Nonnull username;
@property (nonatomic, strong) PFFileObject *_Nullable image;
@end
