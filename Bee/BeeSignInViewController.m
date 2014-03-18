//
//  BeeSignInViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 17/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSignInViewController.h"
#import "BeeSignUpViewController.h"
#import "BeeLoginViewController.h"

#define NUM_OF_PAGES 2

@interface BeeSignInViewController () <UIScrollViewDelegate, BeeSignUpViewControllerDelegate, BeeLoginViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *viewControllers;
@end

@implementation BeeSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < NUM_OF_PAGES; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    self.scrollView.scrollEnabled = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * NUM_OF_PAGES, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BeeLoginViewController *loginController = (BeeLoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BeeLoginViewController"];
    loginController.delegate = self;
    [self.viewControllers replaceObjectAtIndex:0 withObject:loginController];
    [self loadScrollViewWithController:loginController andPage:0];
    
    BeeSignUpViewController *signupController = (BeeSignUpViewController *)[storyboard instantiateViewControllerWithIdentifier:@"BeeSignUpViewController"];
    signupController.delegate = self;
    [self.viewControllers replaceObjectAtIndex:1 withObject:signupController];
    [self loadScrollViewWithController:signupController andPage:1];
}

- (void)loadScrollViewWithController:(UIViewController *)controller andPage:(NSInteger)page
{
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (void)gotoPage:(NSInteger)page
{
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:YES];
}

#pragma mark - Sign Up View Controller Delegate

- (void)cancelSignUp {
    [self gotoPage:0];
}

#pragma mark - Login View Controller Delegate

- (void)signUpTouched {
    [self gotoPage:1];
}

- (void)finishSuccessLogin {
    [self.delegate finishSuccessLogin];
}



@end
