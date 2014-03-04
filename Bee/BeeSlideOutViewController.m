//
//  BeeSlideOutViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 04/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSlideOutViewController.h"
#import "BeeNotificationsViewController.h"
#import "BeeNavigationController.h"
#import "BeeViewController.h"

#define SLIDE_TIMING .3
#define PANEL_WIDTH 200
#define SCALE_FACTOR 0.9

#define CENTER_TAG 101
#define LEFT_PANEL_TAG 102

@interface BeeSlideOutViewController () <BeeViewControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) BeeNavigationController *centerViewController;
@property (nonatomic, assign) BOOL showingCenterPanel;

@property (nonatomic, strong) BeeNotificationsViewController *leftPanelViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;

@property (nonatomic) BOOL showPanel;
@property (nonatomic) CGPoint preVelocity;

@end

@implementation BeeSlideOutViewController

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark View Will/Did Appear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark View Will/Did Disappear

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Setup View

- (void)setupView
{
    // setup center view
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.centerViewController = [storyboard instantiateViewControllerWithIdentifier:@"BeeNavigationController"];
    self.centerViewController.view.tag = CENTER_TAG;
    self.centerViewController.navDelegate = self;
    
    [self.view addSubview:self.centerViewController.view];
    [self addChildViewController:_centerViewController];
    
    [_centerViewController didMoveToParentViewController:self];
    
    [self setupGestures];
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value)
    {
        [_centerViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [_centerViewController.view.layer setShadowOpacity:0.5];
        [_centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
    }
    else
    {
        [_centerViewController.view.layer setCornerRadius:0.0f];
        [_centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

- (void)resetMainView
{
    // remove left and right views, and reset variables, if needed
    if (_leftPanelViewController != nil)
    {
        [self.leftPanelViewController.view removeFromSuperview];
        self.leftPanelViewController = nil;
        
        _centerViewController.leftButton.tag = 1;
        self.showingLeftPanel = NO;
    }
    self.showingCenterPanel = NO;
    // remove view shadows
    [self showCenterViewWithShadow:NO withOffset:0];
}

- (UIView *)getLeftView
{
    // init view if it doesn't already exist
    if (_leftPanelViewController == nil)
    {
        // this is where you define the view for the left panel
        //self.leftPanelViewController = [[BeeNotificationsViewController alloc] initWithNibName:@"LeftPanelViewController" bundle:nil];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.leftPanelViewController = [storyboard instantiateViewControllerWithIdentifier:@"BeeNotificationsViewController"];
        
        self.leftPanelViewController.view.tag = LEFT_PANEL_TAG;
        self.leftPanelViewController.delegate = _centerViewController;
        
        [self.view addSubview:self.leftPanelViewController.view];
        
        [self addChildViewController:_leftPanelViewController];
        [_leftPanelViewController didMoveToParentViewController:self];
        
        _leftPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _leftPanelViewController.view.transform = CGAffineTransformMakeScale(SCALE_FACTOR, SCALE_FACTOR);
    }
    
    self.showingLeftPanel = YES;
    
    // set up view shadows
    [self showCenterViewWithShadow:YES withOffset:-2];
    
    UIView *view = self.leftPanelViewController.view;
    return view;
}

#pragma mark -
#pragma mark Swipe Gesture Setup/Actions

#pragma mark - setup

- (void)setupGestures
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [_centerViewController.view addGestureRecognizer:panRecognizer];
}

-(void)movePanel:(id)sender
{
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        UIView *childView = nil;
        
        if(velocity.x > 0) {
            //if (!_showingRightPanel) {
                childView = [self getLeftView];
            //}
        } else {
            //if (!_showingLeftPanel) {
                //childView = [self getRightView];
            //}
            if (_showingLeftPanel) {
                self.showingLeftPanel = NO;
                self.showingCenterPanel = YES;
            }
            
        }
        // Make sure the view you're working with is front and center.
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        if (!_showPanel) {
            [self movePanelToOriginalPosition];
        } else {
            if (_showingLeftPanel) //{
                [self movePanelRight];
            else if (_showingCenterPanel)
                [self movePanelToOriginalPosition];
            //}  else if (_showingRightPanel) {
                //[self movePanelLeft];
            //}
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        UIView *childView = nil;
        if(velocity.x > 0) {
            //if (!_showingRightPanel) {
                childView = _leftPanelViewController.view;
            //} else {
                //childView = _rightPanelViewController.view;
            //}
        } else {
            if (!_showingLeftPanel) {
                //childView = _rightPanelViewController.view;
                childView = _leftPanelViewController.view;
            } else {
                childView = _leftPanelViewController.view;
            }
        }
        
        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
        _showPanel = abs([sender view].center.x - _centerViewController.view.frame.size.width/4) > _centerViewController.view.frame.size.width/4;
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        CGFloat percent = [self percentForCenterViewPosition:[sender view].frame.origin.x];
        childView.transform = CGAffineTransformMakeScale(percent, percent);
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
    }
}

- (CGFloat)percentForCenterViewPosition:(CGFloat)x
{
    CGFloat percent = SCALE_FACTOR;
    CGFloat xRange = (self.centerViewController.view.frame.size.width - PANEL_WIDTH);
    if (x < xRange && x > (-xRange))
    {
        x = abs(x);
        percent = percent + 0.1 * x / xRange;
    } else {
        percent = 1.0;
    }
    return percent;
}

#pragma mark -
#pragma mark Delegate Actions

- (void)movePanelRight // to show left panel
{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
                         childView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _centerViewController.leftButton.tag = 0;
                         }
                     }];
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         self.leftPanelViewController.view.transform = CGAffineTransformMakeScale(SCALE_FACTOR, SCALE_FACTOR);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

#pragma mark -
#pragma mark Default System Code

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
