//
//  BeeNotificationView.m
//  Bee
//
//  Created by Emiliano Bivachi on 16/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeNotificationView.h"

@interface BeeNotificationView ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation BeeNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenSeaColor];
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.label.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.label];
    }
    return self;
}

- (void)setNotificationText:(NSString *)notificationText {
    _notificationText = notificationText;
    self.label.text = notificationText;
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
