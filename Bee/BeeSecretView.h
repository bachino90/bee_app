//
//  BeeSecretView.h
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Notification;

@interface BeeSecretView : UIView
- (instancetype)initWithSecret:(Secret *)secret;
- (instancetype)initWithNotification:(Notification *)notification;
@end
