//
//  ThemeTracker.h
//  Enable
//
//  Created by Amanda Wang on 7/27/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface ThemeTracker : NSObject
@property (strong, nonatomic) NSString * theme;
+ (instancetype)sharedTheme;
- (void) updateTheme: (NSString * _Nonnull) theme withColorDict: (NSDictionary * _Nullable) dict;
- (void) getTheme;
- (void) removeCustomTheme;
- (void) selectCustom;
- (NSDictionary * _Nullable) getCustomTheme;
- (UIColor *) getBackgroundColor;
- (UIColor *) getSecondaryColor;
- (UIColor *) getAccentColor;
- (UIColor *) getLabelColor;
- (UIColor *) getStarColor;
- (UIColor *) getLikeColor;
- (NSString *) getStatusBarColor;



@end

NS_ASSUME_NONNULL_END
