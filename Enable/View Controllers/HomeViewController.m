//
//  HomeViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import "HomeViewController.h"
#import "MapView.h"
#import "Location.h"
#import "ProfileViewController.h"
#import "Utilities.h"
#import "ErrorHandler.h"
#import "InfoWindowView.h"
@interface HomeViewController () <GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate, ReviewByLocationViewControllerDelegate, ViewErrorHandle>
@property (weak, nonatomic) IBOutlet MapView *mapView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
@property (strong, nonatomic) NSString * POI_idStr;
@property (strong, nonatomic) NSMutableArray<GMSMarker *> * customMarkers;
@property (strong, nonatomic) GMSProjection * currentProjection;
@property (strong, nonatomic) InfoWindowView * infoWindowView;
@property double radiusMiles;
@end

@implementation HomeViewController
GMSMarker *infoMarker;
- (void)viewDidLoad {
    [super viewDidLoad];
    [ErrorHandler testInternetConnection:self];
    self.mapView.errorDelegate = self;
    self.mapView.mapView.delegate = self;
    [self setUpSearch];
    [self.mapView.mapView setBounds:self.mapView.bounds];
    self.customMarkers = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self viewDidLoad];
}

- (void) setUpSearch {
    self.resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    self.searchController = [[UISearchController alloc]
                                initWithSearchResultsController:self.resultsViewController
                            ];
    self.resultsViewController.delegate = self;
    self.searchController.searchResultsUpdater = self.resultsViewController;
    [self.searchController setHidesNavigationBarDuringPresentation:NO];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectZero];
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subView];
    [subView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:0].active = YES;
    [subView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:0].active = YES;
    [subView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:0].active = YES;
    [subView.heightAnchor constraintEqualToConstant:50].active = YES;
    [subView.bottomAnchor constraintEqualToAnchor:self.mapView.topAnchor constant:0].active = YES;
    
    [subView addSubview:self.searchController.searchBar];
    [self.searchController.searchBar sizeToFit];

    self.searchController.searchBar.text = @"";
    self.searchController.searchBar.placeholder = @"Search location...";
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"review"]){
        ReviewByLocationViewController* vc = [segue destinationViewController];
        vc.delegate = self;
        vc.POI_idStr = self.POI_idStr;
    }
}
#pragma mark - Google Maps
-(void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.searchController setActive:NO];

}

- (void)mapView:(GMSMapView *)mapView didTapPOIWithPlaceID:(NSString *)placeID
                                      name:(NSString *)name
                                      location:(CLLocationCoordinate2D)location {

    infoMarker = [GMSMarker markerWithPosition:location];
    [Utilities getLocationFromPOI_idStr:placeID withCompletion:^(Location * _Nullable location, NSDictionary * _Nullable error) {
        if(location){
            infoMarker.snippet = [NSString stringWithFormat:@"Average Rating: %0.2f/5", location.rating];
        } else {
            infoMarker.snippet = @"No reviews yet!";
        }
    }];
    self.POI_idStr = placeID;
    infoMarker.title = name;
    infoMarker.opacity = 0;
    CGPoint pos = infoMarker.infoWindowAnchor;
    pos.y = 1;
    infoMarker.infoWindowAnchor = pos;
    infoMarker.map = mapView;
    mapView.selectedMarker = infoMarker;
}

- (void)resultsController:(nonnull GMSAutocompleteResultsViewController *)resultsController didAutocompleteWithPlace:(nonnull GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);

    self.searchController.searchBar.text = [place name];
    CLLocationCoordinate2D loc = [place coordinate];
    [self.mapView.mapView setCamera:[GMSCameraPosition cameraWithLatitude:loc.latitude longitude:loc.longitude zoom:16]];
}
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    [ErrorHandler showAlertFromViewController:self title:@"Cannot Autocomplete" message:[error description] completion:^{
    }];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{

    GMSVisibleRegion region = mapView.projection.visibleRegion;
    PFGeoPoint * farRightCorner = [PFGeoPoint geoPointWithLatitude:region.farRight.latitude longitude:region.farRight.longitude];
    PFGeoPoint * point = [PFGeoPoint geoPointWithLatitude:position.target.latitude longitude:position.target.longitude];
    double radius = [point distanceInMilesTo:farRightCorner];
    if(self.currentProjection && self.radiusMiles){
        if([Utilities shouldUpdateLocation:self.currentProjection currentRegion:region radius:radius prevRadius:self.radiusMiles]){
            [self updateLocationMarkersWithProjection:mapView.projection radius:radius];
        }
    } else {
        [self updateLocationMarkersWithProjection:mapView.projection radius:radius];
    }
}

- (void) updateLocationMarkersWithProjection: (GMSProjection *) projection radius: (double) radius {
    self.radiusMiles = radius;
    self.currentProjection = projection;
    [self.mapView.mapView clear];
    [self.customMarkers removeAllObjects];
    [self showLocationMarkers];
}
// prevents map from centering to tapped marker. prevents constant refresh
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    mapView.selectedMarker = marker;
    return YES;
}

-(void) showLocationMarkers {
    NSLog(@"camera position %f,%f", self.mapView.mapView.camera.target.latitude, self.mapView.mapView.camera.target.longitude);
    [Utilities getLocationsFromLocation:self.mapView.mapView.camera.target corner:self.mapView.mapView.projection.visibleRegion.farRight withCompletion:^(NSArray<Location *> * _Nullable locations, NSDictionary * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
            }];
        }
        else if(locations){
            for(int i = 0; i < locations.count; i++){
                CLLocationCoordinate2D position = CLLocationCoordinate2DMake(locations[i].coordinates.latitude, locations[i].coordinates.longitude);

                [self.customMarkers addObject:[GMSMarker markerWithPosition:position]];
                self.customMarkers[i].title = locations[i].name;
                self.customMarkers[i].userData = locations[i].POI_idStr;
                self.customMarkers[i].snippet = [NSString stringWithFormat:@"%0.2f", locations[i].rating];
                self.customMarkers[i].appearAnimation = kGMSMarkerAnimationPop;
                self.customMarkers[i].map = self.mapView.mapView;

            }
        }
    }];

}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(nonnull GMSMarker *)marker{
    self.infoWindowView = [[InfoWindowView alloc] initWithFrame:CGRectMake(marker.infoWindowAnchor.x, marker.infoWindowAnchor.y + 1, 180, 100)];
    self.infoWindowView.starRatingView.value = [marker.snippet floatValue];
    self.infoWindowView.placeNameLabel.text = marker.title;
    return self.infoWindowView;
}

-(void) didRequestAutocompletePredictionsForResultsController:(GMSAutocompleteResultsViewController *)resultsController{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)didUpdateAutocompletePredictionsForResultsController:
    (GMSAutocompleteResultsViewController *)resultsController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (IBAction)didTapProfile:(id)sender {
    if([PFUser currentUser]){
        [self performSegueWithIdentifier:@"signedIn" sender:nil];
    }
    else {
        [self performSegueWithIdentifier:@"signedOut" sender:nil];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    if(marker.userData){
        self.POI_idStr = marker.userData;
    }
    [self performSegueWithIdentifier:@"review" sender:nil];
}

#pragma mark - ViewErrorHandle
- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion{
    [ErrorHandler showAlertFromViewController:self title:title message:message completion:completion];
}

#pragma mark - ReviewByLocationViewControllerDelegate
- (void)setGMSCameraCoordinatesWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    [self.mapView.mapView setCamera:[GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:14]];
    [self updateLocationMarkersWithProjection:self.mapView.mapView.projection radius:self.radiusMiles];
}

@end
