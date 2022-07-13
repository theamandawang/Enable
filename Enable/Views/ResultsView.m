//
//  ResultsView.m
//  Enable
//
//  Created by Amanda Wang on 7/11/22.
//

#import "ResultsView.h"
#import "UserProfile.h"
#import "Parse/PFImageView.h"
#import "Utilities.h"
#import "HCSStarRatingView/HCSStarRatingView.h"


@interface ResultsView ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) NSArray<PFFileObject *> * images;

@property (strong, nonatomic) HCSStarRatingView *starRatingView;

@end
@implementation ResultsView
bool liked;
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

//TODO: figure out how to make this async and refactor it.
- (void)loadImage:(NSURL *)imageURL
{
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]
                                        initWithTarget:self
                                        selector:@selector(requestRemoteImage:)
                                        object:imageURL];
    [queue addOperation:operation];
}

- (void)requestRemoteImage:(NSURL *)imageURL
{
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
    UIImage *image = [[UIImage alloc] initWithData:imageData];

    [self performSelectorOnMainThread:@selector(placeImageInUI:) withObject:image waitUntilDone:YES];
}

- (void)placeImageInUI:(UIImage *)image
{
    [self.photosImageView setImage:image];
}

- (void) loadData {
    if (self.review) {
        [self present:self.review];
    } else if (self.reviewID) {
        [Utilities getReviewFromID:self.reviewID withCompletion:^(Review * _Nullable review, NSDictionary * _Nullable error) {
            if(!error){
                self.review = review;
                [self present:self.review];
            } else {
                [self.delegate showAlertWithTitle:error[@"title"] message:error[@"message"] completion:^{
                }];
            }

        }];
    } else {
        [self.delegate showAlertWithTitle:@"Failed to load data" message:@"review and revewID are both undefined" completion:^{
        }];
        NSLog(@"Fail loadData in ResultsView %@", @"review and reviewID are both undefined");

    }
}

- (void) present: (Review * _Nullable) review {
    [Utilities getUserProfileFromID: review.userProfileID.objectId withCompletion:^(UserProfile * _Nullable profile, NSDictionary * _Nullable error) {
        if(error){
            [self.delegate showAlertWithTitle:error[@"title"] message:error[@"message"] completion:^{
            }];
        } else {
            self.titleLabel.text = review.title;
            self.detailsLabel.text = review.reviewText;
            self.starRatingView.value = review.rating;
            self.usernameLabel.text = profile.username;
            self.likeCountLabel.text = [NSString stringWithFormat: @"%u", review.likes];
            if(review.images.count > 0){
                [self loadImage:    [NSURL URLWithString:[review.images[0] valueForKey:@"url"]]];
            }
        }
    }];
}

- (IBAction)didLike:(id)sender {
    if(liked){
        self.likeImageView.image = [UIImage systemImageNamed:@"arrow.up.heart"];
        liked = false;
    } else {
        self.likeImageView.image = [UIImage systemImageNamed:@"arrow.up.heart.fill"];
        liked = true;
    }

}



@end
