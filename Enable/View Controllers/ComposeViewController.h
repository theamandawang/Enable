//
//  ComposeViewController.h
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "UserProfile.h"
NS_ASSUME_NONNULL_BEGIN

@interface ComposeViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) Location * location;
@property (strong, nonatomic) NSString * POI_idStr;
@end

NS_ASSUME_NONNULL_END
