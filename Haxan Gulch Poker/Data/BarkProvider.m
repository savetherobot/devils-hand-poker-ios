//
//  BarkProvider.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/16/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "BarkProvider.h"

@implementation BarkProvider

+(NSString*)getBarkForTrigger:(BarkTrigger)trigger andPlayer:(Player*)player {
    // FIXME: In this first implementation, we won't actually use the player

    switch(trigger) {
        case AceyDeuceyGulch:
            if ([self doesBarkTrigger:0.7]) return @"Durnit, the gulch!";
            break;
        case AceyDeuceyWideSpread:
            if ([self doesBarkTrigger:0.7]) return @"Could drive a mighty herd of cattle through there.";
            break;
        case AceyDeuceyPossibleTrips:
            if ([self doesBarkTrigger:0.7]) return @"I smells me some trips!";
            break;
        case AnacondaTrashPassed:
            if ([self doesBarkTrigger:0.1]) return @"Yup, you passed the trash.";
            break;
        default:
            return @"";
    }
    
    return @"";
}

+(bool)doesBarkTrigger:(CGFloat)oddsOfTriggering {
    int r = arc4random_uniform(100);
    return (r <= oddsOfTriggering * 100);
}

@end
