//
//  ComposeViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//
#import <GooglePlaces/GooglePlaces.h>
#import "HCSStarRatingView/HCSStarRatingView.h"
#import "ComposeViewController.h"
#import "Parse/PFImageView.h"
#import "GoogleUtilities.h"
#import "ParseUtilities.h"
#import "Review.h"
@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextField;
@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (strong, nonatomic) HCSStarRatingView *starRatingView;
@end

@implementation ComposeViewController

//TODO: automatically scroll up when keyboard opens
//https://stackoverflow.com/questions/13161666/how-do-i-scroll-the-uiscrollview-when-the-keyboard-appears


UITapGestureRecognizer *scrollViewTapGesture;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    scrollViewTapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollViewTapGesture];
    
    
    self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(100, 300, 200, 100)];

    self.starRatingView.maximumValue = 5;
    self.starRatingView.minimumValue = 0;
    self.starRatingView.value = 0;
    self.starRatingView.tintColor = [UIColor systemYellowColor];
//    [self.starRatingView addTarget:self action:@selector(didChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.starRatingView];
}


-(void) getLocationDataWithCompletion: (void (^_Nonnull)(void)) completion {
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
    [GoogleUtilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withCompletion:^(GMSPlace * _Nullable place) {
        self.location = [[Location alloc] initWithClassName:@"Location"];
        self.location.POI_idStr = self.POI_idStr;
        self.location.address = [place formattedAddress];
        self.location.name = [place name];
        self.location.coordinates = [PFGeoPoint geoPointWithLatitude: [place coordinate].latitude longitude:[place coordinate].longitude];
        completion();
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (bool) checkValuesWithRating:(int)rating title:(NSString *)title description:(NSString*) description{
    if(rating && title && description){
        return !([title isEqualToString:@""] || [description isEqualToString:@""]);
    }
    return false;
}

- (void) locationHandlerWithRating : (int) rating title: (NSString *) title description: (NSString *) description didPost: (void (^_Nonnull)(void))didPost{
    
    // TODO: decide whether to fetch location again, i've already done it in the previous vc.
    // I have created an option so that if there is no location provided then I will have it request
    // location on its own, but the default is still probably going to rely on the location already provided.
    if(!self.location){
        [self getLocationDataWithCompletion:^{
            [ParseUtilities postLocationWithPOI_idStr:self.location.POI_idStr coordinates:self.location.coordinates name:self.location.name address:self.location.address completion:^(Location * _Nullable location) {
                [ParseUtilities postReviewWithLocation:location rating:rating title:title description:description completion:didPost];
            }];
        }];
    } else {
        [ParseUtilities postReviewWithLocation:self.location rating:rating title:title description:description completion:didPost];
    }
}

// method to hide keyboard when user taps on a scrollview
-(void)hideKeyboard
{
    [self.scrollView endEditing:YES];
}
- (IBAction)didTapPhoto:(id)sender {
    NSLog(@"tapped photo");
}

- (IBAction)didTapSubmit:(id)sender {
    if([self checkValuesWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextField.text]){
        [self locationHandlerWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextField.text didPost:^{
            //TODO: go back to the reviews screen, not the maps screen.
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    } else {
        //TODO: error handle
        NSLog(@"values need to be filled");
    }
}
@end
