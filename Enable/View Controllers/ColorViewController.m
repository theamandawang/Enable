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
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    self.backgroundColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell:self.backgroundColorWell withLabel: self.backgroundColorLabel withTitle:@"Select Background Color"];
    [self.backgroundColorWell setSelectedColor:colorSet[@"Background"]];
    
    self.secondaryColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.secondaryColorWell withLabel: self.secondaryColorLabel withTitle: @"Select text field color"];
    [self.secondaryColorWell setSelectedColor:colorSet[@"Secondary"]];
    
    
    self.accentColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.accentColorWell withLabel: self.accentColorLabel withTitle: @"Select button color"];
    [self.accentColorWell setSelectedColor:colorSet[@"Accent"]];

    
    self.labelColorWell = self.labelColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.labelColorWell withLabel: self.labelColorLabel withTitle: @"Select text color"];
    [self.labelColorWell setSelectedColor:colorSet[@"Label"]];

    
    self.likeColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.likeColorWell withLabel: self.likeColorLabel withTitle: @"Select like color"];
    [self.likeColorWell setSelectedColor:colorSet[@"Like"]];

    
    self.starColorWell = [[UIColorWell alloc] initWithFrame:CGRectZero];
    [self setupColorWell: self.starColorWell withLabel: self.starColorLabel withTitle: @"Select star color"];
    [self.starColorWell setSelectedColor:colorSet[@"Star"]];
    
    
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
    return [[NSAttributedString alloc] initWithString:themes[row] attributes:[NSDictionary dictionaryWithObjects:@[[ThemeTracker sharedTheme].colorSet[@"Label"]] forKeys:@[NSForegroundColorAttributeName]]];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([themes[row] isEqualToString: @"Custom"]){
        [self.customizeContentView setHidden:NO];
        [self didTapCustomize:nil];

    } else {
        [[ThemeTracker sharedTheme] updateTheme:themes[row] withColorDict:nil];
        [self.customizeContentView setHidden:YES];
    }
}

#pragma mark - Setup

- (void) setupTheme {
    [self setupMainTheme];
    NSDictionary * colorSet = [ThemeTracker sharedTheme].colorSet;
    [self.scrollContentView setBackgroundColor: colorSet[@"Background"]];
    [self.customizeContentView setBackgroundColor: colorSet[@"Background"]];
    [self.customizeButton setTintColor: colorSet[@"Accent"]];
    [self.titleLabel setTextColor: colorSet[@"Label"]];
    [self.backgroundColorLabel setTextColor: colorSet[@"Label"]];
    [self.secondaryColorLabel setTextColor: colorSet[@"Label"]];
    [self.accentColorLabel setTextColor: colorSet[@"Label"]];
    [self.likeColorLabel setTextColor: colorSet[@"Label"]];
    [self.starColorLabel setTextColor: colorSet[@"Label"]];
    [self.labelColorLabel setTextColor: colorSet[@"Label"]];
    [self.themePicker setBackgroundColor: colorSet[@"Secondary"]];
    [self.themePicker reloadComponent:0];
}
- (IBAction)didTapCustomize:(id)sender {
    if([self checkColors]){
        //TODO: calculate statusBar color based on background color
        NSDictionary * dict = @{@"Background" : self.backgroundColorWell.selectedColor, @"Secondary" : self.secondaryColorWell.selectedColor,
                                @"Label" : self.labelColorWell.selectedColor, @"Accent" : self.accentColorWell.selectedColor,
                                @"Like" : self.likeColorWell.selectedColor, @"Star" : self.starColorWell.selectedColor, @"StatusBar" : @"Dark"};
        [[ThemeTracker sharedTheme] updateTheme:@"Custom" withColorDict:dict];
    }
}


- (bool) checkColors {
    if(self.backgroundColorWell.selectedColor && self.secondaryColorWell.selectedColor
       && self.labelColorWell.selectedColor
       && self.accentColorWell.selectedColor
       && self.likeColorWell.selectedColor
       && self.starColorWell.selectedColor){
        //TODO: check how close colors are!
        return true;
    } else {
        [self showAlert:@"Selections invalid" message:@"Not all fields are filled in" completion:nil];
        return false;
    }
}



@end
