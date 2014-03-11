//
//  BeeLoginViewController.h
//  Bee
//
//  Created by Emiliano Bivachi on 05/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BeeLoginViewControllerDelegate <NSObject>
- (void)finishSuccessLogin;
@end

@interface BeeLoginViewController : UIViewController
@property (nonatomic, weak) id <BeeLoginViewControllerDelegate> delegate;
@end
