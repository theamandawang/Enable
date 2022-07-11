//
//  ResultsView.m
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import "ResultsView.h"
#import "UserProfile.h"
#import "Parse/PFImageView.h"
#import "HCSStarRatingView/HCSStarRatingView.h"
@interface ResultsView ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (strong, nonatomic) HCSStarRatingView *starRatingView;

@property (strong, nonatomic) UserProfile * userProfile;

@end
@implementation ResultsView

- (instancetype) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self customInit];
    }
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self customInit];
    }
    return self;
}
- (instancetype) customInit{
    [[NSBundle mainBundle] loadNibNamed: @"ResultsView" owner: self options:nil];
    [self addSubview: self.contentView];
    self.contentView.frame = self.bounds;
    self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    self.starRatingView.maximumValue = 5;
    self.starRatingView.minimumValue = 0;
    self.starRatingView.value = 0;
    self.starRatingView.tintColor = [UIColor systemYellowColor];
    [self.starRatingView setUserInteractionEnabled:NO];
    [self.contentView addSubview:self.starRatingView];

    return self;
}
- (void) loadData {
    [self getUserProfileFromIDWithCompletion:^{
        self.titleLabel.text = self.review.title;
        self.detailsLabel.text = self.review.reviewText;
        self.starRatingView.value = self.review.rating;
        self.usernameLabel.text = self.userProfile.username;
    }];
    
}
- (void) getUserProfileFromIDWithCompletion: (void (^_Nonnull)(void))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    [query getObjectInBackgroundWithId:self.review.userProfileID.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.userProfile = (UserProfile *) object;
        completion();
    }];
}
@end
