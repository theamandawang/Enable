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
@interface HomeViewController () <GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate, ReviewByLocationViewControllerDelegate, ViewErrorHandle>
@property (weak, nonatomic) IBOutlet MapView *mapView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
@property (strong, nonatomic) NSString * POI_idStr;
@property (strong, nonatomic) NSMutableArray<GMSMarker *> * customMarkers;
@property (strong, nonatomic) GMSProjection * currentProjection;
@end

@implementation HomeViewController
GMSMarker *infoMarker;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.errorDelegate = self;
    self.resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    self.searchController = [[UISearchController alloc]
                                initWithSearchResultsController:self.resultsViewController
                            ];
    self.resultsViewController.delegate = self;
    self.searchController.searchResultsUpdater = self.resultsViewController;

    // TODO: change search controller to using tableview
    [self.searchController setHidesNavigationBarDuringPresentation:NO];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 240, 30)];

    [subView addSubview:self.searchController.searchBar];
    [self.searchController.searchBar sizeToFit];
    [self.view addSubview:subView];

    self.mapView.mapView.delegate = self;
    self.searchController.searchBar.text = @"";
    self.searchController.searchBar.placeholder = @"Search location...";
    [self.mapView.mapView setBounds:self.mapView.bounds];
    
    self.customMarkers = [[NSMutableArray alloc] init];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self viewDidLoad];
}

- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion{
    [ErrorHandler showAlertFromViewController:self title:title message:message completion:completion];
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

    self.searchController.searchBar.text = place.formattedAddress;
    CLLocationCoordinate2D loc = [place coordinate];

    [self.mapView.mapView setCamera:[GMSCameraPosition cameraWithLatitude:loc.latitude longitude:loc.longitude zoom:20]];
}
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    [ErrorHandler showAlertFromViewController:self title:@"Cannot Autocomplete" message:[error description] completion:^{
    }];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{

    GMSVisibleRegion region = mapView.projection.visibleRegion;
    if(self.currentProjection){
        if([self.currentProjection containsCoordinate: region.farRight] && [self.currentProjection containsCoordinate: region.farLeft] && [self.currentProjection containsCoordinate: region.nearRight] && [self.currentProjection containsCoordinate: region.nearLeft]){
            return;
        }
        [self updateLocationMarkersWithProjection:mapView.projection];
    } else {
        [self updateLocationMarkersWithProjection:mapView.projection];
    }
}

- (void) updateLocationMarkersWithProjection: (GMSProjection *) projection {
    self.currentProjection = projection;
    [self.mapView.mapView clear];
    [self.customMarkers removeAllObjects];
    [self showLocationMarkers];
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
                self.customMarkers[i].snippet = [NSString stringWithFormat:@"Average Rating: %0.2f/5", locations[i].rating];
                self.customMarkers[i].appearAnimation = kGMSMarkerAnimationPop;
                self.customMarkers[i].map = self.mapView.mapView;

            }
        }
    }];

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


#pragma mark - ReviewByLocationViewControllerDelegate
- (void)setGMSCameraCoordinatesWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    [self.mapView.mapView setCamera:[GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:14]];
}

@end
