//
//  ReviewTableViewCell.h
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "ResultsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ResultsView *resultsView;

@end

NS_ASSUME_NONNULL_END
