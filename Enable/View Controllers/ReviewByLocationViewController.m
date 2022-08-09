//
//  ReviewByLocationViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "ReviewByLocationViewController.h"
#import "Review.h"
#import "UserProfile.h"
#import "ComposeViewController.h"
#import "ComposeTableViewCell.h"
#import "SummaryReviewTableViewCell.h"
#import "ReviewTableViewCell.h"
#import "ReviewShimmerView.h"
#import "ProfileViewController.h"
#import <GooglePlaces/GooglePlaces.h>

@interface ReviewByLocationViewController () <UITableViewDataSource, UITableViewDelegate, ResultsViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray<Review *> * reviews;
@property (strong, nonatomic) Location * location;
@property (strong, nonatomic) UserProfile * _Nullable currentProfile;
@property (strong, nonatomic) id userProfileID;
@property (strong, nonatomic) ReviewShimmerView * shimmerLoadView;
@end

@implementation ReviewByLocationViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.reviews = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:kReviewTableViewCellNibName bundle:nil];
    [self setupShimmerView];
    [self.tableView registerNib:nib forCellReuseIdentifier:kReviewTableViewCellReuseID];
    [self getCurrentUserProfile];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.refreshControl addTarget:self action:@selector(queryForLocationData) forControlEvents:UIControlEventValueChanged];
    [self setupTheme];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self testInternetConnection];
    [self setupTheme];
    [self queryForLocationData];

}
- (void) willMoveToParentViewController:(UIViewController *)parent {
     [super willMoveToParentViewController:parent];
    if (!parent){
        // recenters camera to the current location
        [self.delegate setGMSCameraCoordinatesWithLatitude:self.location.coordinates.latitude longitude:self.location.coordinates.longitude];
    }
}

#pragma mark - Override

- (void) startLoading {
    [self.shimmerLoadView setHidden:NO];
    [self.tableView setHidden:YES];
}

- (void) endLoading {
    [self.tableView setHidden:NO];
    [self.shimmerLoadView setHidden:YES];
    [self.refreshControl endRefreshing];
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
    [self performSegueWithIdentifier: kReviewToLoginSegueName sender:nil];
}
- (void) toProfile: (id) userProfileID {
    self.userProfileID = userProfileID;
    [self performSegueWithIdentifier: kReviewToProfileSegueName sender:nil];
}


#pragma mark - Queries

- (void) getReviewsFromLocation: (Location * _Nonnull) location {
    self.location = location;
    [Utilities getReviewsByLocation:self.location withCompletion:^(NSMutableArray<Review *> * _Nullable reviews, NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to get reviews" message:error.localizedDescription completion:nil];
        } else {
            self.reviews = reviews;
            [self.tableView reloadData];
            [self endLoading];
        }
    }];
}
- (void) queryForLocationData {
    [self startLoading];
    if(self.locationID){
        [Utilities getLocationFromID:self.locationID withCompletion:^(Location * _Nullable location, NSError * _Nullable error) {
            if(error){
                [self showAlert:@"Failed to get location" message:error.localizedDescription completion:nil];
            } else if (location){
                [self getReviewsFromLocation : location];
            }
        }];
    } else {
        [Utilities getLocationFromPOI_idStr:self.POI_idStr withCompletion:^(Location * _Nullable location, NSError * _Nullable locationError) {
            if(locationError && (locationError.code != kNoMatchErrorCode)){
                [self showAlert:@"Failed to get location" message:locationError.localizedDescription completion:nil];
                [self endLoading];
            } else {
                if(location){
                    [self getReviewsFromLocation : location];
                } else {
                    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
                    [Utilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withCompletion:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
                        if(error){
                            [self showAlert:@"Failed to get Place data" message:error.localizedDescription completion:nil];
                        } else {
                            self.location = [[Location alloc] initWithClassName: kLocationModelClassName];
                            self.location.POI_idStr = self.POI_idStr;
                            self.location.address = [place formattedAddress];
                            self.location.name = [place name];
                            self.location.coordinates = [PFGeoPoint geoPointWithLatitude: [place coordinate].latitude longitude:[place coordinate].longitude];
                            [self.tableView reloadData];
                        }
                        [self endLoading];

                    }];
                }
            }
        }];
    }
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
    if([segue.identifier isEqualToString: kReviewToComposeSegueName]){
        ComposeViewController * vc = [segue destinationViewController];
        vc.POI_idStr = self.POI_idStr;
        vc.location = self.location;
    }
    if([segue.identifier isEqualToString: kReviewToProfileSegueName]){
        ProfileViewController * vc = [segue destinationViewController];
        vc.userProfileID = self.userProfileID;
    }
}

# pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return kNumberReviewSections;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.section == kSummarySection){
        SummaryReviewTableViewCell *summaryCell = [self.tableView dequeueReusableCellWithIdentifier: kSummaryTableViewCellReuseID];
        summaryCell.locationNameLabel.text = self.location.name;
        if(self.reviews && self.reviews.count > 0){
            summaryCell.locationRatingLabel.text = [NSString stringWithFormat: @"%0.2f/5 stars!", self.location.rating];
        } else {
            summaryCell.locationRatingLabel.text = @"No reviews yet!";
        }
        [self setupSummaryCellTheme:summaryCell];
        return summaryCell;
    } else if (indexPath.section == kComposeSection) {
        ComposeTableViewCell *composeCell = [self.tableView dequeueReusableCellWithIdentifier: kComposeTableViewCellReuseID];
        [self setupComposeCellTheme : composeCell];
        return composeCell;
    }
    else {
        ReviewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kReviewTableViewCellReuseID];
        cell.resultsView.delegate = self;
        [self setupResultsViewTheme:cell.resultsView];
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
        case kSummarySection: return kRowsForNonReviews;
        case kComposeSection: return kRowsForNonReviews;
        default: return self.reviews.count;
    }
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == kSummarySection){
        [self.delegate setGMSCameraCoordinatesWithLatitude:self.location.coordinates.latitude longitude:self.location.coordinates.longitude];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if(indexPath.section == kComposeSection){
        if([PFUser currentUser]){
            [self performSegueWithIdentifier:kReviewToComposeSegueName sender:nil];
        } else {
            [self performSegueWithIdentifier:kReviewToLoginSegueName sender:nil];
        }
    }
}


#pragma mark - Setup
- (void) setupTheme {
    [self setupMainTheme];
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [self.shimmerLoadView setBG: [singleton getBackgroundColor] FG: [singleton getSecondaryColor]];
    [self.refreshControl setTintColor: [singleton getLabelColor]];
    [self.tableView setBackgroundColor: [singleton getBackgroundColor]];
    [self.tableView setSeparatorColor: [singleton getSecondaryColor]];
}
- (void) setupResultsViewTheme : (ResultsView * ) view {
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [view.contentView setBackgroundColor: [singleton getBackgroundColor]];
    [view.titleLabel setTextColor: [singleton getLabelColor]];
    [view.usernameLabel setTextColor: [singleton getLabelColor]];
    [view.detailsLabel setTextColor: [singleton getLabelColor]];
    [view.likeCountLabel setTextColor: [singleton getLabelColor]];
    [view.profileImageView setTintColor: [singleton getAccentColor]];
    [view.starRatingView setTintColor: [singleton getStarColor]];
    [view.starRatingView setBackgroundColor: [singleton getBackgroundColor]];
    [view.likeImageView setTintColor: [singleton getLikeColor]];
}
- (void) setupSummaryCellTheme : (SummaryReviewTableViewCell *) cell {
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [cell.contentView setBackgroundColor: [singleton getBackgroundColor]];
    [cell.locationNameLabel setTextColor: [singleton getLabelColor]];
    [cell.locationRatingLabel setTextColor: [singleton getLabelColor]];
}


- (void) setupComposeCellTheme : (ComposeTableViewCell *) cell {
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [cell.contentView setBackgroundColor: [singleton getBackgroundColor]];
    [cell.composeTextField setBackgroundColor: [singleton getSecondaryColor]];
    [cell.composeTextField setTextColor: [singleton getLabelColor]];
    [cell.composeTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Add a review..." attributes:@{NSForegroundColorAttributeName: [singleton getLabelColor]}]];

}

- (void) setupShimmerView {
    self.shimmerLoadView = [[ReviewShimmerView alloc] init];
    self.shimmerLoadView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.shimmerLoadView];
    [self.shimmerLoadView setHidden:YES];
    [self.shimmerLoadView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.shimmerLoadView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.shimmerLoadView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.shimmerLoadView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;

    [self.shimmerLoadView setup];
}

@end
