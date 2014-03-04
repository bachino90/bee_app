//
//  BeeSecretView.m
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSecretView.h"
#define LABEL_WIDTH 280.0f
#define LABEL_MARGIN_X 20.0f
#define LABEL_MARGIN_TOP_Y 50.0f
#define LABEL_MARGIN_BOTTOM_Y 40.0f

@interface BeeSecretView ()
@property (nonatomic, strong) Secret *secret;
@end

@implementation BeeSecretView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithSecret:(Secret *)secret {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.secret = secret;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.text = secret.content;
        label.textAlignment = NSTextAlignmentCenter;
        CGSize maxSize = CGSizeMake(SCREEN_WIDTH - 2*LABEL_MARGIN_X, CGFLOAT_MAX);
        CGSize requiredSize = [label sizeThatFits:maxSize];
        requiredSize.width = SCREEN_WIDTH - 2*LABEL_MARGIN_X;
        
        label.frame = CGRectMake(LABEL_MARGIN_X, LABEL_MARGIN_TOP_Y, requiredSize.width, requiredSize.height);
        [self addSubview:label];
        
        self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, LABEL_MARGIN_TOP_Y + requiredSize.height + LABEL_MARGIN_BOTTOM_Y);
    }
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
