//
//  ThemeTracker.m
//  Enable
//
//  Created by Amanda Wang on 7/27/22.
//

#import "ThemeTracker.h"
#import "Utilities.h"
#import "Constants.h"
@interface ThemeTracker ()
@property (strong, nonatomic) NSMutableDictionary * colorSet;
@property (strong, nonatomic) NSDictionary * customTheme;
@property (strong, nonatomic) NSDictionary * plist;
@end
@implementation ThemeTracker
+ (instancetype)sharedTheme {
    static ThemeTracker *globalTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalTheme = [[self alloc] init];
    });
    return globalTheme;
}
- (void) updateTheme: (NSString * _Nonnull) theme withColorDict: (NSMutableDictionary * _Nullable) dict {
    self.theme = theme;
    if ([theme isEqualToString:kCustomThemeName] && dict){
        [self saveToDefaults:theme dict:dict];
        [self setupColorSetWithColorDict:dict];
    } else {
        [self saveToDefaults: theme dict:nil];
        [self setupColorSetWithColorDict:nil];
    }
    [self sendNotification];
    if([PFUser currentUser]){
        [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
            if(error){
                NSLog(@"Unable to update user theme: couldn't get user profile");
            } else if (profile){
                [Utilities updateUserProfile:profile withTheme:theme withCustom: dict withCompletion:^(NSError * _Nullable updateError) {
                    if(updateError){
                        NSLog(@"Unable to update user theme: %@", updateError.localizedDescription);
                    }
                }];
            }
        }];
    }
}

- (void) getTheme {
    self.theme = [[NSUserDefaults standardUserDefaults] stringForKey: kNSUserDefaultThemeKey];
    if(!self.theme) self.theme = @"Default";
    if([self.theme isEqualToString:kCustomThemeName]){
        NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
        [self unarchiveColor: customDict];
        if(customDict.count > 0){
            [self setupColorSetWithColorDict:customDict];
        } else {
            //custom theme doesn't exist anymore; reset to default!
            [self updateTheme:@"Default" withColorDict:nil];
        }
    } else {
        [self setupColorSetWithColorDict:nil];
    }
    [self sendNotification];
    if([PFUser currentUser]){
        [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
            if(error){
                NSLog(@"Unable to get user theme: %@", error.localizedDescription);
            } else if (profile) {
                if(!profile.theme) profile.theme = @"Default";
                self.theme = profile.theme;
                if(profile.customTheme){
                    NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
                    [self loadColorDictFromParse:profile.customTheme to:customDict];
                    [self saveToDefaults: profile.theme dict:customDict];
                    [self setupColorSetWithColorDict:customDict];
                } else {
                    [self saveToDefaults: profile.theme dict:nil];
                    [self setupColorSetWithColorDict:nil];
                }
                [self sendNotification];

            }
        }];
    }
}
#pragma mark - Helper functions

- (void) selectCustom {
    NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
    [self unarchiveColor:customDict];
    if(!customDict || !customDict.count){
        //if there is no custom theme, do nothing
    } else {
        [self updateTheme:kCustomThemeName withColorDict:customDict];
    }
}

- (void) loadColorDictFromParse: (NSDictionary * _Nonnull) profileDict to:(NSMutableDictionary * _Nonnull) customDict {
    for(NSString * str in profileDict){
        if([str isEqualToString:@"StatusBar"]){
            customDict[str] = profileDict[str];
            continue;
        }
        unsigned int color = 0;
        [[NSScanner scannerWithString:profileDict[str]] scanHexInt:&color];
        float r = (color & 0xFF0000) >> 16;
        float g = (color & 0x00FF00) >> 8;
        float b = color & 0x0000FF;
        customDict[str] = [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:1.0];
    }
}

- (void) setupColorSetWithColorDict: (NSDictionary * _Nullable) dict {
    self.plist = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: kThemePlistName ofType: @"plist"]][self.theme];
    self.colorSet = [[NSMutableDictionary alloc] init];
    if([self.theme isEqualToString:kCustomThemeName]){
        for (NSString * str in dict){
            self.colorSet[str] = dict[str];
        }
    } else {
        for (NSString * str in self.plist){
            if([str isEqualToString:@"StatusBar"]){
                self.colorSet[str] = self.plist[str];
                continue;
            }
            self.colorSet[str] = [UIColor colorNamed:self.plist[str]];
        }
    }
}

#pragma mark - Get Data From NSUserDefaults
- (void) unarchiveColor: (NSMutableDictionary *) dict{
    NSDictionary * temp = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kCustomThemeName];
    for(NSString * str in temp){
        if([str isEqualToString:@"StatusBar"]){
            dict[str] = temp[str];
        } else {
            dict[str] = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:temp[str] error:nil];
        }
    }
}

- (void) saveToDefaults: (NSString * _Nonnull) theme dict: (NSDictionary * _Nullable) dict {
    [[NSUserDefaults standardUserDefaults] setObject:theme forKey:kNSUserDefaultThemeKey];
    if(dict){
        NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
        for(NSString * str in dict){
            if([str isEqualToString:@"StatusBar"]){
                customDict[str] = dict[str];
            } else {
                customDict[str] = [NSKeyedArchiver archivedDataWithRootObject:dict[str] requiringSecureCoding:NO error:nil];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject: customDict forKey:kCustomThemeName];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) removeCustomTheme {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCustomThemeName];
    if([self.theme isEqualToString: kCustomThemeName]){
        [self getTheme];
    }
}

#pragma mark - Notification

- (void) sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName: kThemeNotificationName object:nil];
}


#pragma mark - Get Functions
- (NSDictionary * _Nullable) getCustomTheme {
    if([self.theme isEqualToString:kCustomThemeName]){
        return self.colorSet;
    }
    return nil;
}
- (UIColor *) getBackgroundColor {
    return self.colorSet[@"Background"];
}
- (UIColor *) getSecondaryColor {
    return self.colorSet[@"Secondary"];

}
- (UIColor *) getAccentColor {
    return self.colorSet[@"Accent"];

}
- (UIColor *) getLabelColor {
    return self.colorSet[@"Label"];

}
- (UIColor *) getStarColor {
    return self.colorSet[@"Star"];

}
- (UIColor *) getLikeColor {
    return self.colorSet[@"Like"];

}
- (NSString *) getStatusBarColor {
    return self.colorSet[@"StatusBar"];
}

@end
