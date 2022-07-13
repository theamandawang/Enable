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
#import "ErrorHandler.h"
#import "Review.h"
@interface ComposeViewController () <UITextViewDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (strong, nonatomic) HCSStarRatingView *starRatingView;
@end

@implementation ComposeViewController
//TODO: add tableview for dropdown.
//TODO: automatically scroll up when keyboard opens
//https://stackoverflow.com/questions/13161666/how-do-i-scroll-the-uiscrollview-when-the-keyboard-appears
// this doesn't seem to be working? not sure what to do.
// when keyboard is already open, and i click the textview, this works really well. but not when i click the textView first.
UITapGestureRecognizer *scrollViewTapGesture;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    scrollViewTapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollViewTapGesture];
    self.reviewTextView.delegate = self;
    [self registerForKeyboardNotifications];
    
    
    
    
    self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(100, 200, 200, 100)];

    self.starRatingView.maximumValue = 5;
    self.starRatingView.minimumValue = 0;
    self.starRatingView.value = 0;
    self.starRatingView.backgroundColor = [UIColor systemBackgroundColor];
    self.starRatingView.tintColor = [UIColor systemYellowColor];
//    [self.starRatingView addTarget:self action:@selector(didChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.starRatingView];
}


-(void) getLocationDataWithCompletion: (void (^_Nonnull)(void)) completion {
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
    [GoogleUtilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withVC: self withCompletion:^(GMSPlace * _Nullable place) {
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

- (void) locationHandlerWithRating : (int) rating title: (NSString *) title description: (NSString *) description didPost: (void (^_Nonnull)(NSDictionary * error))didPost{
    // I have created an option so that if there is no location provided then I will have it request
    // location on its own, but the default is still probably going to rely on the location already provided.
    if(!self.location){
        [self getLocationDataWithCompletion:^{
            [ParseUtilities postLocationWithPOI_idStr:self.location.POI_idStr coordinates:self.location.coordinates name:self.location.name address:self.location.address completion:^(Location * _Nullable location, NSDictionary * _Nullable locationError) {
                if(locationError){
                    [ErrorHandler showAlertFromViewController:self title:locationError[@"title"] message:locationError[@"message"] completion:^{
                    }];
                } else {
                    [ParseUtilities postReviewWithLocation:location rating:rating title:title description:description images:nil completion:didPost];
                }
            }];
        }];
    } else {
        [ParseUtilities postReviewWithLocation:self.location rating:rating title:title description:description images:nil completion:didPost];
    }
}

//- (void)textViewDidBeginEditing:(UITextView *)textView{
//}
//- (void) textViewDidEndEditing:(UITextView *)textView{
//}
// method to hide keyboard when user taps on a scrollview
-(void)hideKeyboard
{
    [self.scrollView endEditing:YES];
}
- (IBAction)didTapPhoto:(id)sender {
    NSLog(@"tapped photo");
}

- (IBAction)didTapSubmit:(id)sender {
    if([self checkValuesWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text]){
        [self locationHandlerWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text didPost:^(NSDictionary * _Nullable error){
            //TODO: go back to the reviews screen, not the maps screen.
            if(error){
                [ErrorHandler showAlertFromViewController:self title:error[@"title"] message:error[@"message"] completion:^{
                }];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    } else {
        [ErrorHandler showAlertFromViewController:self title:@"Cannot post review" message:@"Please fill in all fields." completion:^{
        }];
    }
}


// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(keyboardWasShown:)
            name:UIKeyboardDidShowNotification object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self
             selector:@selector(keyboardWillBeHidden:)
             name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    UITextView * activeField = self.reviewTextView;
    NSLog(@"%f", activeField.frame.size.height);
    NSLog(@"%f", activeField.frame.origin.y);
    CGPoint point = CGPointMake(0, activeField.frame.origin.y + activeField.frame.size.height);
    if(!CGRectContainsPoint(aRect,point)) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y + activeField.frame.size.height - kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}











@end
