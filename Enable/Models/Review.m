//
//  Review.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Review.h"
@implementation Review
    @dynamic userID;
    @dynamic rating;
    @dynamic title;
    @dynamic reviewText;
    @dynamic locationID;
    @dynamic likes;
    @dynamic images;
+ (nonnull NSString *)parseClassName {
    return @"Review";
}

@end
