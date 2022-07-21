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

int imageIndex = 0;
UITapGestureRecognizer *scrollViewTapGesture;

- (void)viewDidLoad {
    [super viewDidLoad];
    [ErrorHandler testInternetConnection:self];

    self.images = [[NSMutableArray alloc] init];

    scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    scrollViewTapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollViewTapGesture];
    self.reviewTextView.delegate = self;
    [self registerForKeyboardNotifications];
    
    [self setupStarRatingView];

}

#pragma mark - Querying
-(void) getLocationDataWithCompletion: (void (^_Nonnull)(void)) completion {
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
    [Utilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withCompletion:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if(error){
            [ErrorHandler showAlertFromViewController:self title:@"Failed to get Place data" message:error.localizedDescription completion:^{
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

- (bool) checkValuesWithRating:(int)rating title:(NSString *)title description:(NSString*) description{
    if(rating && title && description){
        return !([title isEqualToString:@""] || [description isEqualToString:@""]);
    }
    return false;
}

- (void) locationHandlerWithRating : (int) rating title: (NSString *) title description: (NSString *) description images: (NSArray *) images didPost: (void (^_Nonnull)(NSError * error))didPost{
    // I have created an option so that if there is no location provided then I will have it request
    // location on its own, but the default is still probably going to rely on the location already provided.
    if(!self.location){
        [self getLocationDataWithCompletion:^{
            [Utilities postLocationWithPOI_idStr:self.location.POI_idStr coordinates:self.location.coordinates name:self.location.name address:self.location.address completion:^(Location * _Nullable location, NSError * _Nullable locationError) {
                if(locationError){
                    [ErrorHandler showAlertFromViewController:self title:@"Failed to post location" message:locationError.localizedDescription completion:^{
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

- (IBAction)didTapSubmit:(id)sender {
    [ErrorHandler startLoading:self];
    if([self checkValuesWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text]){
        [self locationHandlerWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text images: (NSArray *) self.images didPost:^(NSError * _Nullable error){
            if(error){
                [ErrorHandler endLoading:self];
                [ErrorHandler showAlertFromViewController:self title:@"Failed to post review" message:error.localizedDescription completion:^{
                }];
            } else {
                [ErrorHandler endLoading:self];
                [self.navigationController popViewControllerAnimated:NO];
            }
        }];
    } else {
        [ErrorHandler endLoading:self];
        [ErrorHandler showAlertFromViewController:self title:@"Cannot post review" message:@"Please fill in all fields." completion:^{
        }];
    }
}

#pragma mark - ImagePicker / Camera
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
        [ErrorHandler showAlertFromViewController:self title:@"Camera unavailable" message:@"Use photo library instead" completion:^{
            NSLog(@"Camera unavailable so we will use photo library instead");
            [self openLibrary];
        }];
        
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

#pragma mark - Keyboard
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
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
//    CGFloat kbHeight = 216;
    [self moveScrollView:kbHeight + 20];
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self moveScrollView:0];
}

- (void) hideKeyboard
{
    [self.scrollView endEditing:YES];
}

// push scroll view up so that keyboard doesn't block anything
- (void)moveScrollView: (CGFloat)constant {
//    [self.scrollView setBackgroundColor:UIColor.greenColor];
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

#pragma mark - Star Review


- (void)setupStarRatingView {
    self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectZero];
    self.starRatingView.backgroundColor = [UIColor systemBackgroundColor];
    self.starRatingView.tintColor = [UIColor systemYellowColor];
    [self.scrollView addSubview:self.starRatingView];
    
    [self setupStarRatingViewValues];
    
    self.starRatingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupStarRatingViewConstraints];
}

- (void)setupStarRatingViewValues {
    self.starRatingView.maximumValue = 5;
    self.starRatingView.minimumValue = 0;
    self.starRatingView.value = 0;
}

- (void)setupStarRatingViewConstraints {
    // Y
    [self.starRatingView.topAnchor constraintEqualToAnchor:self.imageStepper.bottomAnchor constant:30].active = YES;
    [self.starRatingView.heightAnchor constraintEqualToConstant:80].active = YES;
    [self.titleTextField.topAnchor constraintEqualToAnchor:self.starRatingView.bottomAnchor constant:30].active = YES;
    // X
    [self.starRatingView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.starRatingView.widthAnchor constraintEqualToConstant:250].active = YES;
}


#pragma mark - Image Uploading

- (IBAction)didChangeImageNumber:(id)sender {
    NSLog(@"%f", self.imageStepper.value);
    if(self.images.count == 0 && self.imageStepper.value == 1){
        self.imageStepper.value = 0;
        [self didTapPhoto:nil];
        return;
    }
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
