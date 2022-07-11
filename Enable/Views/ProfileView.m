//
//  ProfileView.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileView.h"
@interface ProfileView()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;

@end
@implementation ProfileView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self profileInit];
    }
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self profileInit];
    }
    return self;
}
- (instancetype) profileInit{
    [[NSBundle mainBundle] loadNibNamed: @"ProfileView" owner: self options:nil];
    [self addSubview: self.contentView];
    self.contentView.frame = self.bounds;
    [self reloadUserData];
    return self;
}
- (void) reloadUserData {
    if(self.userProfile) {
        self.userDisplayNameLabel.text = self.userProfile.username;
    } else {
        NSLog(@"user is null");
    }
}
@end
