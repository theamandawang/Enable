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
    [[ThemeTracker sharedTheme] updateTheme:themes[row]];
}

#pragma mark - Setup

- (void) setupTheme {
    [self setupMainTheme];
    [self.titleLabel setTextColor:[UIColor colorNamed: [ThemeTracker sharedTheme].colorSet[@"Label"]]];
    [self.themePicker setBackgroundColor:[UIColor colorNamed: [ThemeTracker sharedTheme].colorSet[@"Secondary"]]];
    [self.themePicker reloadComponent:0];
}

@end
