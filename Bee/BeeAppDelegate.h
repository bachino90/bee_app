//
//  BeeAppDelegate.h
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "BeeSlideOutViewController.h"

@interface BeeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BeeSlideOutViewController *viewController;

@end
