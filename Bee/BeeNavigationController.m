//
//  BeeNavigationController.m
//  Bee
//
//  Created by Emiliano Bivachi on 04/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeNavigationController.h"
#import "BeeViewController.h"

@interface BeeNavigationController ()

@end

@implementation BeeNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)leftButton {
    return ((BeeViewController *)self.topViewController).leftButton;
}

- (void)refreshSecrets {
    [((BeeViewController *)self.topViewController) refreshSecrets];
}

@end
