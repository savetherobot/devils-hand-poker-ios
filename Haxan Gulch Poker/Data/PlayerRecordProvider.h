//
//  PlayerRecordProvider.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/15/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPProvider.h"
#import "PlayerRecord.h"

@interface PlayerRecordProvider : NSObject

/**
 Retrieve the player's winnings to date (across the lifetime of the game)

 @return The winnings to date
 */
+(int)getWinningsToDate;

/**
 Set the player's winnings to date (across the lifetime of the game). Typically the game would use addWinnings to add (or subtract) a discrete amount, rather than setting the value outright

 @param winningsToDate The winnings to date
 */
+(void)setWinningsToDate:(int)winningsToDate;

/**
 Add the specified winnings to the player's winnings to date (for example, from a hand that the player just won)

 @param winnings The amount that the player just won
 */
+(void)addWinnings:(int)winnings;

+(void)updateHighestRoomUnlocked:(int)highestRoom;

+(bool)isGameUnlocked;

+(void)unlockGameForPlayer;

+(PlayerRecord*)fetchPlayerRecord;

+(void)updatePlayerRecord:(PlayerRecord*)playerRecord;

@end
