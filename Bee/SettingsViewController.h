//
//  SettingsViewController.h
//  Bee
//
//  Created by Emiliano Bivachi on 02/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate <NSObject>
- (void)cancel;
@end

@interface SettingsViewController : UIViewController

@property (nonatomic, weak) id <SettingsViewControllerDelegate> delegate;

@end
