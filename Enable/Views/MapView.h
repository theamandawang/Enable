//
//  MapView.h
//  Enable
//
//  Created by Amanda Wang on 7/5/22.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
NS_ASSUME_NONNULL_BEGIN
@protocol ViewErrorHandle
- (void) showAlertWithTitle: (NSString *) title message: (NSString * _Nonnull) message completion: (void (^ _Nullable)(void))completion;
@end
@interface MapView : UIView <CLLocationManagerDelegate>
@property (weak, nonatomic) id<ViewErrorHandle> errorDelegate;
@property (strong, nonatomic) GMSMapView *mapView;
@end

NS_ASSUME_NONNULL_END
