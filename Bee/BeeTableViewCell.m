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
@property (nonatomic, strong) UIColor *darkColor;
@property (nonatomic, strong) UIColor *color;
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

- (void)setDarkColor:(UIColor *)color {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    saturation += 0.2;
    brightness -= 0.2;
    _darkColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
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
    self.secretLabel.textAlignment = NSTextAlignmentCenter;
    self.secretLabel.textColor = [UIColor whiteColor];
    //self.secretLabel.layer.borderWidth = 1.0f;
    //self.secretLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    switch (_secret.author) {
        case 0:
            self.isFriendLabel.text = @"";
            break;
        case 1:
            self.isFriendLabel.text = @"";
            break;
        case 2:
            self.isFriendLabel.text = @"F";
            break;
        case 3:
            self.isFriendLabel.text = @"FoF";
            break;
        default:
            self.isFriendLabel.text = @"";
            break;
    }
    self.commentButton.titleLabel.text = [NSString stringWithFormat:@"C%i",_secret.commentsCount];
    self.likeButton.titleLabel.text = [NSString stringWithFormat:@"L%i",_secret.likesCount];
    self.backgroundColor = secret.color;
    self.secretLabel.font = secret.font;
    
    [self setDarkColor:secret.color];
    [self setColor:secret.color];
    self.bottomBorder.backgroundColor = self.darkColor;
    [self setNeedsLayout];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    /*
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
     */
}

@end
