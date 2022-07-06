//
//  MapView.m
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import "MapView.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
@implementation MapView{
    GMSMapView *mapView;
    BOOL firstLocationUpdate;
}

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
        [self mapInit];
    }
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self mapInit];
    }
    return self;
}
- (instancetype) mapInit{
    [[NSBundle mainBundle] loadNibNamed: @"MapView" owner: self options:nil];
    [self addSubview: self.contentView];
    self.contentView.frame = self.bounds;
    firstLocationUpdate = NO;
    //default camera value, Sydney, Australia
    GMSCameraPosition *camera = [GMSCameraPosition
                                 cameraWithLatitude:-33.86
                                 longitude:151.20
                                 zoom:6];
    mapView = [GMSMapView mapWithFrame:self.contentView.frame camera:camera];
    mapView.myLocationEnabled = YES;
    
    /*
     https://stackoverflow.com/questions/17366403/gmsmapview-mylocation-not-giving-actual-location
     using KOV method; not CLLocation. CLLocation was not working not sure why.
    */
    if(CLLocationManager.locationServicesEnabled){
        [mapView
                    addObserver:self
                    forKeyPath:@"myLocation"
                    options:NSKeyValueObservingOptionNew
                    context:NULL
        ];
        
    } else {
        NSLog(@"Location issues :((");
    }
    
    [self.contentView addSubview:mapView];

    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (!firstLocationUpdate) {
    // If the first location update has not yet been received, then jump
    firstLocationUpdate = YES;
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
      if(!CLLocationManager.locationServicesEnabled){
          return;
      }
    mapView.camera = [GMSCameraPosition
                      cameraWithTarget:location.coordinate
                      zoom:14];
  }
}
@end
