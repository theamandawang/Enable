//
//  MapView.h
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN
@interface MapView : UIView
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) GMSMapView *mapView;
@end

NS_ASSUME_NONNULL_END
