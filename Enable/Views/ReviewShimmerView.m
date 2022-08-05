//
//  ReviewShimmerView.m
//  Enable
//
//  Created by Amanda Wang on 8/1/22.
//
#import "ReviewShimmerView.h"
#import "Constants.h"

@implementation ReviewShimmerView

- (instancetype) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        return [self initWith:kReviewShimmerViewNibName];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        return [self initWith:kReviewShimmerViewNibName];
    }
    return self;
}

- (void) setup {
    [super setup:self.shimmeringContentView];
}

@end
