//
//  UIFont+Bee.m
//  Bee
//
//  Created by Emiliano Bivachi on 12/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "UIFont+Bee.h"

@implementation UIFont (Bee)

+ (UIFont *)beeFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Quicksand-Regular" size:size];
}

+ (NSArray *)secretsFonts {
    CGFloat size = 30.0;
    NSArray *fonts = @[[UIFont airstreamFontWithSize:size],[UIFont alexBrushFontWithSize:size],[UIFont bpscriptFontWithSize:25.0f],[UIFont capsuulaFontWithSize:size],[UIFont dinerRegularFontWithSize:40.0],[UIFont dosisLightFontWithSize:27.0f],[UIFont dosisExtraLightFontWithSize:27.0f],[UIFont dymaxionScriptFontWithSize:25.0f],[UIFont fingerPaintFontWithSize:24.0f],[UIFont frenteH1FontWithSize:size],[UIFont idolwildFontWithSize:28.0f],[UIFont impactLabelFontWithSize:23.0f],[UIFont impactLabelReversedFontWithSize:23.0f],[UIFont komikaFontWithSize:28.0f],[UIFont printClearlyFontWithSize:size],[UIFont printBoldFontWithSize:size],[UIFont quicksandFontWithSize:28.0f],[UIFont walkwayFontWithSize:size],[UIFont ostrichSansFontWithSize:size],[UIFont comfortaaRegularFontWithSize:size]];
    return fonts;
}

+ (UIFont *)airstreamFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Airstream" size:size];
}

+ (UIFont *)alexBrushFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AlexBrush-Regular" size:size];
}

+ (UIFont *)bpscriptFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"BPscript" size:size];
}

+ (UIFont *)capsuulaFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Capsuula" size:size];
}

+ (UIFont *)comfortaaRegularFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Comfortaa" size:size];
}

//no anda
+ (UIFont *)comfortaaThinFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Comfortaa-Thin" size:size];
}

+ (UIFont *)dinerRegularFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Diner-Regular" size:size];
}

+ (UIFont *)dosisLightFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Dosis-Light" size:size];
}

+ (UIFont *)dosisExtraLightFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Dosis-ExtraLight" size:size];
}

//no anda
+ (UIFont *)daypblFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"DAYPBL_" size:size];
}

//no anda
+ (UIFont *)deftoneFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"DEFTONE" size:size];
}

+ (UIFont *)dymaxionScriptFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"DymaxionScript" size:size];
}

+ (UIFont *)fingerPaintFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"FingerPaint-Regular" size:size];
}

+ (UIFont *)frenteH1FontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"FrenteH1-Regular" size:size];
}

+ (UIFont *)idolwildFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"idolwild" size:size];
}

+ (UIFont *)impactLabelFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Impact Label" size:size];
}

+ (UIFont *)impactLabelReversedFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Impact Label Reversed" size:size];
}

+ (UIFont *)komikaFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"KomikaTitle-Kaps" size:size];
}

//no anda
+ (UIFont *)newCicleFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"New Cicle Semi" size:size];
}

//no anda
+ (UIFont *)openSansFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"OpenSans" size:size];
}

+ (UIFont *)ostrichSansFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Ostrich Sans Inline" size:size];
}

//no anda
+ (UIFont *)porterSansFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"porter-sans-inline-block" size:size];
}

+ (UIFont *)printBoldFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"PrintBold" size:size];
}

+ (UIFont *)printClearlyFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"PrintClearly" size:size];
}

+ (UIFont *)quicksandFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Quicksand-Regular" size:size];
}

//no anda
+ (UIFont *)sevillanaFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Sevillana-Regular" size:size];
}

+ (UIFont *)walkwayFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Walkway SemiBold" size:size];
}

@end
