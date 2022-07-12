//
//  ReviewByLocationViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "ReviewByLocationViewController.h"
#import "Review.h"
#import "ParseUtilities.h"
#import "ComposeViewController.h"
#import "SummaryReviewTableViewCell.h"
#import "ReviewTableViewCell.h"
#import <GooglePlaces/GooglePlaces.h>
#import "GoogleUtilities.h"

@interface ReviewByLocationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Review *> * reviews;
@property (strong, nonatomic) Location * location;
@end

@implementation ReviewByLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.reviews = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"ReviewTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ReviewCell"];
    [self queryForLocationData];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void) queryForLocationData {
    [ParseUtilities getLocationFromPOI_idStr:self.POI_idStr withCompletion:^(Location * _Nullable location) {
        if(location){
            self.location = location;
            [ParseUtilities getReviewsByLocation:self.location withCompletion:^(NSMutableArray<Review *> * _Nullable reviews) {
                self.reviews = reviews;
                [self.tableView reloadData];
            }];
        } else {
            GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
            [GoogleUtilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withCompletion:^(GMSPlace * _Nullable place) {
                self.location = [[Location alloc] initWithClassName:@"Location"];
                self.location.POI_idStr = self.POI_idStr;
                self.location.address = [place formattedAddress];
                self.location.name = [place name];
                self.location.coordinates = [PFGeoPoint geoPointWithLatitude: [place coordinate].latitude longitude:[place coordinate].longitude];
                [self.tableView reloadData];
            }];
            
        }
    }];
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
    cell.resultsView.reviewID = self.reviews[indexPath.row - 2].objectId;
    cell.resultsView.review = self.reviews[indexPath.row-2];
    [cell.resultsView loadData];

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