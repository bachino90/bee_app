//
//  BeeAddSecretViewController.h
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BeeAddSecretViewController;
@protocol BeeAddSecretViewControllerDelegate <NSObject>
- (void)cancelPublication;
- (void)publishSecret:(NSDictionary *)secret;
@end

@interface BeeAddSecretViewController : UIViewController

@property (nonatomic, weak) id <BeeAddSecretViewControllerDelegate> delegate;

@end
