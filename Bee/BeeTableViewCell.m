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
#define LABEL_MINIMUM_HEIGHT 50.0f
#define LABEL_MAXIMUM_HEIGHT 340.0f

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

- (IBAction)likeSecret:(UIButton *)sender {
    if (self.secret.iLikeIt) {
        [[BeeAPIClient sharedClient]DELETELikeOnSecret:self.secret.secretID success:^(NSURLSessionDataTask *task, id responseObject) {
            self.secret.likesCount--;
            self.secret.iLikeIt = NO;
            self.likeButton.titleLabel.text = [NSString stringWithFormat:@"L%i",self.secret.likesCount];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    } else {
        [[BeeAPIClient sharedClient]PUTLikeOnSecret:self.secret.secretID success:^(NSURLSessionDataTask *task, id responseObject) {
            self.secret.likesCount++;
            self.secret.iLikeIt = YES;
            self.likeButton.titleLabel.text = [NSString stringWithFormat:@"L%i",self.secret.likesCount];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
    
}

- (IBAction)commentSecret:(UIButton *)sender {
}

- (void)setSecret:(Secret *)secret {
    _secret = secret;
    NSString *content = _secret.content;
    self.secretLabel.text = content;
    self.secretLabel.backgroundColor = [UIColor yellowColor];

    if (_secret.friendIsAuthor) {
        self.isFriendLabel.text = @"F";
    } else {
        self.isFriendLabel.text = @"NF";
    }
    self.commentButton.titleLabel.text = [NSString stringWithFormat:@"C%i",_secret.commentsCount];
    self.likeButton.titleLabel.text = [NSString stringWithFormat:@"L%i",_secret.likesCount];
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize maxSize = CGSizeMake(LABEL_WIDTH, LABEL_MAXIMUM_HEIGHT);
    CGSize requiredSize = [self.secretLabel sizeThatFits:maxSize];
    requiredSize.width = LABEL_WIDTH;
    if (requiredSize.height < LABEL_MINIMUM_HEIGHT) {
        requiredSize.height = LABEL_MINIMUM_HEIGHT;
    } else if (requiredSize.height > LABEL_MAXIMUM_HEIGHT) {
        requiredSize.height = LABEL_MAXIMUM_HEIGHT;
    }
    self.secretLabel.frame = CGRectMake(self.secretLabel.frame.origin.x, self.secretLabel.frame.origin.y, requiredSize.width, requiredSize.height);
    self.requiredCellHeight = 20.0f + requiredSize.height + 30.0f + 6.0f + 8.0f;
}

@end
