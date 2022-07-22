//
//  MapView.m
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import "MapView.h"
#import <CoreLocation/CoreLocation.h>
@interface MapView() <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) CLLocation * _Nullable currentLocation;
@end
@implementation MapView
float preciseLocationZoomLevel = 14;
float approximateLocationZoomLevel = 10;
bool didUpdateInitial = false;

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
    [self setupLocationManager];
    [self setupMap];

    [self.stackView addArrangedSubview:self.mapView];

    return self;
}
- (void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
}

- (void) setupMap {
    // default location
    GMSCameraPosition *camera = [GMSCameraPosition
                                 cameraWithLatitude:-33.86
                                 longitude:151.20
                                 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:self.stackView.frame camera:camera];

    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.padding = UIEdgeInsetsMake(0, 0, 20, 0);
    [self.mapView setMapType:kGMSTypeTerrain];
    if(CLLocationManager.locationServicesEnabled){
        [self.mapView setCamera: [GMSCameraPosition cameraWithLatitude:self.mapView.myLocation.coordinate.latitude longitude:self.mapView.myLocation.coordinate.longitude zoom:14]];
    } else {
        [self.errorDelegate showAlertWithTitle:@"No location access" message:@"Some features of this app will not work." completion:nil];
    }
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if(didUpdateInitial){
        return;
    }
    CLLocation *location = locations.lastObject;
    NSLog(@"MapView Location Manager Location: %@", location);

    float zoomLevel = self.locationManager.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel;
    GMSCameraPosition * camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                           longitude:location.coordinate.longitude
                                                                zoom:zoomLevel];
    [self.mapView setCamera:camera];
    didUpdateInitial = true;
}

// Handle authorization for the location manager.
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager{
    CLAccuracyAuthorization accuracy = manager.accuracyAuthorization;
    switch (accuracy) {
      case CLAccuracyAuthorizationFullAccuracy:
        NSLog(@"Location accuracy is precise.");
        break;
      case CLAccuracyAuthorizationReducedAccuracy:
        NSLog(@"Location accuracy is not precise.");
        break;
    }
    switch(manager.authorizationStatus){
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location access was restricted.");
            break;
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"User denied access to location.");
            // Display the map using the default location.
            GMSCameraPosition *camera = [GMSCameraPosition
                                       cameraWithLatitude:-33.86
                                       longitude:151.20
                                       zoom:6];
            [self.mapView setCamera:camera];
            self.mapView.hidden = NO;
        }
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Location status not determined.");
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Location status is OK.");
    }
}
// Handle location manager errors.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    [self.errorDelegate showAlertWithTitle:@"Location Manager Failed" message:error.localizedDescription completion:nil];
    NSLog(@"Error: %@", error.localizedDescription);
}
@end
