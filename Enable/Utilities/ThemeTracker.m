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

- (void) updateTheme: (NSString * _Nonnull) theme withColorDict: (NSMutableDictionary * _Nullable) dict {
    self.theme = theme;
    [self saveToDefaults: theme dict:dict];
    NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
    if(dict) {
        NSDictionary * temp = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Custom"];
        for(NSString * str in temp){
            if([str isEqualToString:@"StatusBar"]) continue;
            customDict[str] = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:temp[str] error:nil];
        }
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
    // unarchive dictionary from core data :')
    NSDictionary * temp = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Custom"];
    NSMutableDictionary * customDict = [[NSMutableDictionary alloc] init];
    for(NSString * str in temp){
        if([str isEqualToString:@"StatusBar"]) continue;
        customDict[str] = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:temp[str] error:nil];
    }
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

- (void) saveToDefaults: (NSString * _Nonnull) theme dict: (NSMutableDictionary * _Nullable) dict {
    [[NSUserDefaults standardUserDefaults] setObject:theme forKey:@"theme"];
    if([theme isEqualToString:@"Custom"]){
//        for(NSString * str in dict){
        dict[@"Background"] = [NSKeyedArchiver archivedDataWithRootObject:dict[@"Background"] requiringSecureCoding:NO error:nil];
        dict[@"Secondary"] = [NSKeyedArchiver archivedDataWithRootObject:dict[@"Secondary"] requiringSecureCoding:NO error:nil];
        dict[@"Label"] = [NSKeyedArchiver archivedDataWithRootObject:dict[@"Label"] requiringSecureCoding:NO error:nil];
        dict[@"Accent"] = [NSKeyedArchiver archivedDataWithRootObject:dict[@"Accent"] requiringSecureCoding:NO error:nil];
        dict[@"Like"] = [NSKeyedArchiver archivedDataWithRootObject:dict[@"Like"] requiringSecureCoding:NO error:nil];
        dict[@"Star"] = [NSKeyedArchiver archivedDataWithRootObject:dict[@"Star"] requiringSecureCoding:NO error:nil];
//        }
        [[NSUserDefaults standardUserDefaults] setObject: dict forKey:@"Custom"];

    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Theme" object:nil];
}

- (void) setupColorSetWithColorDict: (NSDictionary * _Nullable) dict {
    //TODO: handle custom
    self.plist = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Themes" ofType: @"plist"]][self.theme];

    if([self.theme isEqualToString:@"Custom"]){
        self.colorSet = [[NSMutableDictionary alloc] init];
        for (NSString * str in dict){
            self.colorSet[str] = dict[str];
        }
    } else {
        self.colorSet = [[NSMutableDictionary alloc] init];

        for (NSString * str in self.plist){
            self.colorSet[str] = [UIColor colorNamed:self.plist[str]];
        }
    }
}

@end
