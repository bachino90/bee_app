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

@class BeeCommentTableViewCell;
@protocol BeeCommentTableViewCellDelegate <NSObject>
- (void)commentCell:(BeeCommentTableViewCell *)cell rePostComment:(Comment *)comment;
- (void)commentCell:(BeeCommentTableViewCell *)cell deleteComment:(Comment *)comment;
@end

@interface BeeCommentTableViewCell : UITableViewCell

@property (nonatomic, weak) id <BeeCommentTableViewCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet BeeAvatarView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) Comment *comment;
@property (nonatomic) CGFloat requiredCellHeight;
@end
