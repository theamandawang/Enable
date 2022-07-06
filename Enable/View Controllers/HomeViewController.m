//
//  HomeViewController.m
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import "HomeViewController.h"
#import "MapView.h"
@interface HomeViewController () <GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet MapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.mapView.delegate = self;
    
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.searchBar endEditing:YES];
}

@end
