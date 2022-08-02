//
//  ColorViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/27/22.
//

#import "ColorViewController.h"
@interface ColorViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *themePicker;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UIColorWell * accentColorWell;
@property (strong, nonatomic) UIColorWell * backgroundColorWell;
@property (strong, nonatomic) UIColorWell * secondaryColorWell;
@property (strong, nonatomic) UIColorWell * labelColorWell;
@property (strong, nonatomic) UIColorWell * starColorWell;
@property (strong, nonatomic) UIColorWell * likeColorWell;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIView *customizeContentView;
@property (weak, nonatomic) IBOutlet UILabel *backgroundColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *accentColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *starColorLabel;
@property (weak, nonatomic) IBOutlet UIButton *customizeButton;

@end

@implementation ColorViewController
NSArray<NSString *> * themes;
- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary * themesDictionary = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Themes" ofType: @"plist"]];
    themes = [[themesDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    self.themePicker.dataSource = self;
    self.themePicker.delegate = self;
    [self setupAllColorWells];
    NSString * myTheme = [ThemeTracker sharedTheme].theme;
    int row = myTheme ? [themes indexOfObject: myTheme] : 0;
    [self.themePicker selectRow:row inComponent:0 animated:YES];
    if([themes[row] isEqualToString: @"Custom"]){
        [self.customizeContentView setHidden:NO];
    } else {
        [self.customizeContentView setHidden:YES];
    }
    [self setupTheme];

}
#pragma mark = ColorWell
- (void) setupAllColorWells {
    self.backgroundColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell:self.backgroundColorWell withLabel: self.backgroundColorLabel withTitle:@"Select Background Color"];
    
    self.secondaryColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.secondaryColorWell withLabel: self.secondaryColorLabel withTitle: @"Select text field color"];
    
    self.accentColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.accentColorWell withLabel: self.accentColorLabel withTitle: @"Select button color"];
    
    self.labelColorWell = self.labelColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.labelColorWell withLabel: self.labelColorLabel withTitle: @"Select text color"];
    
    self.likeColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.likeColorWell withLabel: self.likeColorLabel withTitle: @"Select like color"];
    
    self.starColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.starColorWell withLabel: self.starColorLabel withTitle: @"Select star color"];
    
    
    
}

- (void) setupColorWell : (UIColorWell *) well withLabel: (UILabel * ) label withTitle: (NSString *) title {
    well.title = title;
    well.supportsAlpha = NO;
    [self.customizeContentView addSubview:well];
    well.translatesAutoresizingMaskIntoConstraints = NO;
    [well.centerYAnchor constraintEqualToAnchor:label.centerYAnchor].active = YES;
    [well.leadingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-100].active = YES;
    [well.heightAnchor constraintEqualToConstant:80].active = YES;
    [well.widthAnchor constraintEqualToConstant:80].active = YES;
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
    if([themes[row] isEqualToString: @"Custom"]){
        [self.customizeContentView setHidden:NO];
    } else {
        [[ThemeTracker sharedTheme] updateTheme:themes[row]];
        [self.customizeContentView setHidden:YES];
    }
}

#pragma mark - Setup

- (void) setupTheme {
    [self setupMainTheme];
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    [self.scrollContentView setBackgroundColor:[UIColor colorNamed: colorSet[@"Background"]]];
    [self.customizeContentView setBackgroundColor:[UIColor colorNamed: colorSet[@"Background"]]];
    [self.customizeButton setTintColor: [UIColor colorNamed: colorSet[@"Accent"]]];
    [self.titleLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.backgroundColorLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.secondaryColorLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.accentColorLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.likeColorLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.starColorLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.labelColorLabel setTextColor:[UIColor colorNamed: colorSet[@"Label"]]];
    [self.themePicker setBackgroundColor:[UIColor colorNamed: colorSet[@"Secondary"]]];
    [self.themePicker reloadComponent:0];
}
- (IBAction)didTapCustomize:(id)sender {
    [self checkColors];
}


- (void) checkColors {
    if(self.backgroundColorWell.selectedColor && self.secondaryColorWell.selectedColor
       && self.labelColorWell.selectedColor
       && self.accentColorWell.selectedColor
       && self.likeColorWell.selectedColor
       && self.starColorWell.selectedColor){
        NSLog(@"%@", self.labelColorWell.selectedColor);
    } else {
        [self showAlert:@"Selections invalid" message:@"Not all fields are filled in" completion:nil];
    }
}



@end
