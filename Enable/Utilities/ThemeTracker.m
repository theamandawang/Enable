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
@property (strong, nonatomic) NSDictionary * cloudThemes;
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
    } else if (self.plist[theme]) {
        [self saveToDefaults: theme dict:nil];
        [self setupColorSetWithColorDict:nil];
    } else {
        NSMutableDictionary * cloudDict = [[NSMutableDictionary alloc] init];
        [self unarchiveColor:cloudDict custom:false];
        if(cloudDict.count > 0){
            [self saveToDefaults: theme dict:nil];
            [self setupColorSetWithColorDict:cloudDict];
        } else {
            theme = kDefaultThemeName;
            dict = nil;
            [self resetToDefault];
        }
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
- (void) getLocalInfo {
    self.theme = [[NSUserDefaults standardUserDefaults] stringForKey: kNSUserDefaultThemeKey];
    self.plist = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: kThemePlistName ofType: @"plist"]];
    if(!self.theme) self.theme = kDefaultThemeName;
    if([self.theme isEqualToString:kCustomThemeName]){
        NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
        [self unarchiveColor:customDict custom:true];
        if(customDict.count > 0){
            [self setupColorSetWithColorDict:customDict];
        } else {
            //custom theme doesn't exist anymore; reset to default!
            [self updateTheme:kDefaultThemeName withColorDict:nil];
            return;
        }
    } else if(self.plist[self.theme]){
        [self setupColorSetWithColorDict:nil];
    } else {
        NSMutableDictionary * cloudDict = [[NSMutableDictionary alloc] init];
        [self unarchiveColor:cloudDict custom:false];
        if(cloudDict.count > 0){
            [self setupColorSetWithColorDict:cloudDict];
        } else {
            //cloud theme doesn't exist anymore; reset to default!
            [self updateTheme:kDefaultThemeName withColorDict:nil];
            return;
        }
    }
}
- (void) getTheme {
    [self getLocalInfo];
    [self sendNotification];
    if([PFUser currentUser]){
        [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
            if(error){
                NSLog(@"Unable to get user theme: %@", error.localizedDescription);
            } else if (profile) {
                if(!profile.theme) profile.theme = kDefaultThemeName;
                if(!profile.customTheme && [profile.theme isEqualToString:kCustomThemeName]){
                    profile.theme = kDefaultThemeName;
                }
                self.theme = profile.theme;
                NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
                if(profile.customTheme){
                    [self loadColorDictFromParse:profile.customTheme to:customDict];
                    [self saveToDefaults: nil dict:customDict];
                }
                if([profile.theme isEqualToString: kCustomThemeName]){
                    [self updateTheme:profile.theme withColorDict: customDict];
                } else if(self.plist[profile.theme]){
                    [self updateTheme:profile.theme withColorDict:nil];
                } else if(![profile.theme isEqualToString:kCustomThemeName]){
                    NSMutableDictionary * cloudDict = [[NSMutableDictionary alloc] init];
                    [self unarchiveColor:cloudDict custom:false];
                    if(cloudDict.count > 0){
                        [self updateTheme:profile.theme withColorDict:nil];
                    } else {
                        [self updateTheme:kDefaultThemeName withColorDict:nil];
                    }
                }
            }
        }];
    }
}
- (void) checkCloudThemes {
    [Utilities getCloudThemesWithCompletion:^(NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> * _Nullable cloudThemes, NSError * _Nullable error) {
        if(cloudThemes){
            NSMutableDictionary * cloudDict = [[NSMutableDictionary alloc] init];
            for (NSString * theme in cloudThemes) {
                NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
                [self loadColorDictFromParse:cloudThemes[theme] to:customDict];
                cloudDict[theme] = [[NSMutableDictionary alloc] init];
                [self archiveFrom:customDict to:cloudDict[theme]];
            }
            [self saveCloudThemesToDefaults:cloudDict];
            self.cloudThemes = cloudDict;
        }
        [self getTheme];
    }];
}

#pragma mark - Helper functions

- (void) selectCustom {
    NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
    [self unarchiveColor:customDict custom:true];
    if(customDict && customDict.count){
        [self updateTheme:kCustomThemeName withColorDict:customDict];
    }
}

- (void) loadColorDictFromParse: (NSDictionary * _Nonnull) profileDict to:(NSMutableDictionary * _Nonnull) customDict {
    for(NSString * str in profileDict){
        if([str isEqualToString:kStatusBarKey]){
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
- (void) resetToDefault {
    [self saveToDefaults:kDefaultThemeName dict:nil];
    [self setupColorSetWithColorDict:nil];
}
- (void) setupColorSetWithColorDict: (NSDictionary * _Nullable) dict {
    NSDictionary * localList = self.plist[self.theme];
    self.colorSet = [[NSMutableDictionary alloc] init];
    if(dict){
        for (NSString * str in dict){
            self.colorSet[str] = dict[str];
        }
    } else {
        for (NSString * str in localList){
            if([str isEqualToString: kStatusBarKey]){
                self.colorSet[str] = localList[str];
                continue;
            }
            self.colorSet[str] = [UIColor colorNamed:localList[str]];

        }
    }
}

#pragma mark - Get Data From NSUserDefaults
- (void) unarchiveColor: (NSMutableDictionary *) dict custom: (bool) custom{
    NSDictionary * temp;
    if(custom){
        temp = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kCustomThemeName];
    } else {
        self.cloudThemes = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kNSUserDefaultCloudThemesKey];
        temp = self.cloudThemes[self.theme];
    }
    [self unarchiveFrom:temp to:dict];
}
- (void) unarchiveFrom: (NSDictionary *) dict to: (NSMutableDictionary *) customDict {
    for(NSString * str in dict){
        if([str isEqualToString: kStatusBarKey]){
            customDict[str] = dict[str];
        } else {
            customDict[str] = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:dict[str] error:nil];
        }
    }
}

- (void) saveToDefaults: (NSString * _Nullable) theme dict: (NSDictionary * _Nullable) dict {
    if(theme){
        [[NSUserDefaults standardUserDefaults] setObject:theme forKey:kNSUserDefaultThemeKey];
    }
    if(dict){
        NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
        [self archiveFrom:dict to:customDict];
        [[NSUserDefaults standardUserDefaults] setObject: customDict forKey:kCustomThemeName];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) saveCloudThemesToDefaults: (NSDictionary * _Nullable) dict {
    [[NSUserDefaults standardUserDefaults] setObject: dict forKey:kNSUserDefaultCloudThemesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) archiveFrom: (NSDictionary *) dict to: (NSMutableDictionary *) customDict {
    for(NSString * str in dict){
        if([str isEqualToString: kStatusBarKey]){
            customDict[str] = dict[str];
        } else {
            customDict[str] = [NSKeyedArchiver archivedDataWithRootObject:dict[str] requiringSecureCoding:NO error:nil];
        }
    }
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
    return self.colorSet[kBackgroundKey];
}
- (UIColor *) getSecondaryColor {
    return self.colorSet[kSecondaryKey];

}
- (UIColor *) getAccentColor {
    return self.colorSet[kAccentKey];

}
- (UIColor *) getLabelColor {
    return self.colorSet[kLabelKey];

}
- (UIColor *) getStarColor {
    return self.colorSet[kStarKey];

}
- (UIColor *) getLikeColor {
    return self.colorSet[kLikeKey];

}
- (NSString *) getStatusBarColor {
    return self.colorSet[kStatusBarKey];
}

- (NSArray *) getCloudThemeNames {
   return self.cloudThemes.allKeys;
}

@end
