//
//  Secret+Bee.m
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Secret+Bee.h"

@implementation Secret (Bee)

+ (NSArray *)colors {
    static NSArray *colors;
    if (colors) {
        return colors;
    }
    colors = @[[UIColor turquoiseColor], [UIColor emerlandColor], [UIColor peterRiverColor], [UIColor amethystColor], [UIColor wetAsphaltColor], [UIColor carrotColor], [UIColor sunflowerColor], [UIColor alizarinColor], [UIColor concreteColor]];
    return colors;
}

+ (NSArray *)fonts {
    static NSArray *fonts;
    if (fonts) {
        return fonts;
    }
    fonts = [UIFont secretsFonts];
    return fonts;
}

- (UIColor *)color {
    NSArray *ar = [self.about componentsSeparatedByString:@","];
    if (ar.count == 2) {
        return [Secret colors][[ar[0] intValue]];
    } else {
        return [Secret colors][0];
    }
}

- (UIFont *)font {
    NSArray *ar = [self.about componentsSeparatedByString:@","];
    if (ar.count == 2) {
        return [Secret fonts][[ar[1] intValue]];
    } else {
        return [Secret fonts][0];
    }
}

@end
