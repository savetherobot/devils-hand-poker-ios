//
//  UIFont+Extensions.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/16/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "UIFont+Extensions.h"

@implementation UIFont (Extensions)

+ (UIFont *)fontForBody
{
    return [UIFont fontWithName:@"Baskerville-SemiBold" size:15.0f];
}

+ (UIFont *)fontForButton {
    if (CGRectGetWidth([[UIScreen mainScreen] bounds]) <= 480) {
        return [UIFont fontWithName:@"Baskerville-SemiBold" size:15.0f];
    }
    else if (CGRectGetWidth([[UIScreen mainScreen] bounds]) <= 568) {
        return [UIFont fontWithName:@"Baskerville-SemiBold" size:16.0f];
    }
    else {
        return [UIFont fontWithName:@"Baskerville-SemiBold" size:18.0f];
    }
}

+ (UIFont *)fontForLargeLabel {
    if (CGRectGetWidth([[UIScreen mainScreen] bounds]) <= 480) {
        return [UIFont fontWithName:@"Baskerville-SemiBold" size:19.0f];
    }
    else if (CGRectGetWidth([[UIScreen mainScreen] bounds]) <= 568) {
        return [UIFont fontWithName:@"Baskerville-SemiBold" size:20.0f];
    }
    else {
        return [UIFont fontWithName:@"Baskerville-SemiBold" size:22.0f];
    }
}

+ (UIFont *)fontForGiantButton {
    return [UIFont fontWithName:@"Baskerville-SemiBold" size:30.0f];
}

@end

