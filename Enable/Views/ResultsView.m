//
//  ResultsView.m
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import "ResultsView.h"
#import "UserProfile.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
@interface ResultsView ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleTopToProfileBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleTopToImageBottom;
@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (strong, nonatomic) NSArray<PFFileObject *> * images;
@property int imageIndex;
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
    [self setupStarRatingView];
    return self;
}

- (void) presentReview: (Review * _Nullable) review byUser: (UserProfile * _Nonnull) profile{
    if(review.images.count > 0){
        [self.titleTopToProfileBottom setActive: NO];
        [self.titleTopToImageBottom setActive: YES];
        [self.photosImageView setHidden: NO];
        [self.photosImageView setNeedsLayout];
        [self setCurrentImage:0];
    }
    else {
        [self.titleTopToImageBottom setActive: NO];
        [self.titleTopToProfileBottom setActive: YES];
        [self.photosImageView setHidden: YES];
    }
    self.imageIndex = 0;
    self.titleLabel.text = review.title;
    self.detailsLabel.text = review.reviewText;
    self.starRatingView.value = review.rating;
    self.usernameLabel.text = profile.username;
    self.userProfile = profile;
    self.likeCountLabel.text = [NSString stringWithFormat: @"%d", review.likes];
    if(self.liked){
        self.likeImageView.image = [UIImage systemImageNamed:@"arrow.up.heart.fill"];
    } else {
        self.likeImageView.image = [UIImage systemImageNamed:@"arrow.up.heart"];
    }
    if(profile.image){
        self.profileImageView.file = profile.image;
        [self.profileImageView loadInBackground];
    } else {
        self.profileImageView.image = [UIImage systemImageNamed:@"person.fill"];
    }
    [self layoutIfNeeded];

}

- (void) setCurrentImage: (int) i {
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.review.images[i] valueForKey:@"url"]]];
    [self.photosImageView setImageWithURLRequest:request placeholderImage:[UIImage systemImageNamed:@"photo.on.rectangle.angled"]
        success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                if(image){
                    [UIView transitionWithView:self.photosImageView
                            duration:0.5f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.photosImageView.image = image;
                            }
                            completion:nil
                    ];
                }
        }
        failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                //set loading state
            }
    ];
}



# pragma mark - IBActions

- (IBAction)didSwipeRight:(id)sender {
    if(self.imageIndex > 0){
        self.imageIndex --;
        [self setCurrentImage:self.imageIndex];
    }
}
- (IBAction)didSwipeLeft:(id)sender {
    if(self.imageIndex + 1 < self.review.images.count){
        self.imageIndex ++;
        [self setCurrentImage:self.imageIndex];
    }
}

- (IBAction)didLike:(id)sender {
    if(!self.currentProfile){
        [self.delegate toLogin];
        return;
    }
    if(self.liked){
        self.likeImageView.image = [UIImage systemImageNamed:@"arrow.up.heart"];
        self.liked = false;
        self.likeCountLabel.text = [NSString stringWithFormat:@"%u", self.review.likes - 1];
        [self.delegate removeLikeFromReview:self.review currentUser: self.currentProfile];
    } else {
        self.likeImageView.image = [UIImage systemImageNamed:@"arrow.up.heart.fill"];
        self.liked = true;
        self.likeCountLabel.text = [NSString stringWithFormat:@"%u", self.review.likes + 1];
        [self.delegate addLikeFromUserProfile:self.currentProfile review:self.review];
    }

}
- (IBAction)didTapUser:(id)sender {
    if(self.userProfile){
        [self.delegate toProfile:self.userProfile.objectId];
    }
}

# pragma mark - StarRatingView setup

- (void)setupStarRatingView {
    self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectZero];
    [self setupStarRatingViewValues];
    [self.starRatingView setUserInteractionEnabled:NO];
    self.starRatingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.starRatingView];
    [self setupStarRatingViewConstraints];
}

- (void)setupStarRatingViewValues {
    self.starRatingView.maximumValue = 5;
    self.starRatingView.minimumValue = 0;
    self.starRatingView.value = 0;
}

- (void)setupStarRatingViewConstraints {
    // Y
    [self.starRatingView.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor].active = YES;
    [self.starRatingView.heightAnchor constraintEqualToConstant:50].active = YES;
    // X
    [self.starRatingView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-30].active = YES;
    [self.starRatingView.widthAnchor constraintEqualToConstant:150].active = YES;
}

@end
