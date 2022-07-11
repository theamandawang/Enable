//
//  ComposeViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/7/22.
//

#import "ComposeViewController.h"
#import "Review.h"
@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) locationHandler {
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
                    [self postReviewWithLocation:location];
                }
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    } else {
        [self postReviewWithLocation:self.location];
    }
}
- (void) postReviewWithLocation:(Location *)location{
    Review *review = [[Review alloc] initWithClassName:@"Review"];
    review.title = @"my title";
    review.reviewText = @"my text";
    review.rating  = 5;
    review.locationID = location;
    review.images = nil;
    review.likes = 0;
    review.userID = [PFUser currentUser];
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(!error){
            if(succeeded){
                NSLog(@"successful post");
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
    NSLog(@"submitted");
    [self locationHandler];
}
@end
