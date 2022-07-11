//
//  ReviewByLocationViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "ReviewByLocationViewController.h"
#import "Parse/Parse.h"
#import "Review.h"
#import "ComposeViewController.h"
#import "SummaryReviewTableViewCell.h"
@interface ReviewByLocationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Review *> * reviews;

@end

@implementation ReviewByLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.reviews = [[NSMutableArray alloc] init];
    [self fetchData];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void) fetchData {
    if(self.location){
        PFQuery *query = [PFQuery queryWithClassName:@"Review"];
        query.limit = 20;
        [query whereKey:@"locationID" equalTo:self.location];
        [query orderByDescending:@"likes"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if(!error){
                self.reviews = (NSMutableArray<Review *> *)objects;
                [self.tableView reloadData];
            } else {
                //TODO: error handle
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"compose"]){
        ComposeViewController * vc = [segue destinationViewController];
        vc.location = self.location;
        vc.locationValid = self.locationValid;
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // create a uitableview cell for the regular reviews, the aggregated review, and  the cell that opens the compose view.
    if(indexPath.row == 0){
        SummaryReviewTableViewCell *summaryCell = [self.tableView dequeueReusableCellWithIdentifier:@"SummaryCell"];
        if(self.reviews && self.reviews.count > 0){
            summaryCell.locationNameLabel.text = self.location.name;
        } else {
            summaryCell.locationNameLabel.text = @"no reviews yet!";
        }
        return summaryCell;
    }
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];

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
