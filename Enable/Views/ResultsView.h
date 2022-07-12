//
//  ResultsView.h
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Review.h"
NS_ASSUME_NONNULL_BEGIN

@interface ResultsView : UIView
 @property (strong, nonatomic) id reviewID;
@property (strong, nonatomic) Review *review;
-(void) loadData;
@end

NS_ASSUME_NONNULL_END
