//
//  BeeFooterView.m
//  Bee
//
//  Created by Emiliano Bivachi on 23/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeFooterView.h"

@interface BeeFooterView ()
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation BeeFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor lightGrayColor];
        self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityView.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        self.activityView.hidesWhenStopped = YES;
        [self addSubview:self.activityView];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 75.0)];
    return self;
}

- (void)start {
    [self.activityView startAnimating];
}

- (void)stop {
    [self.activityView stopAnimating];
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
