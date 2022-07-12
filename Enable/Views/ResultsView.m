//
//  ResultsView.m
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import "ResultsView.h"
#import "UserProfile.h"
#import "Parse/PFImageView.h"
#import "ParseUtilities.h"
#import "HCSStarRatingView/HCSStarRatingView.h"
@interface ResultsView ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (strong, nonatomic) HCSStarRatingView *starRatingView;

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
    self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    self.starRatingView.maximumValue = 5;
    self.starRatingView.minimumValue = 0;
    self.starRatingView.value = 0;
    self.starRatingView.tintColor = [UIColor systemYellowColor];
    [self.starRatingView setUserInteractionEnabled:NO];
    [self.contentView addSubview:self.starRatingView];

    return self;
}


- (void) loadData {
    if (self.review) {
        [self present:self.review];
    } else if (self.reviewID) {
        // TODO: same issue as map view, don't know how to attach alert onto a view
        [ParseUtilities getReviewFromID:self.reviewID vc: [self nextResponder] withCompletion:^(Review * _Nullable review) {
            self.review = review;
            [self present:self.review];
        }];
    } else {
        // TODO: error handle
        // TODO: same issue as map view, don't know how to attach alert onto a view
        NSLog(@"Fail loadData in ResultsView %@", @"review and reviewID are both undefined");
        
    }
}

- (void) present: (Review * _Nullable) review {
    // TODO: same issue as map view, don't know how to attach alert onto a view
    [ParseUtilities getUserProfileFromID: review.userProfileID.objectId vc: [self nextResponder] withCompletion:^(UserProfile * _Nullable profile) {
                self.titleLabel.text = review.title;
                self.detailsLabel.text = review.reviewText;
                self.starRatingView.value = review.rating;
                self.usernameLabel.text = profile.username;
            }];
}

@end
