//
//  BeeCommentTableViewCell.h
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "BeeAvatarView.h"

@interface BeeCommentTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet BeeAvatarView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *howIsLabel;

@property (nonatomic, strong) Comment *comment;
@property (nonatomic) CGFloat requiredCellHeight;
@end
