//
//  BeeCommentTableViewCell.m
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeCommentTableViewCell.h"
#import "Comment+Bee.h"
#import "Secret+Bee.h"

#define FONT_SIZE 18.0f
#define LABEL_WIDTH 220.0f

@interface BeeCommentTableViewCell () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

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

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer) {
        return _tapGestureRecognizer;
    }
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rePostComment:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    _tapGestureRecognizer.numberOfTouchesRequired = 1;
    return _tapGestureRecognizer;
}

- (void)rePostComment:(UITapGestureRecognizer *)tapGesture {
    if ([self.comment.state integerValue] == CommentFailDelivered) {
        UIActionSheet *as = [[UIActionSheet alloc]initWithTitle:@"Que deseas hacer?" delegate:self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:@"Enviar de nuevo",@"Eliminar el comentario",nil];
        
        [as showInView:self.superview];
    }
}

- (void)deleteComment:(UIButton *)deleteBtn {
    if ([self.comment.author integerValue] == 1) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Borrar Comentario" message:@"Esta seguro que desea borrar el comentario" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)updateBackgroundColor {
    switch ([self.comment.state integerValue]) {
        case CommentDelivered:
            self.backgroundColor = [UIColor blueColor];
            self.gestureRecognizers = nil;
            break;
        case CommentSuccessDelivered:
            self.backgroundColor = [UIColor clearColor];
            self.gestureRecognizers = nil;
            break;
        case CommentFailDelivered:
            self.backgroundColor = [UIColor redColor];
            [self addGestureRecognizer:self.tapGestureRecognizer];
            break;
        default:
            break;
    }
}

- (void)setComment:(Comment *)comment {
    _comment = comment;
    NSString *content = _comment.content;
    self.commentLabel.text = content;
    NSLog(@"%@",comment);
    self.avatarView.backgroundColor = [Secret colors][[comment.avatar_id integerValue]];
    //self.commentLabel.backgroundColor = [UIColor yellowColor];
    /*
    if (_comment.friendIsAuthor) {
        self.howIsLabel.text = @"F";
    } else {
        if (_comment.iAmAuthor)
            self.howIsLabel.text = @"";
        else
            self.howIsLabel.text = @"NF";
    }
    */
    self.deleteButton.hidden = YES;
    [self.deleteButton removeTarget:self action:@selector(deleteComment:) forControlEvents:UIControlEventTouchUpInside];
    if ([_comment.author integerValue] == 1) {
        self.deleteButton.hidden = NO;
        [self.deleteButton addTarget:self action:@selector(deleteComment:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.dateLabel.text = comment.dateString;
    [self updateBackgroundColor];
    
    [self setNeedsLayout];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize maxSize = CGSizeMake(LABEL_WIDTH, CGFLOAT_MAX);
    CGSize requiredSize = [self.commentLabel sizeThatFits:maxSize];
    requiredSize.width = LABEL_WIDTH;
    self.commentLabel.frame = CGRectMake(self.commentLabel.frame.origin.x, self.commentLabel.frame.origin.y, requiredSize.width, requiredSize.height);
    if (requiredSize.height < 45) {
        self.requiredCellHeight = 60.0f;
    } else
        self.requiredCellHeight = 20.0f + requiredSize.height + 10.0f;
}


#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.delegate commentCell:self rePostComment:self.comment];
    } else if (buttonIndex == 1) {
        [self.delegate commentCell:self deleteComment:self.comment];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
        [self.delegate commentCell:self deleteComment:self.comment];
    }
}

@end
