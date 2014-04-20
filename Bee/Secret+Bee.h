//
//  Secret+Bee.h
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Secret.h"

@interface Secret (Bee)

+ (NSArray *)colors;
+ (NSArray *)fonts;

- (UIColor *)color;
- (UIFont *)font;

@end
