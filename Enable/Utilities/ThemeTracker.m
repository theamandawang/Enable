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

- (void) updateTheme: (NSString * _Nonnull) theme {
    self.theme = theme;
    [[NSUserDefaults standardUserDefaults] setObject:theme forKey:@"theme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.colorSet = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Themes" ofType: @"plist"]][self.theme];
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
    if(!self.theme) self.theme = @"Default";
    self.colorSet = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Themes" ofType: @"plist"]][self.theme];
    [self sendNotification];
    if([PFUser currentUser]){
        [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
            if(error){
                // TODO: how to handle error?
            } else if (profile) {
                if(!profile.theme) profile.theme = @"Default";
                self.theme = profile.theme;
                self.colorSet = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Themes" ofType: @"plist"]][self.theme];
                [[NSUserDefaults standardUserDefaults] setObject:self.theme forKey:@"theme"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self sendNotification];

            }
        }];
    }
}
- (void) sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Theme" object:nil];
}

@end
