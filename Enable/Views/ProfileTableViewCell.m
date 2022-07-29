//
//  ProfileTableViewCell.m
//  Enable
//
//  Created by Amanda Wang on 7/21/22.
//

#import "ProfileTableViewCell.h"
#import "ThemeTracker.h"
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
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self setupTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(setupTheme)
            name:@"Theme" object:nil];
    
}

- (void) setupTheme {
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    [self.contentView setBackgroundColor:[UIColor colorNamed: colorSet[@"Background"]]];
    [self.userProfileImageView setTintColor:[UIColor colorNamed: colorSet[@"Accent"]]];
    [self.userDisplayNameTextField setBackgroundColor:[UIColor colorNamed: colorSet[@"Secondary"]]];
    [self.userDisplayNameTextField setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.updateButton setTintColor:[UIColor colorNamed: colorSet[@"Accent"]]];
}
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
