//
//  BeeTableViewCell.h
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeeTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *secretLabel;
@property (nonatomic, weak) IBOutlet UILabel *isFriendLabel;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIView *bottomBorder;

@property (nonatomic, strong) Secret *secret;
@property (nonatomic) CGFloat requiredCellHeight;

@end
