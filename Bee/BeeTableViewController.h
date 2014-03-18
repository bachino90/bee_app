//
//  BeeTableViewController.h
//  Bee
//
//  Created by Emiliano Bivachi on 18/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeeTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;

- (void)refreshSecrets;

@end
