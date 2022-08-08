//
//  ARViewController.m
//  Enable
//
//  Created by Amanda Wang on 8/8/22.
//

#import "ARViewController.h"
@interface ARViewController () <ARSCNViewDelegate>
@property (weak, nonatomic) IBOutlet ARSCNView *arView;
//@property (strong, nonatomic) ARSCNView * arView;
@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    self.arView.autoenablesDefaultLighting = YES;
    [[self.arView session] runWithConfiguration:configuration options:ARSessionRunOptionRemoveExistingAnchors];

    self.arView.delegate = self;
}
#pragma mark ARSCNView
- (void)sessionWasInterrupted:(ARSession *)session {
    [self showAlert:@"ARSession Interrupted" message:@"Try again" completion:nil];
}

#pragma mark - Measure gesture
- (IBAction)didTapandDragScene:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:sender.view];
    switch(sender.state){
        case UIGestureRecognizerStateBegan:
        {
            [self addNodeAt:location];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self addNodeAt:location];

            break;
        }
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}


- (void) addNodeAt: (CGPoint) location {
    ARRaycastQuery *query = [self.arView raycastQueryFromPoint:location allowingTarget:ARRaycastTargetEstimatedPlane alignment:ARRaycastTargetAlignmentAny];
    NSArray<ARRaycastResult *> *result = [self.arView.session raycast:query];
    if (![result firstObject]) {
        return;
    }
    ARRaycastResult * point = result[0];
    SCNVector3 pos = SCNVector3Make(point.worldTransform.columns[3].x, point.worldTransform.columns[3].y, point.worldTransform.columns[3].z);
    SCNNode * node = [[SCNNode alloc] init];
    node.geometry = [SCNSphere sphereWithRadius:0.01];
    node.position = pos;
    [self.arView.scene.rootNode addChildNode:node];
}
- (void) setupTheme {
    [self setupMainTheme];
}
@end
