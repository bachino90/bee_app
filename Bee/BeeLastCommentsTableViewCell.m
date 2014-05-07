//
//  BeeLastCommentsTableViewCell.m
//  Bee
//
//  Created by Emiliano Bivachi on 05/05/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeLastCommentsTableViewCell.h"

#import "BeeSyncEngine.h"

@interface BeeLastCommentsTableViewCell ()
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation BeeLastCommentsTableViewCell

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
    [self restartCell];
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer) {
        return _tapGestureRecognizer;
    }
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchOldComments:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    _tapGestureRecognizer.numberOfTouchesRequired = 1;
    return _tapGestureRecognizer;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (_activityIndicatorView) {
        return _activityIndicatorView ;
    }
    _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.frame = CGRectMake(0.0, 0.0, _activityIndicatorView.frame.size.width, _activityIndicatorView.frame.size.height);
    _activityIndicatorView.center = self.contentView.center;
    return _activityIndicatorView;
}

- (UILabel *)label {
    if (_label) {
        return _label;
    }
    
    _label   = [[UILabel alloc]initWithFrame:CGRectZero];
    _label.text = @"Ver comentarios anteriores";
    _label.font = [UIFont systemFontOfSize:13.0f];
    CGSize size = [_label sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    _label.frame = CGRectMake(10.0, self.contentView.center.y - size.height/2.0, size.width, size.height);
    return _label;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)searchOldComments:(UITapGestureRecognizer *)tapGestureRecognizer {
    self.contentView.gestureRecognizers = nil;
    [self.label removeFromSuperview];
    [self.contentView addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    [self.delegate searchOldComments:self];
}

- (void)restartCell {
    [self.activityIndicatorView removeFromSuperview];
    [self.contentView addSubview:self.label];
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
}

@end
