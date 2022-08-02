//
//  BaseShimmerView.m
//  Enable
//
//  Created by Amanda Wang on 8/1/22.
//

#import "BaseShimmerView.h"
@implementation BaseShimmerView

- (instancetype) initWith: (NSString *)nibName {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self loadNib:nibName];
    }
    return self;
}

- (instancetype) loadNib: (NSString *)nibName {
    [[NSBundle mainBundle] loadNibNamed: nibName owner: self options:nil];
    return self;
}

- (void) setup: (UIView *)contentView {
    self.baseShimmeringContentView = contentView;
    self.shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectZero];
    self.shimmeringView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.shimmeringView];
    
    [self.shimmeringView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor].active = YES;
    [self.shimmeringView.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor].active = YES;
    [self.shimmeringView.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor].active = YES;
    [self.shimmeringView.safeAreaLayoutGuide.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    self.shimmeringView.contentView = self.baseShimmeringContentView;
    self.shimmeringView.shimmering = YES;
}

- (void) setBG:(UIColor *)backgroundColor FG:(UIColor *)foregroundColor {
    self.baseShimmeringContentView.backgroundColor = backgroundColor;
    for(UIView * v in self.baseShimmeringContentView.subviews){
        [v setBackgroundColor:foregroundColor];
    }
}


@end
