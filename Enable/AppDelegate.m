//
//  AppDelegate.m
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "ThemeTracker.h"
@import GoogleMaps;
@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate
NSString *path;
NSDictionary *dict;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    dict = [NSDictionary dictionaryWithContentsOfFile: path];
    [[ThemeTracker sharedTheme] getTheme];
    [self setUpParse];
    [self setUpGoogleMaps];
    return YES;
}
-(void)setUpParse{
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        NSDictionary *back4AppKeys = [dict objectForKey:@"Back4App"];
        configuration.applicationId = [back4AppKeys objectForKey:@"APP_KEY"];
        configuration.clientKey = [back4AppKeys objectForKey:@"CLIENT_KEY"];
        configuration.server = @"https://parseapi.back4app.com/";
    }]];
}
-(void)setUpGoogleMaps{
    [GMSServices provideAPIKey:[dict objectForKey:@"MAP_KEY"]];
    [GMSPlacesClient provideAPIKey:[dict objectForKey:@"MAP_KEY"]];
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
