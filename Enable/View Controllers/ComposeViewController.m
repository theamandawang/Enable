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
@interface ComposeViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet PFImageView *photosImageView;
@property (strong, nonatomic) HCSStarRatingView *starRatingView;
@property (strong, nonatomic) ReviewShimmerView * shimmerLoadView;


@property (strong, nonatomic) NSMutableArray <UIImage *> *images;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ScrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

@implementation ComposeViewController
//TODO: add tableview for dropdown.
//TODO: automatically scroll up when keyboard opens
//https://stackoverflow.com/questions/13161666/how-do-i-scroll-the-uiscrollview-when-the-keyboard-appears
const int kMaxNumberOfImages = 3;
int imageIndex = 0;
UITapGestureRecognizer *scrollViewTapGesture;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = [[NSMutableArray alloc] init];
    scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    scrollViewTapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:scrollViewTapGesture];
    self.reviewTextView.delegate = self;
    [self registerForKeyboardNotifications];
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


#pragma mark - Querying
-(void) getLocationDataWithCompletion: (void (^_Nonnull)(void)) completion {
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress | GMSPlaceFieldName | GMSPlaceFieldCoordinate);
    [Utilities getPlaceDataFromPOI_idStr:self.POI_idStr withFields:fields withCompletion:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to get Place data" message:error.localizedDescription completion:nil];
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
    // location on its own, but the default is still  going to rely on the location already provided.
    if(!self.location){
        [self getLocationDataWithCompletion:^{
            [Utilities postLocationWithPOI_idStr:self.location.POI_idStr coordinates:self.location.coordinates name:self.location.name address:self.location.address completion:^(Location * _Nullable location, NSError * _Nullable locationError) {
                if(locationError){
                    [self showAlert:@"Failed to post location" message:locationError.localizedDescription completion:nil];
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
    [self startLoading];
    [self testInternetConnection];
    if([self checkValuesWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text]){
        [self locationHandlerWithRating:self.starRatingView.value title:self.titleTextField.text description:self.reviewTextView.text images: (NSArray *) self.images didPost:^(NSError * _Nullable error){
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

#pragma mark - Setup
- (void) setupTextView {
    self.reviewTextView.layer.cornerRadius = 5;
    self.reviewTextView.layer.masksToBounds = YES;
}
- (void) setupTheme{
    [self setupMainTheme];
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    [self.addImageButton setTintColor:[UIColor colorNamed: colorSet[@"Accent"]]];
    
    [self.submitButton setTintColor:[UIColor colorNamed: colorSet[@"Accent"]]];
    [self.titleTextField setBackgroundColor:[UIColor colorNamed: colorSet[@"Secondary"]]];
    [self.reviewTextView setBackgroundColor:[UIColor colorNamed: colorSet[@"Secondary"]]];
    [self.titleTextField setTextColor: [UIColor colorNamed: colorSet[@"Label"]]];
    [self.titleTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Title / Summary" attributes:@{NSForegroundColorAttributeName: [UIColor colorNamed: colorSet[@"Label"]]}]];

    [self.reviewTextView setTextColor: [UIColor colorNamed: colorSet[@"Label"]]];
    [self.reviewTextView setBackgroundColor: [UIColor colorNamed: colorSet[@"Secondary"]]];
    [self.starRatingView setTintColor: [UIColor colorNamed: colorSet[@"Star"]]];
    [self.starRatingView setBackgroundColor: [UIColor colorNamed: colorSet[@"Background"]]];
    [self.photosImageView setTintColor: [UIColor colorNamed: colorSet[@"Accent"]]];
    
    [self.shimmerLoadView setBG:[UIColor colorNamed:colorSet[@"Background"]] FG:[UIColor colorNamed: colorSet[@"Secondary"]]];
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

@end
