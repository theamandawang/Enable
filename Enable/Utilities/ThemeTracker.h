//
//  ThemeTracker.h
//  Enable
//
//  Created by Amanda Wang on 7/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ThemeTracker : NSObject
@property (strong, nonatomic) NSString * theme;
@property (strong, nonatomic) NSDictionary * colorSet;
+ (instancetype)sharedTheme;
- (void) updateTheme: (NSString * _Nonnull) theme;
- (void) getTheme;
@end

NS_ASSUME_NONNULL_END
