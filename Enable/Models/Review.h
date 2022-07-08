//
//  Review.h
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "Parse/Parse.h"
@interface Review : PFObject<PFSubclassing>

@property (nonatomic, strong) PFUser * _Nonnull userID;
@property int rating;
@property (nonatomic, strong) NSString * _Nonnull title;
@property (nonatomic, strong) NSString * _Nonnull reviewText;
@property (nonatomic, strong) PFObject *_Nonnull locationID;
@property int likes;
@property (nonatomic, strong) NSArray<PFFileObject *> *_Nullable images;
@end
