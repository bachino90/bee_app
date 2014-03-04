//
//  BeeCommentView.m
//  Bee
//
//  Created by Emiliano Bivachi on 03/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeCommentView.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_SIZE 19.0f
#define HEIGHT 50.0f
#define MAX_HEIGHT 240.0f
#define BUTTON_WIDTH 85.0f

@interface BeeCommentView () <UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *postButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic) CGFloat lastHeight;
@end

@implementation BeeCommentView

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [self unregisterForKeyboardNotifications];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH - BUTTON_WIDTH, HEIGHT)];
        self.textView.delegate = self;
        self.textView.font = [UIFont systemFontOfSize:FONT_SIZE];
        self.postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.postButton.frame = CGRectMake(SCREEN_WIDTH - BUTTON_WIDTH, 0.0, BUTTON_WIDTH, HEIGHT);
        [self.postButton setTitle:@"Post" forState:UIControlStateNormal];
        [self.postButton addTarget:self action:@selector(postBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.postButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        [self addSubview:self.textView];
        [self addSubview:self.postButton];
        self.postButton.enabled = NO;
        
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
        self.tapGesture.numberOfTouchesRequired = 1;
        self.tapGesture.numberOfTapsRequired = 1;
        
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0.0, SCREEN_HEIGHT - HEIGHT, SCREEN_WIDTH, HEIGHT)];
}

- (void)hideKeyboard {
    [self.textView resignFirstResponder];
}

- (void)postBtn:(UIButton *)btn {
    if (self.textView.text.length > 0) {
        [self.delegate commentView:self postComment:self.textView.text];
        [self resetTextView];
    }
}

- (void)resetTextView {
    self.textView.text = @"";
    self.postButton.enabled = NO;
    [self hideKeyboard];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShown:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat newOriginY = self.frame.origin.y - kbSize.height;
    
    [self.superview addGestureRecognizer:self.tapGesture];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.delegate commentView:self keyboardWillShown:info];
    self.frame = CGRectMake(self.frame.origin.x,  newOriginY, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat newOriginY = self.frame.origin.y + kbSize.height;
    
    self.superview.gestureRecognizers = nil;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.delegate commentView:self keyboardWillHidden:info];
    self.frame = CGRectMake(self.frame.origin.x,  newOriginY, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark - Frame resize

- (void)setNewHeight:(CGFloat)height {
    CGRect frame = self.bounds;
    frame.size.height = height;
    
    frame.size.width = SCREEN_WIDTH - BUTTON_WIDTH;
    self.textView.frame = frame;
    
    frame.size.width = BUTTON_WIDTH;
    frame.origin.x = SCREEN_WIDTH - BUTTON_WIDTH;
    self.postButton.frame = frame;
    
    frame = self.frame;
    frame.origin.y -= (height - frame.size.height);
    frame.size.height = height;
    self.frame = frame;
}

- (void)calculateHeightForTextView:(UITextView *)textView {
    CGSize maxSize = CGSizeMake(SCREEN_WIDTH - BUTTON_WIDTH, CGFLOAT_MAX);
    CGSize requiredSize = [textView sizeThatFits:maxSize];
    requiredSize.width = SCREEN_WIDTH - BUTTON_WIDTH;
    if (requiredSize.height > HEIGHT &&
        requiredSize.height < MAX_HEIGHT &&
        self.lastHeight != requiredSize.height) {
        [UIView animateWithDuration:0.25f animations:^{
            [self setNewHeight:requiredSize.height];
            [self.delegate commentView:self resizeFrame:self.frame];
            self.lastHeight = requiredSize.height;
        }];
    }
}

#pragma mark - Text view delegate

//Begin

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
}

//End

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self hideKeyboard];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

//Change

- (void)textViewDidChange:(UITextView *)textView {
    [self calculateHeightForTextView:textView];
    if (self.textView.text.length > 0) {
        self.postButton.enabled = YES;
    } else {
        self.postButton.enabled = NO;
    }
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
