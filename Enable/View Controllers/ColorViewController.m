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
    NSDictionary * themesDictionary = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: kThemePlistName ofType: @"plist"]];
    themes = [[themesDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    self.themePicker.dataSource = self;
    self.themePicker.delegate = self;
    [self setupAllColorWells];
    NSString * myTheme = [ThemeTracker sharedTheme].theme;
    int row = myTheme ? [themes indexOfObject: myTheme] : 0;
    [self.themePicker selectRow:row inComponent:0 animated:YES];
    if([themes[row] isEqualToString: kCustomThemeName]){
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
    return [[NSAttributedString alloc] initWithString:themes[row] attributes:[NSDictionary dictionaryWithObjects:@[[[ThemeTracker sharedTheme] getLabelColor]] forKeys:@[NSForegroundColorAttributeName]]];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([themes[row] isEqualToString: kCustomThemeName]){
        [self.customizeContentView setHidden:NO];
        [[ThemeTracker sharedTheme] selectCustom];
    } else {
        [self.customizeContentView setHidden:YES];
        [[ThemeTracker sharedTheme] updateTheme:themes[row] withColorDict:nil];
    }
}

#pragma mark - Setup
- (void) updateColorWells {
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    if([[singleton theme] isEqualToString:kCustomThemeName]){
        [self.backgroundColorWell setSelectedColor: [singleton getBackgroundColor]];
        [self.secondaryColorWell setSelectedColor: [singleton getSecondaryColor]];
        [self.accentColorWell setSelectedColor: [singleton getAccentColor]];
        [self.labelColorWell setSelectedColor: [singleton getLabelColor]];
        [self.likeColorWell setSelectedColor: [singleton getLikeColor]];
        [self.starColorWell setSelectedColor: [singleton getStarColor]];
    }
}
- (void) setupTheme {
    [self setupMainTheme];
    ThemeTracker * singleton = [ThemeTracker sharedTheme];
    [self.scrollContentView setBackgroundColor: [singleton getBackgroundColor]];
    [self.customizeContentView setBackgroundColor: [singleton getBackgroundColor]];
    [self.customizeButton setTintColor: [singleton getAccentColor]];
    [self.titleLabel setTextColor: [singleton getLabelColor]];
    [self.backgroundColorLabel setTextColor: [singleton getLabelColor]];
    [self.secondaryColorLabel setTextColor: [singleton getLabelColor]];
    [self.accentColorLabel setTextColor: [singleton getLabelColor]];
    [self.likeColorLabel setTextColor: [singleton getLabelColor]];
    [self.starColorLabel setTextColor: [singleton getLabelColor]];
    [self.labelColorLabel setTextColor: [singleton getLabelColor]];
    [self.themePicker setBackgroundColor: [singleton getSecondaryColor]];
    [self.themePicker reloadComponent:0];
    [self updateColorWells];

}
- (IBAction)didTapCustomize:(id)sender {
    if([self checkColors]){
        NSDictionary * dict = @{@"Background" : self.backgroundColorWell.selectedColor, @"Secondary" : self.secondaryColorWell.selectedColor,
                                @"Label" : self.labelColorWell.selectedColor, @"Accent" : self.accentColorWell.selectedColor,
                                @"Like" : self.likeColorWell.selectedColor, @"Star" : self.starColorWell.selectedColor, @"StatusBar" : [self calculateStatusBar]};
        [[ThemeTracker sharedTheme] updateTheme:kCustomThemeName withColorDict:dict];
    }
}
- (NSString *) calculateStatusBar {
    // taken from https://www.w3.org/WAI/ER/WD-AERT/#color-contrast
    const CGFloat * components = CGColorGetComponents(self.backgroundColorWell.selectedColor.CGColor);
    float contrastVal = ((components[0] * 255 * 299) + (components[1] * 255 * 587) + (components[2] * 255 * 114)) / 1000;
    if(contrastVal < 125) {
        return kLightStatusBar;
    }
    return kDarkStatusBar;
}

- (bool) calculateDifferenceColor: (CGColorRef) c1 and: (CGColorRef) c2 {
    // taken from https://www.w3.org/WAI/ER/WD-AERT/#color-contrast
    const CGFloat * c1Components = CGColorGetComponents(c1);
    const CGFloat * c2Components = CGColorGetComponents(c2);
    float contrast = (fabs(c1Components[0] - c2Components[0]) + fabs(c1Components[1] - c2Components[1]) + fabs(c1Components[2] - c2Components[2])) * 255;
    return contrast > 200;
    
}
- (bool) checkColors {
    if([self allColorWellsFilled]){
        if([self labelSecondaryBackgroundContrast]){
            return true;
        } else {
            [self showAlert:@"Selections invalid" message:@"Make sure label and accent colors have enough contrast from background and secondary" completion:nil];
            return false;
        }
    } else {
        [self showAlert:@"Selections invalid" message:@"Not all fields are filled in" completion:nil];
        return false;
    }
}

- (bool) allColorWellsFilled {
    return self.backgroundColorWell.selectedColor && self.secondaryColorWell.selectedColor
    && self.labelColorWell.selectedColor
    && self.accentColorWell.selectedColor
    && self.likeColorWell.selectedColor
    && self.starColorWell.selectedColor;
}

- (bool) labelSecondaryBackgroundContrast {
    return [self calculateDifferenceColor:self.backgroundColorWell.selectedColor.CGColor and:self.accentColorWell.selectedColor.CGColor] &&
    [self calculateDifferenceColor:self.secondaryColorWell.selectedColor.CGColor and:self.accentColorWell.selectedColor.CGColor] &&
    [self calculateDifferenceColor:self.backgroundColorWell.selectedColor.CGColor and:self.labelColorWell.selectedColor.CGColor] &&
    [self calculateDifferenceColor:self.secondaryColorWell.selectedColor.CGColor and:self.labelColorWell.selectedColor.CGColor];
}

@end
