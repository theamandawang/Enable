//
//  HomeViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import "HomeViewController.h"
#import "MapView.h"
#import "ReviewByLocationViewController.h"
#import "Location.h"
#import "ProfileViewController.h"
@interface HomeViewController () <GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MapView *mapView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
@end

@implementation HomeViewController
GMSMarker *infoMarker;
NSString *POI_idStr;

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    self.searchController = [[UISearchController alloc]
                                initWithSearchResultsController:self.resultsViewController
                            ];
    self.resultsViewController.delegate = self;
    self.searchController.searchResultsUpdater = self.resultsViewController;
    
    // search bar covers nav bar; need to constrain somehow
    // TODO: either fix styling or change search controller to using tableview
    [self.searchController setHidesNavigationBarDuringPresentation:NO];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 240, 30)];
    
    [subView addSubview:self.searchController.searchBar];
    [self.searchController.searchBar sizeToFit];
    [self.view addSubview:subView];
    
    self.mapView.mapView.delegate = self;
    self.searchController.searchBar.text = @"";
    self.searchController.searchBar.placeholder = @"Search location...";
    [self.mapView.mapView setBounds:self.mapView.bounds];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self viewDidLoad];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"review"]){
        ReviewByLocationViewController* vc = [segue destinationViewController];
        vc.POI_idStr = POI_idStr;
    }
}

-(void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.searchController setActive:NO];

}

- (void)mapView:(GMSMapView *)mapView didTapPOIWithPlaceID:(NSString *)placeID
                                      name:(NSString *)name
                                      location:(CLLocationCoordinate2D)location {
    
    infoMarker = [GMSMarker markerWithPosition:location];
    infoMarker.snippet = placeID;
    POI_idStr = placeID;
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
  // TODO: handle the error.
  NSLog(@"Error: %@", [error description]);
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
    [self performSegueWithIdentifier:@"review" sender:nil];
}

@end
