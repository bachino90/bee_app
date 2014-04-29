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
    
}

@end
