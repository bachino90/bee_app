//
//  BeeNavigationController.h
//  Bee
//
//  Created by Emiliano Bivachi on 04/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeeNotificationsViewController.h"

@protocol BeeViewControllerDelegate <NSObject>
@optional
- (void)movePanelRight;
@required
- (void)movePanelToOriginalPosition;
@end

@interface BeeNavigationController : UINavigationController <BeeNotificationsViewControllerDelegate>

@property (nonatomic, weak) id <BeeViewControllerDelegate> navDelegate;
@property (nonatomic, readonly) UIBarButtonItem *leftButton;

- (void)refreshSecrets;

@end
