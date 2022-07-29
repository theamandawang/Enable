//
//  SummaryReviewTableViewCell.m
//  Enable
//
//  Created by Amanda Wang on 7/8/22.
//

#import "SummaryReviewTableViewCell.h"
#import "ThemeTracker.h"
@implementation SummaryReviewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(setupTheme)
            name:@"Theme" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void) setupTheme {
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    [self.contentView setBackgroundColor:[UIColor colorNamed: colorSet[@"Background"]]];
    [self.locationNameLabel setTextColor: [UIColor colorNamed: colorSet[@"Label"]]];
    [self.locationRatingLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
}

@end
