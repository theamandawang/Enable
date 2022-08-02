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
    [self setupShimmerView];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ReviewCell"];
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
    [self performSegueWithIdentifier:@"reviewToLogin" sender:nil];
}
- (void) toProfile: (id) userProfileID {
    self.userProfileID = userProfileID;
    [self performSegueWithIdentifier:@"reviewToProfile" sender:nil];
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
                            self.location = [[Location alloc] initWithClassName:@"Location"];
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
    if([segue.identifier isEqualToString:@"compose"]){
        ComposeViewController * vc = [segue destinationViewController];
        vc.POI_idStr = self.POI_idStr;
        vc.location = self.location;
    }
    if([segue.identifier isEqualToString:@"reviewToProfile"]){
        ProfileViewController * vc = [segue destinationViewController];
        vc.userProfileID = self.userProfileID;
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
        [self setupSummaryCellTheme:summaryCell];
        return summaryCell;
    } else if (indexPath.section == kComposeSection) {
        ComposeTableViewCell *composeCell = [self.tableView dequeueReusableCellWithIdentifier:@"ComposeCell"];
        [self setupComposeCellTheme : composeCell];
        return composeCell;
    }
    else {
        ReviewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
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
        case kSummarySection: return 1;
        case kComposeSection: return 1;
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
            [self performSegueWithIdentifier:@"compose" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"reviewToLogin" sender:nil];
        }
    }
}


#pragma mark - Setup
- (void) setupTheme {
    [self setupMainTheme];
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    
    [self.shimmerLoadView setBG:[UIColor colorNamed: colorSet[@"Background"]] FG:[UIColor colorNamed: colorSet[@"Secondary"]]];

    [self.refreshControl setTintColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.tableView setBackgroundColor: [UIColor colorNamed: colorSet[@"Background"]]];
    [self.tableView setSeparatorColor:[UIColor colorNamed: colorSet[@"Secondary"]]];
}
- (void) setupResultsViewTheme : (ResultsView * ) view {
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    [view.contentView setBackgroundColor:[UIColor colorNamed: colorSet[@"Background"]]];
    [view.titleLabel setTextColor: [UIColor colorNamed: colorSet[@"Label"]]];
    [view.usernameLabel setTextColor: [UIColor colorNamed: colorSet[@"Label"]]];
    [view.detailsLabel setTextColor: [UIColor colorNamed: colorSet[@"Label"]]];
    [view.likeCountLabel setTextColor: [UIColor colorNamed: colorSet[@"Label"]]];

    [view.starRatingView setTintColor: [UIColor colorNamed: colorSet[@"Star"]]];
    [view.starRatingView setBackgroundColor:[UIColor colorNamed: colorSet[@"Background"]]];
    [view.likeImageView setTintColor:[UIColor colorNamed: colorSet[@"Like"]]];
}
- (void) setupSummaryCellTheme : (SummaryReviewTableViewCell *) cell {
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    [cell.contentView setBackgroundColor:[UIColor colorNamed: colorSet[@"Background"]]];
    [cell.locationNameLabel setTextColor: [UIColor colorNamed: colorSet[@"Label"]]];
    [cell.locationRatingLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
}


- (void) setupComposeCellTheme : (ComposeTableViewCell *) cell {
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    [cell.contentView setBackgroundColor:[UIColor colorNamed: colorSet[@"Background"]]];
    [cell.composeTextField setBackgroundColor: [UIColor colorNamed: colorSet[@"Secondary"]]];
    [cell.composeTextField setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [cell.composeTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Add a review..." attributes:@{NSForegroundColorAttributeName: [UIColor colorNamed: colorSet[@"Label"]]}]];

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
