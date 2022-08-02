//
//  ProfileShimmerView.m
//  Enable
//
//  Created by Amanda Wang on 8/2/22.
//

#import "ProfileShimmerView.h"

@implementation ProfileShimmerView
const NSString * profileNibName = @"ProfileShimmerView";

- (instancetype) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        return [self initWith:profileNibName];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        return [self initWith:profileNibName];
    }
    return self;
}

- (void) setup {
    [super setup:self.shimmeringContentView];
}


@end
