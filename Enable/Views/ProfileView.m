//
//  ProfileView.m
//  Enable
//
//  Created by Amanda Wang on 7/6/22.
//

#import "ProfileView.h"
#import "ReviewTableViewCell.h"
#import "ProfileTableViewCell.h"
#import "Utilities.h"
@interface ProfileView() <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
@implementation ProfileView
const int kNumberSections = 2;
const int kProfileSection = 0;
- (instancetype) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self profileInit];
    }
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self profileInit];
    }
    return self;
}
- (instancetype) profileInit{
    [[NSBundle mainBundle] loadNibNamed: @"ProfileView" owner: self options:nil];
    UINib *nib = [UINib nibWithNibName:@"ReviewTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ReviewCell"];
    UINib *nib2 = [UINib nibWithNibName:@"ProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"ProfileCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self reloadUserData];
    
    self.contentView.frame = self.bounds;
    [self addSubview: self.contentView];

    return self;
}
- (void) reloadUserData {
    [self.tableView reloadData];
}
# pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberSections;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.section == kProfileSection) {
        ProfileTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        cell.userProfileImageView.file = self.currentProfile.image;
        if(!cell.userProfileImageView.file) {
            cell.userProfileImageView.image = [UIImage systemImageNamed:@"person.fill"];
        }
        cell.userDisplayNameTextField.text = self.userProfile.username;
        return cell;
    } else {
        ReviewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
            cell.resultsView.delegate = self.delegate;
            [Utilities getUserProfileFromID:self.reviews[indexPath.row].userProfileID.objectId withCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
                if(error){
                    [self.delegate showAlertWithTitle:@"Failed to get user" message:error.localizedDescription completion:^{
                    }];
                } else {
                    [Utilities isLikedbyUser:self.currentProfile review:self.reviews[indexPath.row] completion:^(bool liked, NSError * _Nullable error) {
                        if(error){
                            [self.delegate showAlertWithTitle:@"Failed to check likes" message:error.localizedDescription completion:^{
                            }];
                        } else {
                            cell.resultsView.liked = liked;
                            cell.resultsView.currentProfile = self.currentProfile;
                            cell.resultsView.review = self.reviews[indexPath.row];
                            [cell.resultsView presentReview: self.reviews[indexPath.row] byUser: profile];
                        }
                    }];
                    
                }
            }];
        NSLog(@"%@", self.reviews[indexPath.row].title);
            return cell;
    }
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section){
        case kProfileSection:
            return 1;
        default:
            return self.reviews.count;
    }
}

@end
