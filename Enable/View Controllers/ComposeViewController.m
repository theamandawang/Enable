//
//  ComposeViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//
#import "HCSStarRatingView/HCSStarRatingView.h"
#import "ComposeViewController.h"
#import "Review.h"
@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photosImageView;
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
- (void) locationHandlerWithRating : (int) rating title: (NSString *) title description: (NSString *) description completion: (void (^_Nonnull)(void))completion{
    if(!self.locationValid){
        Location *location = [[Location alloc] initWithClassName:@"Location"];
        location.rating = 0;
        location.POI_idStr = self.location.POI_idStr;
        location.coordinates = self.location.coordinates;
        location.name = self.location.name;
        location.address = self.location.address;
        
        [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error){
                if(succeeded){
                    [self postReviewWithLocation:location rating:rating title:title description:description completion:completion];
                }
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    } else {
        [self postReviewWithLocation:self.location rating:rating title:title description:description completion:completion];
    }
}
- (void) postReviewWithLocation:(Location *)location rating: (int) rating title: (NSString *) title description: (NSString *) description completion: (void (^_Nonnull)(void))completion{
    Review *review = [[Review alloc] initWithClassName:@"Review"];
    review.title = title;
    review.reviewText = description;
    review.rating = rating;
    review.locationID = location;
    review.images = nil;
    review.likes = 0;
    review.userID = [PFUser currentUser];
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(!error){
            if(succeeded){
                NSLog(@"successful post");
                completion();
            } else {
                //TODO: implement error check
                NSLog(@"%@", error.localizedDescription);
            }
        }
        else {
            //TODO: implement error check
            NSLog(@"%@", error.localizedDescription);
        }
    }];
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
        [self locationHandlerWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextField.text completion:^{
            //TODO: go back to the reviews screen, not the maps screen.
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    } else {
        //TODO: error handle
        NSLog(@"values need to be fillled");
    }
}
@end
