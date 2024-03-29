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
#import "Review.h"
#import "ReviewShimmerView.h"
@interface ComposeViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, ARViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIButton *arButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (strong, nonatomic) HCSStarRatingView *starRatingView;
@property (strong, nonatomic) ReviewShimmerView * shimmerLoadView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIButton *measurementButton;
@property (weak, nonatomic) IBOutlet UITextField *measureTextField;
@property (strong, nonatomic) NSMutableArray <UIImage *> *images;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ScrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

@implementation ComposeViewController
//TODO: add tableview for dropdown.
int imageIndex = 0;
UITapGestureRecognizer *scrollViewTapGesture;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = [[NSMutableArray alloc] init];
    scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    scrollViewTapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollViewTapGesture];
    self.reviewTextView.delegate = self;
    [self.measurementButton setHidden:YES];
    [self.measureTextField setHidden:YES];
    [self setupTextView];
    [self setupStarRatingView];
    [self setupShimmerView];
    [self setupTheme];
}

#pragma mark - Override
- (void) startLoading {
    [self.scrollView setHidden:YES];
    [self.shimmerLoadView setHidden:NO];
}

- (void) endLoading {
    [self.shimmerLoadView setHidden:YES];
    [self.scrollView setHidden:NO];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:kComposeToARSegueName]){
        ARViewController * vc = [segue destinationViewController];
        vc.delegate = self;
    }
}

