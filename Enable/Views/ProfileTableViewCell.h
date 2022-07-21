//
//  ProfileTableViewCell.h
//  Enable
//
//  Created by Amanda Wang on 7/21/22.
//

#import <UIKit/UIKit.h>
#import "Parse/PFImageView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UITextField *userDisplayNameTextField;

@end

NS_ASSUME_NONNULL_END
