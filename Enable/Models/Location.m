//
//  Location.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Location.h"
@implementation Location
    @dynamic rating;
    @dynamic POI_idStr;
    @dynamic coordinates;
    @dynamic name;
    @dynamic address;
    @dynamic reviews;
+ (nonnull NSString *)parseClassName {
    return @"Location";
}

@end

