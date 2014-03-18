//
//  BeeSignUpViewController.h
//  Bee
//
//  Created by Emiliano Bivachi on 17/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BeeSignUpViewControllerDelegate <NSObject>
- (void)cancelSignUp;
- (void)finishSuccessLogin;
@end

@interface BeeSignUpViewController : UIViewController

@property (nonatomic, weak) id <BeeSignUpViewControllerDelegate> delegate;

@end
