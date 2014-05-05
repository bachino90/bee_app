//
//  BeeNotificationTableViewCell.m
//  Bee
//
//  Created by Emiliano Bivachi on 18/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeNotificationTableViewCell.h"

@interface BeeNotificationTableViewCell ()

@property (nonatomic, strong) BeeSecretView *secretView;
@property (nonatomic, strong) UIView *alphaSkinView;
@property (nonatomic, strong) UILabel *likeLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@end

@implementation BeeNotificationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNotification:(Notification *)notification {
    _notification = notification;
    
    self.secretView = [[BeeSecretView alloc]initWithNotification:notification];
    
    self.alphaSkinView = [[UIView alloc]initWithFrame:self.secretView.frame];
    self.alphaSkinView.backgroundColor = [UIColor whiteColor];
    self.alphaSkinView.alpha = 0.3;
    
    [self.contentView addSubview:self.secretView];
    [self.contentView addSubview:self.alphaSkinView];
    
    if (notification.is_like) {
        self.likeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.likeLabel.text = [NSString stringWithFormat:@"L%i",[notification.likes_count integerValue]];
        [self.likeLabel sizeToFit];
        [self.contentView addSubview:self.likeLabel];
    }
    if (notification.is_comment) {
        self.commentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.commentLabel.text = [NSString stringWithFormat:@"C%i",[notification.comments_count integerValue]];
        [self.commentLabel sizeToFit];
        self.commentLabel.frame = CGRectMake(self.likeLabel.frame.origin.x + self.likeLabel.frame.size.width + 5.0 , self.commentLabel.frame.origin.y, self.commentLabel.frame.size.width, self.commentLabel.frame.size.height);
        [self.contentView addSubview:self.commentLabel];
    }
}

@end
