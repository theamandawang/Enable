//
//  ColorViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/27/22.
//

#import "ColorViewController.h"
@interface ColorViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *themePicker;

@end

@implementation ColorViewController
NSArray<NSString *> * themes;
- (void)viewDidLoad {
    [super viewDidLoad];
    themes = @[@"Default", @"Parchment", @"Sunrise", @"Twilight"];
    self.themePicker.dataSource = self;
    self.themePicker.delegate = self;
    NSString * myTheme = [ThemeTracker sharedTheme].theme;
    int row = myTheme ? [themes indexOfObject: myTheme] : 0;
    [self.themePicker selectRow:row inComponent:0 animated:YES];
    [self setupTheme];

}
- (void) setupTheme {
    [super setupTheme];
    [self.themePicker setBackgroundColor:[UIColor colorNamed: [ThemeTracker sharedTheme].colorSet[@"Secondary"]]];
}
#pragma mark - PickerView
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return themes.count;
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[NSAttributedString alloc] initWithString:themes[row] attributes:[NSDictionary dictionaryWithObjects:@[[UIColor colorNamed: [ThemeTracker sharedTheme].colorSet[@"Label"]]] forKeys:@[NSForegroundColorAttributeName]]];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString *selectedTheme = themes[row];
    [[NSUserDefaults standardUserDefaults] setObject:selectedTheme forKey:@"theme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([PFUser currentUser]){
        [Utilities getCurrentUserProfileWithCompletion:^(UserProfile * _Nullable profile, NSError * _Nullable error) {
            if(error){
                [self showAlert:@"Failed to get current user" message:error.localizedDescription completion:nil];
            } else if(profile) {
                [Utilities updateUserProfile:profile withTheme:themes[row] withCompletion:^(NSError * _Nullable updateError) {
                    if(updateError){
                        [self showAlert:@"Failed to update theme on cloud" message:updateError.localizedDescription completion:nil];
                    }
                }];
            }
            
        }];
    }
    NSLog(@"%@", themes[row]);
}


@end
