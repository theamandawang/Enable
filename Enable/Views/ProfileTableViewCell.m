//
//  ProfileTableViewCell.m
//  Enable
//
//  Created by Amanda Wang on 7/21/22.
//

#import "ProfileTableViewCell.h"
@interface ProfileTableViewCell ()
@property (strong, nonatomic) UITapGestureRecognizer * tapGestureRecognizer;
@end
@implementation ProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) hideKeyboard {
    [self.contentView endEditing:YES];
}

@end
