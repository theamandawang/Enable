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
#import "ErrorHandler.h"

@interface ReviewByLocationViewController () <UITableViewDataSource, UITableViewDelegate, ResultsViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Review *> * reviews;
@property (strong, nonatomic) Location * location;
@property (strong, nonatomic) UserProfile * _Nullable currentProfile;
@end

@implementation ReviewByLocationViewController
const int kNoMatchErrorCode = 101;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.reviews = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"ReviewTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ReviewCell"];
    [self getCurrentUserProfile];
    [self queryForLocationData];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion{
    [ErrorHandler showAlertFromViewController:self title:title message:message completion:completion];
}
- (void) queryForLocationData {
    [Utilities getLocationFromPOI_idStr:self.POI_idStr withCompletion:^(Location * _Nullable location, NSDictionary * _Nullable locationError) {
        if(locationError && ([locationError[@"code"] integerValue] != kNoMatchErrorCode)){
            [ErrorHandler showAlertFromViewController:self title:locationError[@"title"] message:locationError[@"message"] completion:^{
            }];
        } else {
            if(location){
                self.location = location;
                [Utilities getReviewsByLocation:self.location withCompletion:^(NSMutableArray<Review *> * _Nullable reviews, NSDictionary * _Nullable error) {
                    if(error){
                        [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
                        }];
                    } else {
                        self.reviews = reviews;
                        [self.tableView reloadData];
                    }
                }];
            } else {
                GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
                [Utilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withCompletion:^(GMSPlace * _Nullable place, NSDictionary * _Nullable error) {
                    if(error){
                        [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
                        }];
                    } else {
                        self.location = [[Location alloc] initWithClassName:@"Location"];
                        self.location.POI_idStr = self.POI_idStr;
                        self.location.address = [place formattedAddress];
                        self.location.name = [place name];
                        self.location.coordinates = [PFGeoPoint geoPointWithLatitude: [place coordinate].latitude longitude:[place coordinate].longitude];
                        [self.tableView reloadData];
                    }
                }];
            }
        }
    }];
}
- (void) getCurrentUserProfile {
    [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSDictionary * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
            }];
        } else {
            self.currentProfile = profile;
        }
    }];
}

#pragma mark Protocol methods for liking / removing likes
- (void) addLikeFromUserProfile:(UserProfile *)currentProfile review:(Review *)review{
    [Utilities addLikeToReview:review fromUserProfile:currentProfile completion:^(NSDictionary * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
            }];
        }
    }];
    
    // TODO: need to figure out how to sort reviews after liking them. I'm just querying them again, but
    // there should probably be a better way.
    [self queryForLocationData];
}
- (void) removeLikeFromReview:(Review *)review currentUser:(UserProfile *)currentProfile{
    [Utilities removeLikeFromReview:review fromUserProfile:currentProfile completion:^(NSDictionary * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
            }];
        }
    }];
    [self queryForLocationData];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"compose"]){
        ComposeViewController * vc = [segue destinationViewController];
        vc.POI_idStr = self.POI_idStr;
        vc.location = self.location;
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // create a uitableview cell for the regular reviews, the aggregated review, and  the cell that opens the compose view.
    if(indexPath.row == 0){
        SummaryReviewTableViewCell *summaryCell = [self.tableView dequeueReusableCellWithIdentifier:@"SummaryCell"];
        if(self.reviews && self.reviews.count > 0){
            summaryCell.locationNameLabel.text = self.location.name;
        } else {
            summaryCell.locationNameLabel.text = [NSString stringWithFormat:@"%@%@", self.location.name, @" has no reviews yet!"];
        }
        return summaryCell;
    } else if (indexPath.row == 1) {
        UITableViewCell *composeCell = [self.tableView dequeueReusableCellWithIdentifier:@"ComposeCell"];
        return composeCell;
    }
    ReviewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
    cell.resultsView.delegate = self;
    

    //TODO: use sections instead
    //section 1 is summary review
    //section 2 is compose cell
    //section 3 is all the regular reviews
    //if indexPath.section == VARNAME...
    //constants start w/ 'k'
    [Utilities getUserProfileFromID:self.reviews[indexPath.row-2].userProfileID.objectId withCompletion:^(UserProfile * _Nullable profile, NSDictionary * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
            }];
        } else {
            [Utilities isLikedbyUser:self.currentProfile review:self.reviews[indexPath.row - 2] completion:^(bool liked, NSDictionary * _Nullable error) {
                if(error){
                    [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
                    }];
                } else {
                    cell.resultsView.liked = liked;
                    cell.resultsView.currentProfile = self.currentProfile;
                    cell.resultsView.review = self.reviews[indexPath.row - 2];
                    [cell.resultsView presentReview: self.reviews[indexPath.row - 2] byUser: profile];
                }
            }];
            
        }
    }];
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2 + (self.reviews ? self.reviews.count : 0);
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 1){
        if([PFUser currentUser]){
            [self performSegueWithIdentifier:@"compose" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"reviewToLogin" sender:nil];
        }
    }
}

@end
