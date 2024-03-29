//
//  ProfileTableViewCell.m
//  Enable
//
//  Created by Amanda Wang on 7/21/22.
//

#import "ProfileTableViewCell.h"
@interface ProfileTableViewCell ()
@property (strong, nonatomic) UITapGestureRecognizer * tapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer * photoTapGestureRecognizer;
@end
@implementation ProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.photoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPhoto)];
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    self.photoTapGestureRecognizer.cancelsTouchesInView = NO;
    [self.userProfileImageView addGestureRecognizer:self.photoTapGestureRecognizer];
    self.userProfileImageView.layer.cornerRadius = 50;
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];    
}
#pragma mark - IBActions / User input
- (void) didTapPhoto {
    [self.delegate didTapPhoto];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) hideKeyboard {
    [self.contentView endEditing:YES];
}
- (IBAction)didTapUpdate:(id)sender {
    [self.delegate didTapUpdate];
}
- (IBAction)didEdit:(id)sender {
    [self.delegate didEdit];
}

@end
