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
//const int kCustomizedErrorCode = 0; // for no user signed in
const int kSummarySection = 0;
const int kComposeSection = 1;
const int kReviewsSection = 2;
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
-(void)willMoveToParentViewController:(UIViewController *)parent {
     [super willMoveToParentViewController:parent];
    if (!parent){
        //TODO: call a delegate method to make homeview controller set it's map center to here.
        NSLog(@"going back to home");
        [self.delegate setGMSCameraCoordinatesWithLatitude:self.location.coordinates.latitude longitude:self.location.coordinates.longitude];
       // The back button was pressed or interactive gesture used
    }
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
        if(error && ([error[@"code"] intValue] != 0)){
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.section == kSummarySection){
        SummaryReviewTableViewCell *summaryCell = [self.tableView dequeueReusableCellWithIdentifier:@"SummaryCell"];
        if(self.reviews && self.reviews.count > 0){
            summaryCell.locationNameLabel.text = self.location.name;
        } else {
            summaryCell.locationNameLabel.text = [NSString stringWithFormat:@"%@%@", self.location.name, @" has no reviews yet!"];
        }
        return summaryCell;
    } else if (indexPath.section == kComposeSection) {
        UITableViewCell *composeCell = [self.tableView dequeueReusableCellWithIdentifier:@"ComposeCell"];
        return composeCell;
    }
    else {
        ReviewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
        cell.resultsView.delegate = self;
        [Utilities getUserProfileFromID:self.reviews[indexPath.row].userProfileID.objectId withCompletion:^(UserProfile * _Nullable profile, NSDictionary * _Nullable error) {
            if(error){
                [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
                }];
            } else {
                [Utilities isLikedbyUser:self.currentProfile review:self.reviews[indexPath.row] completion:^(bool liked, NSDictionary * _Nullable error) {
                    if(error){
                        [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
                        }];
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

@end
