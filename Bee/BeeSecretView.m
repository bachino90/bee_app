//
//  BeeSecretView.m
//  Bee
//
//  Created by Emiliano Bivachi on 01/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSecretView.h"
#import "Secret+Bee.h"
#import "Notification.h"
#import "Notification+Bee.h"

#define LABEL_WIDTH 280.0f
#define LABEL_MARGIN_X 20.0f
#define LABEL_MARGIN_TOP_Y 20.0f
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
        self.backgroundColor = [secret color];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.text = secret.content;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 20;
        label.font = [secret font];
        //CGSize maxSize = CGSizeMake(SCREEN_WIDTH - 2*LABEL_MARGIN_X, CGFLOAT_MAX);
        //CGSize requiredSize = [label sizeThatFits:maxSize];
        //requiredSize.width = SCREEN_WIDTH - 2*LABEL_MARGIN_X;
        //label.frame = CGRectMake(LABEL_MARGIN_X, LABEL_MARGIN_TOP_Y, requiredSize.width, requiredSize.height);
        label.frame = CGRectMake(LABEL_MARGIN_X, LABEL_MARGIN_TOP_Y, SCREEN_WIDTH - 2*LABEL_MARGIN_X, SECRET_WIDTH - LABEL_MARGIN_TOP_Y);
        [self addSubview:label];
        
        self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SECRET_WIDTH);
    }
    return self;
}

- (id)initWithNotification:(Notification *)notification {
    self = [self initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, SECRET_WIDTH)];
    if (self) {
        self.backgroundColor = [notification color];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.text = notification.secret_content;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 20;
        label.font = [notification font];
        label.frame = CGRectMake(LABEL_MARGIN_X, LABEL_MARGIN_TOP_Y, SCREEN_WIDTH - 2*LABEL_MARGIN_X, SECRET_WIDTH - LABEL_MARGIN_TOP_Y);
        [self addSubview:label];
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
        self.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
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
