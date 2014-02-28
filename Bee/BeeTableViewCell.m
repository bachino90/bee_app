//
//  BeeTableViewCell.m
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeTableViewCell.h"

#define FONT_SIZE 18.0f
#define LABEL_WIDTH 280.0f
#define LABEL_MINIMUM_HEIGHT 40.0f
#define LABEL_MAXIMUM_HEIGHT 280.0f
#define DEFAULT_LABEL_SIZE() CGSizeMake(280.0,90.0)

@interface BeeTableViewCell ()
@end

@implementation BeeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSecret:(Secret *)secret {
    _secret = secret;
    NSString *content = _secret.content;
    self.secretLabel.text = content;
    //self.secretLabel.frame = CGRectZero;
    //self.secretLabel.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
    //[self.secretLabel setNumberOfLines:0];
    //[self.secretLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
    //[self.secretLabel setTag:1];
    self.secretLabel.backgroundColor = [UIColor yellowColor];
    
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [self.secretLabel.text boundingRectWithSize:DEFAULT_LABEL_SIZE() options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.secretLabel.font} context:ctx];
    textRect.origin.y = 20;
    textRect.origin.x = 20;
    textRect.size.width = LABEL_WIDTH;
    if (textRect.size.height < LABEL_MINIMUM_HEIGHT) {
        textRect.size.height = LABEL_MINIMUM_HEIGHT;
    } else if (textRect.size.height > LABEL_MAXIMUM_HEIGHT) {
        textRect.size.height = LABEL_MAXIMUM_HEIGHT;
    }
    self.secretLabel.frame = textRect;
    //CGFloat rowHeight = 20.0f + textRect.size.height + 30.0f + 6.0f + 8.0f;
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, rowHeight);
    
    if (_secret.friendIsAuthor) {
        self.isFriendLabel.text = @"F";
    } else {
        self.isFriendLabel.text = @"NF";
    }
    self.commentButton.titleLabel.text = [NSString stringWithFormat:@"C%i",_secret.commentsCount];
    self.likeButton.titleLabel.text = [NSString stringWithFormat:@"L%i",_secret.likesCount];
}

@end
