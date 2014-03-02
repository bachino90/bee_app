//
//  BeeCommentTableViewCell.m
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeCommentTableViewCell.h"

#define FONT_SIZE 18.0f
#define LABEL_WIDTH 220.0f

@implementation BeeCommentTableViewCell

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

- (void)setComment:(Comment *)comment {
    _comment = comment;
    NSString *content = _comment.content;
    self.commentLabel.text = content;
    self.commentLabel.backgroundColor = [UIColor yellowColor];
    
    if (_comment.friendIsAuthor) {
        self.howIsLabel.text = @"F";
    } else {
        self.howIsLabel.text = @"NF";
    }
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize maxSize = CGSizeMake(LABEL_WIDTH, CGFLOAT_MAX);
    CGSize requiredSize = [self.commentLabel sizeThatFits:maxSize];
    requiredSize.width = LABEL_WIDTH;
    self.commentLabel.frame = CGRectMake(self.commentLabel.frame.origin.x, self.commentLabel.frame.origin.y, requiredSize.width, requiredSize.height);
    if (requiredSize.height < 45) {
        self.requiredCellHeight = 65.0f;
    } else
        self.requiredCellHeight = 20.0f + requiredSize.height;
}


@end
