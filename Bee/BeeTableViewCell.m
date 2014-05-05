//
//  BeeTableViewCell.m
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeTableViewCell.h"
#import "BeeUser.h"
#import "Secret+Bee.h"

#import "BeeSyncEngine.h"

#define FONT_SIZE 18.0f
#define LABEL_WIDTH 280.0f
#define LABEL_MINIMUM_HEIGHT 50.0f
#define LABEL_MAXIMUM_HEIGHT 340.0f

@interface BeeTableViewCell () <UIActionSheetDelegate>
@property (nonatomic, strong) UIColor *darkColor;
@property (nonatomic, strong) UIColor *color;
@end

@implementation BeeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDarkColor:(UIColor *)color {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    saturation += 0.2;
    brightness -= 0.2;
    _darkColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (IBAction)likeSecret:(UIButton *)sender {
    if ([self.secret.i_like_it boolValue]) {
        [[BeeAPIClient sharedClient]DELETELikeOnSecret:self.secret.secret_id success:^(NSURLSessionDataTask *task, id responseObject) {
            //self.secret.likes_count--;
            //self.secret.i_like_it = NO;
            self.likeButton.titleLabel.text = [NSString stringWithFormat:@"L%i",[self.secret.likes_count integerValue]-1];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    } else {
        [[BeeAPIClient sharedClient]PUTLikeOnSecret:self.secret.secret_id success:^(NSURLSessionDataTask *task, id responseObject) {
            //self.secret.likesCount++;
            //self.secret.iLikeIt = YES;
            self.likeButton.titleLabel.text = [NSString stringWithFormat:@"L%i",[self.secret.likes_count integerValue]+1];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
    
}

- (IBAction)commentSecret:(UIButton *)sender {
}

- (IBAction)otherActions:(id)sender {
    UIActionSheet *as;
    if ([self.secret.author integerValue] == 1) {
        as = [[UIActionSheet alloc]initWithTitle:@"Otras cosas" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Borrar Secreto" otherButtonTitles:@"Guardar imagen", @"Denunciar imagen", nil];
    } else {
        as = [[UIActionSheet alloc]initWithTitle:@"Otras cosas" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Guardar imagen", @"Denunciar imagen", nil];
    }
    
    
    if ([[BeeUser sharedUser] isLoggedinFacebook]) {
        [as addButtonWithTitle:@"Compartir en Facebook"];
    }
    if ([[BeeUser sharedUser] isLoggedinTwitter]) {
        [as addButtonWithTitle:@"Compartir en Twitter"];
    }
    
    [as showInView:self.superview];
}

- (void)updateOutlets {
    NSString *content = self.secret.content;
    self.secretLabel.text = content;
    self.secretLabel.textAlignment = NSTextAlignmentCenter;
    self.secretLabel.textColor = [UIColor whiteColor];
    //self.secretLabel.layer.borderWidth = 1.0f;
    //self.secretLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.isFriendLabel.text = [NSString stringWithFormat:@"%i",[_secret.author integerValue]];
    /*
     switch ([_secret.author integerValue]) {
     case 0:
     self.isFriendLabel.text = @"";
     break;
     case 1:
     self.isFriendLabel.text = @"";
     break;
     case 2:
     self.isFriendLabel.text = @"F";
     break;
     case 3:
     self.isFriendLabel.text = @"FoF";
     break;
     default:
     self.isFriendLabel.text = @"";
     break;
     }
     */
    self.commentButton.titleLabel.text = [NSString stringWithFormat:@"C%i",[self.secret.comments_count integerValue]];
    self.likeButton.titleLabel.text = [NSString stringWithFormat:@"L%i",[self.secret.likes_count integerValue]];
    self.backgroundColor = self.secret.color;
    self.secretLabel.font = self.secret.font;
    
    [self setDarkColor:self.secret.color];
    [self setColor:self.secret.color];
    self.bottomBorder.backgroundColor = self.darkColor;
    [self setNeedsLayout];
    [self layoutSubviews];
}

- (void)setSecret:(Secret *)secret {
    _secret = secret;
    [self updateOutlets];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    /*
    CGSize maxSize = CGSizeMake(LABEL_WIDTH, LABEL_MAXIMUM_HEIGHT);
    CGSize requiredSize = [self.secretLabel sizeThatFits:maxSize];
    requiredSize.width = LABEL_WIDTH;
    if (requiredSize.height < LABEL_MINIMUM_HEIGHT) {
        requiredSize.height = LABEL_MINIMUM_HEIGHT;
    } else if (requiredSize.height > LABEL_MAXIMUM_HEIGHT) {
        requiredSize.height = LABEL_MAXIMUM_HEIGHT;
    }
    self.secretLabel.frame = CGRectMake(self.secretLabel.frame.origin.x, self.secretLabel.frame.origin.y, requiredSize.width, requiredSize.height);
    self.requiredCellHeight = 20.0f + requiredSize.height + 30.0f + 6.0f + 8.0f;
     */
}

#pragma mark - Action Sheet Delegate

- (void)saveImageInPhotoLibrary {
    UIView *view = [[UIView alloc]initWithFrame:self.frame];
    view.backgroundColor = self.backgroundColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.frame = self.secretLabel.frame;
    label.text = self.secretLabel.text;
    label.textColor = self.secretLabel.textColor;
    label.font = self.secretLabel.font;
    label.numberOfLines = 20;
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    //CGFloat screenScale = [[UIScreen mainScreen] scale];
    //NSLog(@"%g,%g",view.frame.size.width,view.frame.size.height);
    //view.transform = CGAffineTransformScale(CGAffineTransformIdentity, screenScale, screenScale);
    //NSLog(@"%g,%g",view.frame.size.width,view.frame.size.height);
    UIGraphicsBeginImageContext(view.frame.size);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
    });
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ((buttonIndex == 0 && [self.secret.author integerValue] != 1) ||
        (buttonIndex == 1 && [self.secret.author integerValue] == 1)) {
        [self saveImageInPhotoLibrary];
    } else if (buttonIndex == 0 && [self.secret.author integerValue] == 1) {
        [[BeeSyncEngine sharedEngine]startDeletingSecret:self.secret];
    }
}

@end
