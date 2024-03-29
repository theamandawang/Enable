//
//  InfoWindowView.m
//  Enable
//
//  Created by Amanda Wang on 7/20/22.
//
#import "InfoWindowView.h"
#import "ThemeTracker.h"
#import "Constants.h"
@interface InfoWindowView ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@end
@implementation InfoWindowView
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
    [[NSBundle mainBundle] loadNibNamed: kInfoWindowViewNibName owner: self options:nil];
    [self addSubview: self.contentView];
    self.contentView.frame = self.bounds;
    [self setupPlaceNameLabel];
    [self setupStarRatingView];
    [self setupTheme];
    return self;
}

# pragma mark - Setup
- (void) setupTheme {
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [self.contentView setBackgroundColor: [singleton getBackgroundColor]];
    [self.placeNameLabel setTextColor: [singleton getLabelColor]];
    [self.starRatingView setTintColor: [singleton getStarColor]];
    [self.starRatingView setBackgroundColor: [singleton getBackgroundColor]];
}
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
    self.starRatingView.allowsHalfStars = YES;
    self.starRatingView.value = 0;
}

- (void)setupStarRatingViewConstraints {
    // Y
    [self.starRatingView.topAnchor constraintEqualToAnchor: self.placeNameLabel.bottomAnchor constant:10].active = YES;
    [self.starRatingView.heightAnchor constraintEqualToConstant:20].active = YES;
    // X
    [self.starRatingView.centerXAnchor constraintEqualToAnchor: self.contentView.centerXAnchor].active = YES;
    [self.starRatingView.widthAnchor constraintEqualToConstant:80].active = YES;
    [self.starRatingView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10].active = YES;

}

- (void) setupPlaceNameLabel {
    self.placeNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.placeNameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.placeNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self.placeNameLabel setTextAlignment:NSTextAlignmentNatural];
    [self.placeNameLabel setLineBreakMode:NSLineBreakByWordWrapping];

    [self.contentView addSubview:self.placeNameLabel];
    [self.placeNameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10].active = YES;
    [self.placeNameLabel setNumberOfLines:0];

    [self.placeNameLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.placeNameLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor].active = YES;
    self.placeNameLabel.adjustsFontSizeToFitWidth = YES;
    
}

@end
