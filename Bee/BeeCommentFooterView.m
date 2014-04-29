//
//  BeeCommentFooterView.m
//  Bee
//
//  Created by Emiliano Bivachi on 23/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeCommentFooterView.h"

@interface BeeCommentFooterView ()
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation BeeCommentFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        self.activityView.hidesWhenStopped = YES;
        [self.activityView startAnimating];
        [self addSubview:self.activityView];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 50.0)];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
