//
//  ShimmerView.m
//  Enable
//
//  Created by Amanda Wang on 8/1/22.
//
#import "ShimmerView.h"

@implementation BaseShimmerView: UIView

- (instancetype) initWith: (NSString *)nibName {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self loadNib:nibName];
    }
    self.backgroundColor = UIColor.whiteColor;
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
    
    [self.shimmeringView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.shimmeringView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.shimmeringView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.shimmeringView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    self.shimmeringView.contentView = self.baseShimmeringContentView;
    self.shimmeringView.shimmering = YES;
}

- (void) set:(UIColor *)bacgroundColor and:(UIColor *)foregroundColor {
    self.baseShimmeringContentView.backgroundColor = bacgroundColor;
    for(UIView * v in self.baseShimmeringContentView.subviews){
        [v setBackgroundColor:foregroundColor];
    }
}

@end

@implementation ShimmerView

- (instancetype) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        return [self initWith:@"ShimmerView"];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        return [self initWith:@"ShimmerView"];
    }
    return self;
}

- (void) setup {
    [super setup:self.shimmeringContentView];
}

@end
