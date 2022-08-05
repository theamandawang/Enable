//
//  Constants.m
//  Enable
//
//  Created by Amanda Wang on 8/4/22.
//

#import "Constants.h"

@implementation Constants

#pragma mark - Error
const int kCustomizedErrorCode = 0;
NSString *const kCustomizedErrorDomain = @"CustomError";

#pragma mark - Utilities constants
const int kQueryLimit = 3;
const int kMaxRadius = 50;
const int kMinRadius = 1;
const int kNoMatchErrorCode = 101;

#pragma mark - ComposeVC constants
const int kMaxNumberOfImages = 3;

#pragma mark - Parse Class Names
NSString *const kLocationModelClassName = @"Location";
NSString *const kReviewModelClassName = @"Review";
NSString *const kUserProfileModelClassName = @"UserProfile";

#pragma mark - NibNames + ReuseIDs

NSString *const kReviewShimmerViewNibName = @"ReviewShimmerView";
NSString *const kProfileShimmerViewNibName = @"ProfileShimmerView";
NSString *const kInfoWindowViewNibName = @"InfoWindowView";
NSString *const kResultsViewNibName = @"ResultsView";
NSString *const kMapViewNibName = @"MapView";
NSString *const kReviewTableViewCellNibName = @"ReviewTableViewCell";
NSString *const kReviewTableViewCellReuseID = @"ReviewCell";
NSString *const kProfileTableViewCellNibName = @"ProfileTableViewCell";
NSString *const kProfileTableViewCellReuseID = @"ProfileCell";
NSString *const kSummaryTableViewCellReuseID = @"SummaryCell";
NSString *const kComposeTableViewCellReuseID = @"ComposeCell";

#pragma mark - Segues

NSString *const kProfileToReviewSegueName = @"profileToReviews";
NSString *const kProfileToLoginSegueName = @"profileToLogin";
NSString *const kHomeToReviewSegueName = @"review";
NSString *const kHomeToProfileSignedInSegueName = @"signedIn";
NSString *const kHomeToProfileSignedOutSegueName = @"signedOut";
NSString *const kReviewToComposeSegueName = @"compose";
NSString *const kReviewToLoginSegueName = @"reviewToLogin";
NSString *const kReviewToProfileSegueName = @"reviewToProfile";

#pragma mark - Themes

NSString *const kDarkStatusBar = @"Dark";
NSString *const kLightStatusBar = @"Light";
NSString *const kThemePlistName = @"Themes";
NSString *const kNSUserDefaultThemeKey = @"theme";
NSString *const kThemeNotificationName = @"Theme";
NSString *const kStatusBarKey = @"StatusBar";
NSString *const kBackgroundKey = @"Background";
NSString *const kSecondaryKey = @"Secondary";
NSString *const kAccentKey = @"Accent";
NSString *const kLabelKey = @"Label";
NSString *const kLikeKey = @"Like";
NSString *const kStarKey = @"Star";

NSString *const kCustomThemeName = @"Custom";
NSString *const kDefaultThemeName = @"Default";

const int kMinBrightness = 125;
const int kMinContrast = 200;

#pragma mark - Image names
NSString *const kLikedImageName = @"arrow.up.heart.fill";
NSString *const kUnlikedImageName = @"arrow.up.heart";
NSString *const kPlaceholderProfileImageName = @"person.fill";
NSString *const kPlaceholderPhotoImageName = @"photo.on.rectangle.angled";

@end
