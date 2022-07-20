//
//  SummaryReviewTableViewCell.h
//  Enable
//
//  Created by Amanda Wang on 7/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SummaryReviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationRatingLabel;

@end

NS_ASSUME_NONNULL_END
