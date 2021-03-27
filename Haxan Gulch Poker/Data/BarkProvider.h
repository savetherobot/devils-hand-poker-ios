//
//  BarkProvider.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/16/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#include <stdlib.h>
#import <Foundation/Foundation.h>
#import "Player.h"

typedef enum {
    AceyDeuceyWideSpread,
    AceyDeuceyGulch,
    AceyDeuceyPossibleTrips,
    AnacondaTrashPassed,
    DayBaseballFold,
    DayBaseballBrag
} BarkTrigger;

@interface BarkProvider : NSObject

+(NSString*)getBarkForTrigger:(BarkTrigger)trigger andPlayer:(Player*)player;

@end
