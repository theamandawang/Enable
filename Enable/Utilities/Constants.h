//
//  Constants.h
//  Enable
//
//  Created by Amanda Wang on 8/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Constants : NSObject
FOUNDATION_EXPORT NSString *const kCustomThemeName;
FOUNDATION_EXPORT const int kCustomizedErrorCode;
FOUNDATION_EXPORT const int kQueryLimit;
FOUNDATION_EXPORT const int kMaxRadius;
FOUNDATION_EXPORT const int kMinRadius;
FOUNDATION_EXPORT const int kNoMatchErrorCode;
typedef enum
{
    kNumberProfileSections = 2,
    kProfileSection  = 0,
    kSummarySection = 0,
    kComposeSection = 1,
    kReviewsSection = 2,
    kRowsForNonReviews = 1,
    kNumberReviewSections = 3
} TableViewSections;

FOUNDATION_EXPORT const int kMaxNumberOfImages;
FOUNDATION_EXPORT NSString *const kDarkStatusBar;
FOUNDATION_EXPORT NSString *const kLightStatusBar;
FOUNDATION_EXPORT NSString *const kThemePlistName;
FOUNDATION_EXPORT NSString *const kNSUserDefaultThemeKey;
FOUNDATION_EXPORT NSString *const kThemeNotificationName;





@end

NS_ASSUME_NONNULL_END
