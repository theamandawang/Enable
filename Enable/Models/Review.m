//
//  Review.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Review.h"
#import "Constants.h"
@implementation Review
    @dynamic userProfileID;
    @dynamic rating;
    @dynamic title;
    @dynamic reviewText;
    @dynamic locationID;
    @dynamic likes;
    @dynamic images;
    @dynamic userLikes;
+ (nonnull NSString *)parseClassName {
    return kReviewModelClassName;
}

@end
