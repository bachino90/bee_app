//
//  BeeNotificationsViewController.h
//  Bee
//
//  Created by Emiliano Bivachi on 04/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BeeNotificationsViewControllerDelegate <NSObject>

@end

@interface BeeNotificationsViewController : UIViewController

@property (nonatomic, weak) id <BeeNotificationsViewControllerDelegate> delegate;

@end
