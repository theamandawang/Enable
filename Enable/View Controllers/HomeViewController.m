//
//  HomeViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import "HomeViewController.h"
#import "MapView.h"
#import "ReviewByLocationViewController.h"
#import "Parse/Parse.h"
#import "Location.h"
#import "ProfileViewController.h"
#import "UserProfile.h"
@interface HomeViewController () <GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MapView *mapView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
@property (strong, nonatomic) Location * location;
@property bool locationValid;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonatomic) UserProfile * userProfile;
@end

@implementation HomeViewController
GMSMarker *infoMarker;
NSString *POI_idStr;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getCurrentUserProfileWithCompletion:^{
        self.placesClient = [[GMSPlacesClient alloc] init];
        
        
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
    } ];
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
        vc.location = self.location;
        vc.locationValid = self.locationValid;
        vc.userProfile = self.userProfile;
    }
    if([segue.identifier isEqualToString:@"signedIn"]){
        ProfileViewController* vc = [segue destinationViewController];
        vc.userProfile = self.userProfile;
    }
}

-(void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.searchController setActive:NO];

}

- (void) fillLocationWithName : (NSString *) name placeID: (NSString*) placeID coordinates:(CLLocationCoordinate2D)coordinates{
    self.location = [[Location alloc] initWithClassName:@"Location"];
    self.location.POI_idStr = placeID;
    self.location.name = name;
    self.location.coordinates = [PFGeoPoint geoPointWithLatitude:coordinates.latitude longitude:coordinates.longitude];
    POI_idStr = placeID;

    // Specify the place data types to return.
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress);

    [self.placesClient fetchPlaceFromPlaceID:placeID placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
      if (error != nil) {
        NSLog(@"An error occurred %@", [error localizedDescription]);
        return;
      }
      if (place != nil) {
          self.location.address = [place formattedAddress];
          NSLog(@"%@", [place formattedAddress]);
      }
    }];
}

- (void)mapView:(GMSMapView *)mapView didTapPOIWithPlaceID:(NSString *)placeID
                                      name:(NSString *)name
                                      location:(CLLocationCoordinate2D)location {
    
    
    [self fillLocationWithName:name placeID:placeID coordinates:location];
    
    infoMarker = [GMSMarker markerWithPosition:location];
    infoMarker.snippet = placeID;
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
    NSLog(@"Place attributions %@", place.attributions.string);
    
    
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
- (void) getLocationDataWithCompletion: (void (^_Nonnull)(void))completion{
    PFQuery * query = [PFQuery queryWithClassName:@"Location"];
    query.limit = 1;
    [query whereKey:@"POI_idStr" equalTo:POI_idStr];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable dbLocations, NSError * _Nullable error) {
        if(!error){
            if(dbLocations){
                if(dbLocations.count > 0){
                    self.locationValid = true;
                    self.location = (Location *)dbLocations[0];
                    completion();
                } else {
                    self.locationValid = false;
                    completion();
                }
            } else {
                self.locationValid = false;
                completion();
            }
        } else {
            //TODO: error handle
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    [self getLocationDataWithCompletion:^{
        [self performSegueWithIdentifier:@"review" sender:nil];
    }];
}

- (void) getCurrentUserProfileWithCompletion:(void (^_Nonnull)(void))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
    if(![PFUser currentUser]){
        completion();
        self.userProfile = nil;
        return;
    }
    [query whereKey:@"userID" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable userProfile, NSError * _Nullable error) {
        if(error){
            //TODO: error handle
            NSLog(@"%@", error.localizedDescription);
            completion();
        } else {
            if(userProfile){
                self.userProfile = (UserProfile*)userProfile;
                completion();
            }
            else{
                NSLog(@"no user found!");
                completion();
            }
        }
    }];
}

@end
