//
//  CloudThemes.m
//  Enable
//
//  Created by Amanda Wang on 8/5/22.
//

#import <Foundation/Foundation.h>
#import "CloudThemes.h"
#import "Constants.h"

@implementation CloudThemes

    @dynamic themes;

+ (nonnull NSString *)parseClassName {
    return kCloudThemesModelClassName;
}
@end
