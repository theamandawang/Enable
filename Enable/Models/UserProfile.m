//
//  UserProfile.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"
#import "Constants.h"
@implementation UserProfile
    
    @dynamic userID;
    @dynamic email;
    @dynamic username;
    @dynamic image;
    @dynamic theme;
    @dynamic customTheme;
    
+ (nonnull NSString *)parseClassName {
    return kUserProfileModelClassName;
}

@end
