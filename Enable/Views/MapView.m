//
//  MapView.m
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import "MapView.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation MapView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    [[NSBundle mainBundle] loadNibNamed: @"MapView" owner: self options:nil];
    [self addSubview: self.contentView];
    self.contentView.frame = self.bounds;
    GMSCameraPosition *camera = [GMSCameraPosition
                                 cameraWithLatitude:-33.86
                                 longitude:151.20
                                 zoom:6];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.contentView.frame camera:camera];
    mapView.myLocationEnabled = YES;
    [self.contentView addSubview:mapView];
    return self;
}

@end
