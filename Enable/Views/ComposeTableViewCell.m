//
//  ComposeTableViewCell.m
//  Enable
//
//  Created by Amanda Wang on 7/29/22.
//

#import "ComposeTableViewCell.h"
#import "ThemeTracker.h"
@interface ComposeTableViewCell ()
@property (weak, nonatomic) IBOutlet UITextField *composeTextField;
@end
@implementation ComposeTableViewCell

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
    [self.composeTextField setBackgroundColor: [UIColor colorNamed: colorSet[@"Secondary"]]];
    [self.composeTextField setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.composeTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Add a review..." attributes:@{NSForegroundColorAttributeName: [UIColor colorNamed: colorSet[@"Label"]]}]];

}

@end
