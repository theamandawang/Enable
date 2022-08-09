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
            NSLog(@"%f", [self distanceFrom:self.arView.scene.rootNode.childNodes[0] to:self.arView.scene.rootNode.childNodes[1]]);
            break;
        }
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

- (CGFloat) distanceFrom: (SCNNode *) source to: (SCNNode *) destination {
    CGFloat dx = destination.position.x - source.position.x;
    CGFloat dy = destination.position.y - source.position.y;
    CGFloat dz = destination.position.z - source.position.z;
     
    float inches = 39.3701;
    float meters = sqrt(dx*dx + dy*dy + dz*dz);

    return meters*inches;
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
    SCNSphere * sphere = [SCNSphere sphereWithRadius:0.01];
    SCNMaterial * material = [[SCNMaterial alloc] init];
    material.diffuse.contents = UIColor.systemRedColor;
    sphere.materials = @[material];
    node.geometry = sphere;
    node.position = pos;
    [self.arView.scene.rootNode addChildNode:node];
}
- (void) setupTheme {
    [self setupMainTheme];
}
@end
