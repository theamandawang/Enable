//
//  ReviewByLocationViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "ReviewByLocationViewController.h"
#import "Review.h"
#import "UserProfile.h"
#import "Utilities.h"
#import "ComposeViewController.h"
#import "SummaryReviewTableViewCell.h"
#import "ReviewTableViewCell.h"
#import <GooglePlaces/GooglePlaces.h>

@interface ReviewByLocationViewController () <UITableViewDataSource, UITableViewDelegate, ResultsViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray<Review *> * reviews;
@property (strong, nonatomic) Location * location;
@property (strong, nonatomic) UserProfile * _Nullable currentProfile;
@end

@implementation ReviewByLocationViewController
const int kNoMatchErrorCode = 101;
const int kSummarySection = 0;
const int kComposeSection = 1;
const int kReviewsSection = 2;

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.reviews = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"ReviewTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ReviewCell"];
    [self getCurrentUserProfile];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.refreshControl addTarget:self action:@selector(queryForLocationData) forControlEvents:UIControlEventValueChanged];
    [self queryForLocationData];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self testInternetConnection];
    [self queryForLocationData];

}
- (void) willMoveToParentViewController:(UIViewController *)parent {
     [super willMoveToParentViewController:parent];
    if (!parent){
        // recenters camera to the current location
        [self.delegate setGMSCameraCoordinatesWithLatitude:self.location.coordinates.latitude longitude:self.location.coordinates.longitude];
    }
}

#pragma mark - ResultsViewDelegate

- (void) addLikeFromUserProfile:(UserProfile *)currentProfile review:(Review *)review{
    [Utilities addLikeToReview:review fromUserProfile:currentProfile completion:^(NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to like" message:error.localizedDescription completion:nil];
        }
    }];
}
- (void) removeLikeFromReview:(Review *)review currentUser:(UserProfile *)currentProfile{
    [Utilities removeLikeFromReview:review fromUserProfile:currentProfile completion:^(NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to unlike" message:error.localizedDescription completion:nil];
        }
    }];
}
- (void) toLogin{
    [self performSegueWithIdentifier:@"reviewToLogin" sender:nil];
}


#pragma mark - Queries
- (void) queryForLocationData {
    [self startLoading];
    [Utilities getLocationFromPOI_idStr:self.POI_idStr withCompletion:^(Location * _Nullable location, NSError * _Nullable locationError) {
        if(locationError && (locationError.code != kNoMatchErrorCode)){
            [self showAlert:@"Failed to get location" message:locationError.localizedDescription completion:nil];
            [self finishLoading];
        } else {
            if(location){
                self.location = location;
                [Utilities getReviewsByLocation:self.location withCompletion:^(NSMutableArray<Review *> * _Nullable reviews, NSError * _Nullable error) {
                    if(error){
                        [self showAlert:@"Failed to get reviews" message:error.localizedDescription completion:nil];
                    } else {
                        self.reviews = reviews;
                        [self.tableView reloadData];
                        [self.tableView sizeToFit];

                    }
                }];
                [self finishLoading];
            } else {
                GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
                [Utilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withCompletion:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
                    if(error){
                        [self showAlert:@"Failed to get Place data" message:error.localizedDescription completion:nil];
                    } else {
                        self.location = [[Location alloc] initWithClassName:@"Location"];
                        self.location.POI_idStr = self.POI_idStr;
                        self.location.address = [place formattedAddress];
                        self.location.name = [place name];
                        self.location.coordinates = [PFGeoPoint geoPointWithLatitude: [place coordinate].latitude longitude:[place coordinate].longitude];
                        [self.tableView reloadData];
                        [self.tableView sizeToFit];

                    }
                    [self finishLoading];
                }];
            }
        }
    }];
}
- (void) getCurrentUserProfile {
    [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
        if(error && (error.code != 0)){
            [self showAlert:@"Failed to get current user" message:error.localizedDescription completion:nil];
        } else {
            self.currentProfile = profile;
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"compose"]){
        ComposeViewController * vc = [segue destinationViewController];
        vc.POI_idStr = self.POI_idStr;
        vc.location = self.location;
    }
}

# pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.section == kSummarySection){
        SummaryReviewTableViewCell *summaryCell = [self.tableView dequeueReusableCellWithIdentifier:@"SummaryCell"];
        summaryCell.locationNameLabel.text = self.location.name;
        if(self.reviews && self.reviews.count > 0){
            summaryCell.locationRatingLabel.text = [NSString stringWithFormat: @"%0.2f/5 stars!", self.location.rating];
        } else {
            summaryCell.locationRatingLabel.text = @"No reviews yet!";
        }
        return summaryCell;
    } else if (indexPath.section == kComposeSection) {
        UITableViewCell *composeCell = [self.tableView dequeueReusableCellWithIdentifier:@"ComposeCell"];
        return composeCell;
    }
    else {
        ReviewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
        cell.resultsView.delegate = self;
        [Utilities getUserProfileFromID:self.reviews[indexPath.row].userProfileID.objectId withCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
            if(error){
                [self showAlert:@"Failed to get user" message:error.localizedDescription completion:nil];
            } else {
                [Utilities isLikedbyUser:self.currentProfile review:self.reviews[indexPath.row] completion:^(bool liked, NSError * _Nullable error) {
                    if(error){
                        [self showAlert:@"Failed to check likes" message:error.localizedDescription completion:nil];
                    } else {
                        cell.resultsView.liked = liked;
                        cell.resultsView.currentProfile = self.currentProfile;
                        cell.resultsView.review = self.reviews[indexPath.row];
                        [cell.resultsView presentReview: self.reviews[indexPath.row] byUser: profile];
                    }
                }];

            }
        }];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case kSummarySection: return 1;
        case kComposeSection: return 1;
        default: return self.reviews.count;
    }
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == kComposeSection){
        if([PFUser currentUser]){
            [self performSegueWithIdentifier:@"compose" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"reviewToLogin" sender:nil];
        }
    }
}


#pragma mark - Private functions
- (void) finishLoading {
    [self endLoading];
    [self.refreshControl endRefreshing];
}

@end
