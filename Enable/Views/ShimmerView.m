//
//  ShimmerView.m
//  Enable
//
//  Created by Amanda Wang on 8/1/22.
//
#import "FBShimmeringView.h"
#import "ShimmerView.h"

@implementation ShimmerView

- (instancetype) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}
- (instancetype) customInit {
    [[NSBundle mainBundle] loadNibNamed: @"ShimmerView" owner: self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
    [self shimmer];
    return self;
}
- (void) shimmer {
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:shimmeringView];
//    shimmeringView.contentView = self.myLabel;
//    shimmeringView.shimmering = YES;
    
//    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.contentView.bounds];
//    [self.contentView addSubview:shimmeringView];
//
//    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
//    loadingLabel.textAlignment = NSTextAlignmentCenter;
//    loadingLabel.text = NSLocalizedString(@"Shimmer", nil);
//    [loadingLabel setBackgroundColor:[UIColor systemRedColor]];
//    shimmeringView.contentView = loadingLabel;
//
//    // Start shimmering.
//    shimmeringView.shimmering = YES;
//
    
    
    
    // Start shimmering.
//    shimmeringView.shimmering = YES;
//    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.bounds];
//    shimmeringView.contentView = self.profilePlaceholder;
//    [self.contentView addSubview:shimmeringView];
////    [shimmeringView.contentView addSubview:self.profilePlaceholder];
////    [shimmeringView.contentView addSubview:self.myLabel];
//    shimmeringView.shimmering = YES;
}
- (void) setSubviewColor:(UIColor *)color {
    for(UIView * v in self.contentView.subviews){
        [v setBackgroundColor:color];
    }
}

@end
