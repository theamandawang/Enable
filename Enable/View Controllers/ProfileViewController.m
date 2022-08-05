//
//  ProfileViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileViewController.h"
#import "Utilities.h"
#import "ReviewByLocationViewController.h"
#import "Review.h"
#import "ReviewTableViewCell.h"
#import "ProfileShimmerView.h"
@interface ProfileViewController() <ResultsViewDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ProfileDelegate>
@property (strong, nonatomic) UserProfile * userProfile;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (strong, nonatomic) NSMutableArray<Review *> * reviews;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ProfileShimmerView * shimmerLoadView;
@property (strong, nonatomic) ProfileTableViewCell *profileCell;
@end

@implementation ProfileViewController
bool imageUpdated = false;
bool userUpdated = false;

- (void)viewDidLoad {
    [super viewDidLoad];

    if(self.userProfileID){
        [self.logOutButton setHidden:YES];
    }
    [self getCurrentProfile:^{
        [self getUserProfile];
    }];
    UINib *nib = [UINib nibWithNibName:@"ReviewTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ReviewCell"];
    UINib *nib2 = [UINib nibWithNibName:@"ProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"ProfileCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setupShimmerView];
    [self setupTheme];

}

#pragma mark - Override
- (void) startLoading {
    [self.shimmerLoadView setHidden: NO];
    [self.tableView setHidden: YES];
}

- (void) endLoading {
    [self.shimmerLoadView setHidden:YES];
    [self.tableView setHidden:NO];
}

#pragma mark - Queries
- (void) getUserProfile {
    [self startLoading];
    if(self.userProfileID){
        [Utilities getUserProfileFromID:self.userProfileID withCompletion:^(UserProfile * _Nullable userProfile, NSError * _Nullable error) {
            if(error){
                [self showAlert:@"Failed to get user" message:error.localizedDescription completion:nil];
            } else {
                self.userProfile = userProfile;
                [self getReviewsByUserProfile: userProfile];

            }
        }];
    } else {
        [self getReviewsByUserProfile:self.currentProfile];
        self.userProfile = self.currentProfile;
    }
}

- (void) getCurrentProfile: (void (^ _Nonnull) (void)) completion {
    [self startLoading];
    [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
        if(error && (error.code != kCustomizedErrorCode)){
            [self showAlert:@"Failed to get current user" message:error.localizedDescription completion:nil];
        } else {
            self.currentProfile = profile;
        }
        completion();
    }];
}

- (void) getReviewsByUserProfile: (UserProfile *) userProfile {
    [Utilities getReviewsByUserProfile:userProfile withCompletion:^(NSMutableArray<Review *> * _Nullable reviews, NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to get reviews by user" message:error.localizedDescription completion:nil];
        } else {
            self.reviews = reviews;
        }
        [self endLoading];
        [self.tableView reloadData];
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"profileToReviews"]){
        ReviewByLocationViewController * vc = [segue destinationViewController];
        vc.locationID = sender;
        vc.delegate =  [self.navigationController.viewControllers objectAtIndex: 0];
    }
}


#pragma mark - ResultsViewDelegate
- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nonnull)(void))completion{
    [self showAlert:title message:message completion:completion];
}
- (void) addLikeFromUserProfile:(UserProfile *)currentProfile review:(Review *)review{
    [Utilities addLikeToReview:review fromUserProfile:currentProfile completion:^(NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to like" message:error.localizedDescription completion:nil];
        }
    }];
}
- (void) removeLikeFromReview:(Review *)review currentUser:(UserProfile *)currentProfile{
    [Utilities removeLikeFromReview:review fromUserProfile:currentProfile completion:^(NSError * _Nullable error) {
        if(error){
            [self showAlert:@"Failed to unlike" message:error.localizedDescription completion:nil];
        }
    }];
}
- (void) toLogin{
    [self performSegueWithIdentifier:@"profileToLogin" sender:nil];
}

# pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberProfileSections;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.section == kProfileSection) {
        ProfileTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        if(!self.userProfile.image) {
            cell.userProfileImageView.image = [UIImage systemImageNamed:@"person.fill"];
        } else {
            cell.userProfileImageView.file = self.userProfile.image;
            [cell.userProfileImageView loadInBackground];
        }
        if([self.currentProfile.objectId isEqualToString: self.userProfile.objectId]){
            [cell.updateButton setHidden:NO];
            [cell.contentView setUserInteractionEnabled:YES];
        } else {
            [cell.updateButton setHidden:YES];
            [cell.contentView setUserInteractionEnabled:NO];
        }
        cell.userDisplayNameTextField.text = self.userProfile.username;
        cell.delegate = self;
        self.profileCell = cell;
        [self setupProfileCellTheme:cell];
        return cell;
    } else {
        ReviewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
        cell.resultsView.delegate = self;
        cell.resultsView.userProfile = self.userProfile;
        [self setupResultsViewTheme: cell.resultsView];
        [Utilities isLikedbyUser:self.currentProfile review:self.reviews[indexPath.row] completion:^(bool liked, NSError * _Nullable error) {
            if(error){
                [self showAlert:@"Failed to check likes" message:error.localizedDescription completion:nil];
            } else {
                cell.resultsView.liked = liked;
                cell.resultsView.currentProfile = self.currentProfile;
                [cell.resultsView.profileImageView setUserInteractionEnabled:NO];
                [cell.resultsView.usernameLabel setUserInteractionEnabled:NO];
                cell.resultsView.review = self.reviews[indexPath.row];
                [cell.resultsView presentReview: self.reviews[indexPath.row] byUser: self.userProfile];
            }
        }];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section){
        case kProfileSection:
            return kRowsForNonReviews;
        default:
            return self.reviews.count;
    }
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section != kProfileSection){
        [self performSegueWithIdentifier:@"profileToReviews" sender:self.reviews[indexPath.row].locationID.objectId];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch(section){
        case kProfileSection:
            return @"Profile";
        default:
            return @"Reviews";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor: [[ThemeTracker sharedTheme] getLabelColor]];
    view.tintColor = [[ThemeTracker sharedTheme] getBackgroundColor];
    view.alpha = 0.8;
}

#pragma mark - IBAction
- (IBAction)didTapLogout:(id)sender {
    [Utilities logOutWithCompletion:^(NSError * _Nullable error){
        if(error){
            [self showAlert:@"Failed to log out" message:error.localizedDescription completion:nil];
        } else {
            [[ThemeTracker sharedTheme] removeCustomTheme];
            [self.navigationController popToRootViewControllerAnimated:TRUE];

        }
    } ];
}

#pragma mark - ProfileDelegate
- (void)didTapPhoto {
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
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.profileCell.userProfileImageView.image = editedImage;
    imageUpdated = true;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didEdit {
    userUpdated = true;
}

- (void) didTapUpdate {
    // update profile
    UIImage * img = imageUpdated ? self.profileCell.userProfileImageView.image : nil;
    NSString * user = userUpdated ? self.profileCell.userDisplayNameTextField.text : nil;
    if(imageUpdated || userUpdated){
        [self startLoading];
        [Utilities updateUserProfile:self.userProfile withUser:user withImage:img withCompletion:^(NSError * _Nullable error) {
            if(error){
                [self showAlert:@"Failed update profile" message:error.localizedDescription completion:nil];
            } else {
                imageUpdated = false;
                userUpdated = false;
            }
            [self getReviewsByUserProfile:self.userProfile];
        }];
    }
}

#pragma mark - Setup
- (void) setupTheme {
    [self setupMainTheme];
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [self.shimmerLoadView setBG: [singleton getBackgroundColor] FG: [singleton getSecondaryColor]];
    [self.tableView setBackgroundColor: [singleton getBackgroundColor]];
    [self.tableView setSeparatorColor: [singleton getSecondaryColor]];
}

- (void) setupProfileCellTheme : (ProfileTableViewCell *) cell {
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [cell.contentView setBackgroundColor: [singleton getBackgroundColor]];
    [cell.userProfileImageView setTintColor: [singleton getAccentColor]];
    [cell.userDisplayNameTextField setBackgroundColor: [singleton getSecondaryColor]];
    [cell.userDisplayNameTextField setTextColor: [singleton getLabelColor]];
    [cell.updateButton setTintColor: [singleton getAccentColor]];
    
}

- (void) setupResultsViewTheme : (ResultsView * ) view {
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [view.contentView setBackgroundColor: [singleton getBackgroundColor]];
    [view.titleLabel setTextColor:  [singleton getLabelColor]];
    [view.usernameLabel setTextColor:  [singleton getLabelColor]];
    [view.detailsLabel setTextColor: [singleton getLabelColor]];
    [view.likeCountLabel setTextColor: [singleton getLabelColor]];

    [view.starRatingView setTintColor: [singleton getStarColor]];
    [view.starRatingView setBackgroundColor: [singleton getBackgroundColor]];
    [view.likeImageView setTintColor: [singleton getLikeColor]];
}

- (void) setupShimmerView {
    self.shimmerLoadView = [[ProfileShimmerView alloc] init];
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
