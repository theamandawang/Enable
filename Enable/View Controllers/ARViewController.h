//
//  ARViewController.h
//  Enable
//
//  Created by Amanda Wang on 8/8/22.
//

#import <UIKit/UIKit.h>
#import "EnableBaseViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ARViewControllerDelegate
@required
- (void) exportMeasurement: (CGFloat) measurement image:(UIImage *) snapshot;
@end
@interface ARViewController : EnableBaseViewController <ARSCNViewDelegate>
@property (weak, nonatomic) id<ARViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
