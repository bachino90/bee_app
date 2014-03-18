//
//  BeeSignInViewController.h
//  Bee
//
//  Created by Emiliano Bivachi on 17/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  BeeSignInViewControllerDelegate <NSObject>
- (void)finishSuccessLogin;
@end

@interface BeeSignInViewController : UIViewController
@property (nonatomic, weak) id <BeeSignInViewControllerDelegate> delegate;
@end
