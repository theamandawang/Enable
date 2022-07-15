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
#import "Utilities.h"
#import "ErrorHandler.h"
#import "Review.h"
@interface ComposeViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (strong, nonatomic) HCSStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet UIStepper *imageStepper;
@property (strong, nonatomic) NSMutableArray <UIImage *> *images;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ScrollViewBottomConstraint;
@end

@implementation ComposeViewController
//TODO: add tableview for dropdown.
//TODO: automatically scroll up when keyboard opens
//https://stackoverflow.com/questions/13161666/how-do-i-scroll-the-uiscrollview-when-the-keyboard-appears
// this doesn't seem to be working? not sure what to do.
// when keyboard is already open, and i click the textview, this works really well. but not when i click the textView first.
int imageIndex = 0;
UITapGestureRecognizer *scrollViewTapGesture;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.images = [[NSMutableArray alloc] init];

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
    [self.scrollView addSubview:self.starRatingView];
}


-(void) getLocationDataWithCompletion: (void (^_Nonnull)(void)) completion {
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
            completion();
        }
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

- (void) locationHandlerWithRating : (int) rating title: (NSString *) title description: (NSString *) description images: (NSArray *) images didPost: (void (^_Nonnull)(NSDictionary * error))didPost{
    // I have created an option so that if there is no location provided then I will have it request
    // location on its own, but the default is still probably going to rely on the location already provided.
    if(!self.location){
        [self getLocationDataWithCompletion:^{
            [Utilities postLocationWithPOI_idStr:self.location.POI_idStr coordinates:self.location.coordinates name:self.location.name address:self.location.address completion:^(Location * _Nullable location, NSDictionary * _Nullable locationError) {
                if(locationError){
                    [ErrorHandler showAlertFromViewController:self title:locationError[@"title"] message:locationError[@"message"] completion:^{
                    }];
                } else {
                    [Utilities postReviewWithLocation:location rating:rating title:title description:description images:images completion:didPost];
                }
            }];
        }];
    } else {
        [Utilities postReviewWithLocation:self.location rating:rating title:title description:description images: images completion:didPost];
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
    UIAlertController *alert =
        [UIAlertController
                    alertControllerWithTitle:@"Upload Photo or Take Photo"
                    message:@"Would you like to upload a photo from your photos library or take one with your camera?"
                    preferredStyle:(UIAlertControllerStyleAlert)
        ];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * _Nonnull action) {
                                        // handle cancel response here. Doing nothing will dismiss the view.
                                    }];
    [alert addAction:cancelAction];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Use Camera"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
                                                      }];
    [alert addAction:cameraAction];
    UIAlertAction *libraryAction = [UIAlertAction
                                    actionWithTitle:@"Use Library"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [self openLibrary];
                                    }];
    [alert addAction:libraryAction];
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];

}
- (void) openCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //TODO: error handle
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        [self openLibrary];
        return;
    }
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
- (void) openLibrary {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.photosImageView.image = editedImage;
    if(imageIndex == self.images.count && imageIndex != 2){
        [self.images addObject: editedImage];
    } else {
        self.images[imageIndex] = editedImage;
    }
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)didTapSubmit:(id)sender {
    if([self checkValuesWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text]){
        [self locationHandlerWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text images: (NSArray *) self.images didPost:^(NSDictionary * _Nullable error){
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
//    NSDictionary* info = [aNotification userInfo];
//    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    CGFloat kbHeight = 216;
    [self moveScrollView:kbHeight + 20];
    
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
//
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your application might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    UITextView * activeField = self.reviewTextView;
//    NSLog(@"%f", activeField.frame.size.height);
//    NSLog(@"%f", activeField.frame.origin.y);
//    CGPoint point = CGPointMake(0, activeField.frame.origin.y + activeField.frame.size.height);
//    if(!CGRectContainsPoint(aRect,point)) {
//        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y + activeField.frame.size.height - kbSize.height);
//        [self.scrollView setContentOffset:scrollPoint animated:YES];
//    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self moveScrollView:0];
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)moveScrollView: (CGFloat)constant {
    [self.scrollView setBackgroundColor:UIColor.greenColor];
    self.ScrollViewBottomConstraint.constant = -constant;
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
        CGFloat scrollViewYOffset = 0;
        if (constant != 0) {
            scrollViewYOffset = 20;
        }
        [self.scrollView setContentOffset:CGPointMake(0, scrollViewYOffset)];
    }];
}


- (IBAction)didChangeImageNumber:(id)sender {
    NSLog(@"%f", self.imageStepper.value);
    if(imageIndex < self.imageStepper.value){
        [self didTapPhoto:nil];
        imageIndex = self.imageStepper.value;
    } else {
        [self.images removeObjectAtIndex:imageIndex];
        [self didSwipeRight:nil];
    }
}

- (IBAction)didSwipeLeft:(id)sender {
    // takes care of unsigned vs. signed arithmetic
    if((imageIndex + 1) < self.images.count){
        imageIndex ++;
        [self animateSwipe];

    }
}
- (IBAction)didSwipeRight:(id)sender {
    if(imageIndex > 0){
        imageIndex --;
        [self animateSwipe];
    }
}
- (void) animateSwipe {
    [UIView transitionWithView:self.photosImageView
            duration:0.5f
            options:UIViewAnimationOptionTransitionCrossDissolve
            animations:^{
                self.photosImageView.image = self.images[imageIndex];
            }
            completion:nil
    ];
}


@end
