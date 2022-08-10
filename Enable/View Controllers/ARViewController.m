//
//  ARViewController.m
//  Enable
//
//  Created by Amanda Wang on 8/8/22.
//

#import "ARViewController.h"
@interface ARViewController () <ARSCNViewDelegate>
@property (weak, nonatomic) IBOutlet ARSCNView *arView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) NSMutableArray<SCNNode *> * nodes;
@property (strong, nonatomic) SCNNode * ray;
@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    self.arView.autoenablesDefaultLighting = YES;
    [[self.arView session] runWithConfiguration:configuration options:ARSessionRunOptionRemoveExistingAnchors];
    self.arView.delegate = self;
    self.nodes = [[NSMutableArray alloc] init];
}
#pragma mark ARSCNView
- (void)sessionWasInterrupted:(ARSession *)session {
    [self showAlert:@"ARSession Interrupted" message:@"Try again" completion:nil];
}
#pragma mark - Measure gesture
- (IBAction)didTapandDragScene:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:sender.view];
    switch(sender.state){
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        case UIGestureRecognizerStateBegan:
        {
            if(self.nodes.count) {
                [self clearView];
            }
            [self addNodeAt:location];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if(self.nodes.count) {
                if(self.ray){
                    [self.ray removeFromParentNode];
                }
                [self addRay:self.nodes[0] end:location];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self addNodeAt:location];
            if(self.nodes.count != 2) {
                [self clearView];
            } else {
                NSLog(@"%f", [self distanceFrom:self.nodes[0] to:self.nodes[1]]);
                CGFloat dist = [self distanceFrom:self.nodes[0] to:self.nodes[1]];
                SCNVector3 midpoint = [self midpointFrom:self.nodes[0].position to:self.nodes[1].position];
                [self addTextNodeAt:midpoint withDistance:dist];
            }
            break;
        }
        case UIGestureRecognizerStatePossible:
            break;
    }
}

- (void) clearView {
    for(SCNNode * n in self.nodes){
        [n removeFromParentNode];
    }
    [self.ray removeFromParentNode];
    self.ray = nil;
    [self.nodes removeAllObjects];
}

#pragma mark - Calculations
- (SCNVector3) midpointFrom: (SCNVector3) source to: (SCNVector3) destination {
    CGFloat x = (destination.x + source.x) / 2.0;
    CGFloat y = (destination.y + source.y) / 2.0;
    CGFloat z = (destination.z + source.z) / 2.0;
    return SCNVector3Make(x, y, z);
}
- (CGFloat) distanceFrom: (SCNNode *) source to: (SCNNode *) destination {
    float metersToInches = 39.3701;
    return simd_distance(destination.simdPosition, source.simdPosition) * metersToInches;
}



#pragma mark - add nodes

- (SCNVector3) arQuery: (CGPoint) location {
    ARRaycastQuery *query = [self.arView raycastQueryFromPoint:location allowingTarget:ARRaycastTargetEstimatedPlane alignment:ARRaycastTargetAlignmentAny];
    NSArray<ARRaycastResult *> *result = [self.arView.session raycast:query];
    if (![result firstObject]) {
        return SCNVector3Zero;
    }
    ARRaycastResult * point = result[0];
    SCNVector3 pos = SCNVector3Make(point.worldTransform.columns[3].x, point.worldTransform.columns[3].y, point.worldTransform.columns[3].z);
    return pos;
}

- (void) addTextNodeAt: (SCNVector3) location withDistance: (CGFloat) distance {
    SCNNode * node = [[SCNNode alloc] init];
    SCNText * text = [SCNText textWithString:[NSString stringWithFormat:@"%0.2f", distance] extrusionDepth:0.5];
    [self.delegate exportMeasurement:distance];
    SCNMaterial * material = [[SCNMaterial alloc] init];
    material.diffuse.contents = UIColor.systemRedColor;
    text.materials = @[material];
    node.geometry = text;
    node.position = location;
    node.scale = SCNVector3Make(0.005, 0.005, 0.005);
    
    // text faces camera
    SCNLookAtConstraint * constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:self.arView.pointOfView];
    constraint.localFront = SCNVector3Make(0, 0, 1);
    constraint.gimbalLockEnabled = YES;
    node.constraints = @[constraint];
    [self.nodes addObject:node];
    [self.arView.scene.rootNode addChildNode:node];
}

- (void) addNodeAt: (CGPoint) location {
    SCNVector3 pos = [self arQuery:location];
    if(pos.x == 0 && pos.y == 0 && pos.z == 0){
        return;
    }
    SCNNode * node = [[SCNNode alloc] init];
    SCNSphere * sphere = [SCNSphere sphereWithRadius:0.01];
    SCNMaterial * material = [[SCNMaterial alloc] init];
    material.diffuse.contents = UIColor.systemRedColor;
    sphere.materials = @[material];
    node.geometry = sphere;
    node.position = pos;
    [self.nodes addObject:node];
    [self.arView.scene.rootNode addChildNode:node];
}
- (void) addRay: (SCNNode *) startNode end: (CGPoint) end {
    SCNVector3 endPoint = [self arQuery:end];
    CGFloat height = sqrt(pow(startNode.position.x - endPoint.x, 2) + pow(startNode.position.y - endPoint.y, 2) + pow(startNode.position.z - endPoint.z, 2));
    SCNNode * node = [[SCNNode alloc] init];
    SCNCylinder *cylinder = [SCNCylinder cylinderWithRadius:0.005 height: height];
    
    SCNMaterial * material = [[SCNMaterial alloc] init];
    material.diffuse.contents = UIColor.systemRedColor;
    cylinder.materials = @[material];
    
    node.geometry = cylinder;
    node.eulerAngles = SCNVector3Make(M_PI/2, acos((startNode.position.z-endPoint.z)/height), atan2((startNode.position.y-endPoint.y), (startNode.position.x-endPoint.x)));

    node.position = [self midpointFrom:startNode.position to:endPoint];
    
    self.ray = node;
    [self.arView.scene.rootNode addChildNode:node];
}

#pragma mark - IBAction
- (IBAction)didTapSave:(id)sender {
    UIImage * snap = [self.arView snapshot];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:snap];
        changeRequest.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"Saved to Camera Roll" message:@"" completion:nil];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"Failed to Save" message:error.localizedDescription completion:nil];
            });
        }
    }];
}

#pragma mark - Theme

- (void) setupTheme {
    [self setupMainTheme];
    [self.saveButton setTintColor: [[ThemeTracker sharedTheme] getAccentColor]];
    [self.saveButton setBackgroundColor:[[ThemeTracker sharedTheme] getBackgroundColor]];
    self.saveButton.layer.cornerRadius = 10;
}

@end
