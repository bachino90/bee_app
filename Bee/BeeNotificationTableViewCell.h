//
//  BeeNotificationTableViewCell.h
//  Bee
//
//  Created by Emiliano Bivachi on 18/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#import "BeeSecretView.h"

@interface BeeNotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) Notification *notification;

@end
