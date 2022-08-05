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
FOUNDATION_EXPORT NSString *const kDefaultThemeName;

FOUNDATION_EXPORT NSString *const kCustomizedErrorDomain;
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

FOUNDATION_EXPORT NSString *const kLocationModelClassName;
FOUNDATION_EXPORT NSString *const kReviewModelClassName;
FOUNDATION_EXPORT NSString *const kUserProfileModelClassName;

FOUNDATION_EXPORT NSString *const kReviewShimmerViewNibName;
FOUNDATION_EXPORT NSString *const kProfileShimmerViewNibName;
FOUNDATION_EXPORT NSString *const kInfoWindowViewNibName;
FOUNDATION_EXPORT NSString *const kResultsViewNibName;
FOUNDATION_EXPORT NSString *const kMapViewNibName;
FOUNDATION_EXPORT NSString *const kReviewTableViewCellNibName;
FOUNDATION_EXPORT NSString *const kReviewTableViewCellReuseID;
FOUNDATION_EXPORT NSString *const kProfileTableViewCellNibName;
FOUNDATION_EXPORT NSString *const kProfileTableViewCellReuseID;
FOUNDATION_EXPORT NSString *const kSummaryTableViewCellReuseID;
FOUNDATION_EXPORT NSString *const kComposeTableViewCellReuseID;

FOUNDATION_EXPORT NSString *const kProfileToReviewSegueName;
FOUNDATION_EXPORT NSString *const kProfileToLoginSegueName;
FOUNDATION_EXPORT NSString *const kHomeToReviewSegueName;
FOUNDATION_EXPORT NSString *const kHomeToProfileSignedInSegueName;
FOUNDATION_EXPORT NSString *const kHomeToProfileSignedOutSegueName;
FOUNDATION_EXPORT NSString *const kReviewToComposeSegueName;
FOUNDATION_EXPORT NSString *const kReviewToLoginSegueName;
FOUNDATION_EXPORT NSString *const kReviewToProfileSegueName;


FOUNDATION_EXPORT NSString *const kDarkStatusBar;
FOUNDATION_EXPORT NSString *const kLightStatusBar;
FOUNDATION_EXPORT NSString *const kThemePlistName;
FOUNDATION_EXPORT NSString *const kNSUserDefaultThemeKey;
FOUNDATION_EXPORT NSString *const kThemeNotificationName;
FOUNDATION_EXPORT NSString *const kStatusBarKey;
FOUNDATION_EXPORT NSString *const kBackgroundKey;
FOUNDATION_EXPORT NSString *const kSecondaryKey;
FOUNDATION_EXPORT NSString *const kAccentKey;
FOUNDATION_EXPORT NSString *const kLabelKey;
FOUNDATION_EXPORT NSString *const kLikeKey;
FOUNDATION_EXPORT NSString *const kStarKey;



FOUNDATION_EXPORT const int kMinBrightness;
FOUNDATION_EXPORT const int kMinContrast;

FOUNDATION_EXPORT NSString *const kLikedImageName;
FOUNDATION_EXPORT NSString *const kUnlikedImageName;
FOUNDATION_EXPORT NSString *const kPlaceholderProfileImageName;
FOUNDATION_EXPORT NSString *const kPlaceholderPhotoImageName;

@end

NS_ASSUME_NONNULL_END
