//
//  BeeCommentView.h
//  Bee
//
//  Created by Emiliano Bivachi on 03/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BeeCommentView;
@protocol BeeCommentViewDelegate <NSObject>
- (void)commentView:(BeeCommentView *)commentView keyboardWillShown:(NSDictionary *)info;
- (void)commentView:(BeeCommentView *)commentView keyboardWillHidden:(NSDictionary *)info;
- (void)commentView:(BeeCommentView *)commentView resizeFrame:(CGRect)frame;
- (void)commentView:(BeeCommentView *)commentView postComment:(NSString *)comment;
@end

@interface BeeCommentView : UIView

@property (nonatomic, weak) id <BeeCommentViewDelegate> delegate;
- (void)setEnablePost:(BOOL)isEnable;

@end
