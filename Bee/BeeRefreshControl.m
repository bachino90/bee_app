//
//  BeeRefreshControl.m
//  Bee
//
//  Created by Emiliano Bivachi on 02/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeRefreshControl.h"

#define REFRESH_CONTROL_HEIGHT 100.0f

@interface BeeRefreshControl ()
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation BeeRefreshControl

+ (CGFloat)height {
    return REFRESH_CONTROL_HEIGHT;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];
        
        UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, 150.0, REFRESH_CONTROL_HEIGHT)];
        loadingLabel.text = @"Loading...";
        [self addSubview:loadingLabel];
        
        self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityView.frame = CGRectMake(200.0, 0.0, self.activityView.frame.size.width, self.activityView.frame.size.height);
        [self addSubview:self.activityView];
    }
    return self;
}

- (void)amountOfControlVisible:(CGFloat)visibility {
    
}

- (void)refreshingWithDelta:(CGFloat)delta {
    
}


@end
