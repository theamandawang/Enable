//
//  ThemeTracker.m
//  Enable
//
//  Created by Amanda Wang on 7/27/22.
//

#import "ThemeTracker.h"
#import "Parse/Parse.h"
#import "Utilities.h"
@implementation ThemeTracker
+ (instancetype)sharedTheme {
    static ThemeTracker *globalTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalTheme = [[self alloc] init];
    });
    return globalTheme;
}
//TODO: update user for custom theme
- (void) updateTheme: (NSString * _Nonnull) theme withColorDict: (NSMutableDictionary * _Nullable) dict {
    self.theme = theme;
    [self saveToDefaults: theme dict:dict];
    NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
    if(dict) {
        [self unarchiveColor:customDict];
    }
    [self setupColorSetWithColorDict:customDict];
    [self sendNotification];
    if([PFUser currentUser]){
        [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
            if(error){
                // TODO: how to handle error?
            } else if (profile){
                [Utilities updateUserProfile:profile withTheme:theme withCompletion:^(NSError * _Nullable updateError) {
                    if(updateError){
                        // TODO: how to handle error?
                    }
                }];
            }
        }];
    }
}

- (void) getTheme {
    self.theme = [[NSUserDefaults standardUserDefaults] stringForKey:@"theme"];
    NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
    [self unarchiveColor: customDict];
    if(!self.theme) self.theme = @"Default";
    [self setupColorSetWithColorDict:customDict];
    [self sendNotification];
    if([PFUser currentUser]){
        [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
            if(error){
                // TODO: how to handle error?
            } else if (profile) {
                if(!profile.theme) profile.theme = @"Default";
                
                self.theme = profile.theme;
                [self setupColorSetWithColorDict:profile.customTheme];
               
                [self saveToDefaults: profile.theme dict:profile.customTheme];
                [self sendNotification];

            }
        }];
    }
}

- (void) unarchiveColor: (NSMutableDictionary *) dict{
    NSDictionary * temp = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Custom"];
    for(NSString * str in temp){
        if([str isEqualToString:@"StatusBar"]){
            dict[str] = temp[str];
            continue;
        }
        dict[str] = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:temp[str] error:nil];
    }
}

- (void) saveToDefaults: (NSString * _Nonnull) theme dict: (NSDictionary * _Nullable) dict {
    [[NSUserDefaults standardUserDefaults] setObject:theme forKey:@"theme"];
    if([theme isEqualToString:@"Custom"]){
        NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
        for(NSString * str in dict){
            if([str isEqualToString:@"StatusBar"]){
                customDict[str] = dict[str];
            } else {
                customDict[str] = [NSKeyedArchiver archivedDataWithRootObject:dict[str] requiringSecureCoding:NO error:nil];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject: customDict forKey:@"Custom"];

    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Theme" object:nil];
}

- (void) setupColorSetWithColorDict: (NSDictionary * _Nullable) dict {
    self.plist = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Themes" ofType: @"plist"]][self.theme];
    self.colorSet = [[NSMutableDictionary alloc] init];
    if([self.theme isEqualToString:@"Custom"]){
        for (NSString * str in dict){
            self.colorSet[str] = dict[str];
        }
    } else {
        for (NSString * str in self.plist){
            self.colorSet[str] = [UIColor colorNamed:self.plist[str]];
        }
    }
}

@end
