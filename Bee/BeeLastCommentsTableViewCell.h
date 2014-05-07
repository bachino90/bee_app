//
//  BeeLastCommentsTableViewCell.h
//  Bee
//
//  Created by Emiliano Bivachi on 05/05/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BeeLastCommentsTableViewCell;

@protocol BeeLastCommentsTableViewCellDelegate  <NSObject>
- (void)searchOldComments:(BeeLastCommentsTableViewCell *)cell;
@end

@interface BeeLastCommentsTableViewCell : UITableViewCell

@property (nonatomic, weak) id <BeeLastCommentsTableViewCellDelegate> delegate;

- (void)restartCell;

@end
