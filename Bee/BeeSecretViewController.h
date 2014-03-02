//
//  BeeSecretViewController.h
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BeeSecretViewController;
@protocol BeeSecretViewControllerDelegate <NSObject>
- (void)dismissBeeSecretViewController:(BeeSecretViewController *)vc;
@end

@interface BeeSecretViewController : UIViewController
@property (nonatomic, weak) id <BeeSecretViewControllerDelegate> delegate;
@property (nonatomic, strong) Secret *secret;
@end