#pragma mark - Querying
-(void) getLocationDataWithCompletion: (void (^_Nonnull)(void)) completion {
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
    [Utilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withCompletion:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to get Place data" message:error.localizedDescription completion:nil];
        } else {
            self.location = [[Location alloc] initWithClassName: kLocationModelClassName];
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

- (void) locationHandlerWithRating : (int) rating title: (NSString *) title description: (NSString *) description images: (NSArray *) images measurement: (float) measurement measuredItem: (NSString * _Nullable) measuredItem didPost: (void (^_Nonnull)(NSError * error))didPost{
    // I have created an option so that if there is no location provided then I will have it request
    // location on its own, but the default is still  going to rely on the location already provided.
    if([measuredItem isEqualToString:@""]) measuredItem = nil;
    if(!self.location){
        [self getLocationDataWithCompletion:^{
            [Utilities postLocationWithPOI_idStr:self.location.POI_idStr coordinates:self.location.coordinates name:self.location.name address:self.location.address completion:^(Location * _Nullable location, NSError * _Nullable locationError) {
                if(locationError){
                    [self showAlert:@"Failed to post location" message:locationError.localizedDescription completion:nil];
                } else {
                    [Utilities postReviewWithLocation:location rating:rating title:title description:description images:images measurement: measurement measuredItem: measuredItem completion:didPost];
                }
            }];
        }];
    } else {
        [Utilities postReviewWithLocation:self.location rating:rating title:title description:description images: images measurement: measurement measuredItem: measuredItem completion:didPost];
    }
}

- (IBAction)didTapSubmit:(id)sender {
    [self startLoading];
    [self testInternetConnection];
    if([self checkValuesWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text]){
        if(![self.measurementButton isHidden] && [self.measureTextField.text isEqualToString:@""]){
            [self endLoading];
            [self showAlert:@"Cannot post review" message:@"Please describe measured item." completion:nil];
            return;
        }
        [self locationHandlerWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text images: (NSArray *) self.images measurement: [self.measurementButton.titleLabel.text floatValue] measuredItem:self.measureTextField.text didPost:^(NSError * _Nullable error){
            if(error){
                [self endLoading];
                [self showAlert:@"Failed to post review" message:error.localizedDescription completion:nil];
            } else {
                [self endLoading];
                [self.navigationController popViewControllerAnimated:NO];
            }
        }];
    } else {
        [self endLoading];
        [self showAlert:@"Cannot post review" message:@"Please fill in all fields." completion:nil];
    }
}
- (IBAction)didTapAR:(id)sender {
    [self performSegueWithIdentifier:kComposeToARSegueName sender:nil];
}

#pragma mark - ImagePicker / Camera
- (IBAction)didTapPhoto:(id)sender {
    UIAlertController *alert =
        [UIAlertController
                    alertControllerWithTitle:@"Upload Photo or Take Photo"
                    message:@"Would you like to upload a photo from your photos library or take one with your camera?"
                    preferredStyle:(UIAlertControllerStyleAlert)
        ];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                 style:UIAlertActionStyleCancel
                                                 handler:nil];
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
    [self presentViewController:alert animated:YES completion:nil];

}
- (void) openCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showAlert:@"Camera unavailable" message:@"Use photo library instead" completion:^{
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
    PHPickerConfiguration * config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = kMaxNumberOfImages;
    config.filter = [PHPickerFilter imagesFilter];
    PHPickerViewController * imagePickerVC = [[PHPickerViewController alloc] initWithConfiguration:config];

    imagePickerVC.delegate = self;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.photosImageView.image = editedImage;
    imageIndex = 0;
    self.images = [[NSMutableArray alloc] initWithArray:@[editedImage]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)picker:(nonnull PHPickerViewController *)picker didFinishPicking:(nonnull NSArray<PHPickerResult *> *)results {
    int count = 0;
    if(results.count == 0){
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    imageIndex = 0;
    [self.images removeAllObjects];
    for (PHPickerResult * res in results){
        if([res.itemProvider canLoadObjectOfClass:[UIImage class]]){
            [res.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
                if(object){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(count == 0) {
                            self.photosImageView.image = (UIImage*)object;
                        }
                        if(self.images.count < kMaxNumberOfImages){
                            [self.images addObject: (UIImage*)object];
                        }
                    });
                }
            }];
        }
        count ++;

    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Keyboard

- (void) hideKeyboard
{
    [self.scrollView endEditing:YES];
}
#pragma mark - Star Review


- (void)setupStarRatingView {
    self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectZero];
    self.starRatingView.backgroundColor = [UIColor systemBackgroundColor];
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
    [self.starRatingView.topAnchor constraintEqualToAnchor:self.addImageButton.bottomAnchor constant:30].active = YES;
    [self.starRatingView.heightAnchor constraintEqualToConstant:80].active = YES;
    [self.titleTextField.topAnchor constraintEqualToAnchor:self.starRatingView.bottomAnchor constant:30].active = YES;
    // X
    [self.starRatingView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.starRatingView.widthAnchor constraintEqualToConstant:250].active = YES;
}

#pragma mark - Image Uploading

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
- (IBAction)didRemoveMeasure:(id)sender {
    [self.measurementButton setHidden:YES];
    [self.measureTextField setHidden:YES];
    [self.measureTextField setText:@""];
}

#pragma mark - Setup
- (void) setupTextView {
    self.reviewTextView.layer.cornerRadius = 5;
    self.reviewTextView.layer.masksToBounds = YES;
}
- (void) setupTheme{
    [self setupMainTheme];
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [self.addImageButton setTintColor: [singleton getAccentColor]];
    [self.scrollContentView setBackgroundColor: [singleton getBackgroundColor]];
    [self.submitButton setTintColor: [singleton getAccentColor]];
    [self.arButton setTintColor: [singleton getAccentColor]];
    [self.measurementButton setTintColor: [singleton getAccentColor]];
    [self.measureTextField setBackgroundColor: [singleton getSecondaryColor]];
    [self.measureTextField setTextColor: [singleton getLabelColor]];
    [self.measureTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Measured Item:" attributes:@{NSForegroundColorAttributeName: [singleton getLabelColor]}]];
    [self.titleTextField setBackgroundColor: [singleton getSecondaryColor]];
    [self.reviewTextView setBackgroundColor: [singleton getSecondaryColor]];
    [self.titleTextField setTextColor:  [singleton getLabelColor]];
    [self.titleTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Title / Summary" attributes:@{NSForegroundColorAttributeName: [singleton getLabelColor]}]];
    [self.reviewTextView setTextColor: [singleton getLabelColor]];
    [self.reviewTextView setBackgroundColor: [singleton getSecondaryColor]];
    [self.starRatingView setTintColor: [singleton getStarColor]];
    [self.starRatingView setBackgroundColor: [singleton getBackgroundColor]];
    [self.photosImageView setTintColor: [singleton getAccentColor]];

    [self.shimmerLoadView setBG: [singleton getBackgroundColor] FG: [singleton getSecondaryColor]];
}

- (void) setupShimmerView {
    self.shimmerLoadView = [[ReviewShimmerView alloc] init];
    self.shimmerLoadView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.shimmerLoadView];
    [self.shimmerLoadView setHidden:YES];
    [self.shimmerLoadView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.shimmerLoadView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.shimmerLoadView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.shimmerLoadView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.shimmerLoadView setup];
}

- (void)exportMeasurement:(CGFloat)measurement image: (UIImage *) snapshot{
    self.photosImageView.image = snapshot;
    [self.images removeAllObjects];
    [self.images addObject:snapshot];
    [self.measurementButton setTitle:[NSString stringWithFormat:@"%0.2f inches", measurement] forState:UIControlStateNormal];
    [self.measurementButton setHidden:NO];
    [self.measureTextField setHidden:NO];
}

@end
