//
//  BetEvaluator.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 11/15/17.
//  Copyright © 2017 Round the Fire Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Card.h"
#import "HandEvaluator.h"
#import "HandEvaluation.h"

@interface BetEvaluator : NSObject

/**
 For a high-low game, assesses a set of hands, determines whether the AI will bet high, low or both, and then picks the winners. Returns a dictionary where the key is the HighLowBetType and the value is the player index of the winner of that hand type, or -1 if nobody won it
 
 @param players         The players who are betting in the game, including the human player
 @param playerBetType   The human player will already have specified their bet type coming into this method; the AIs' bets will be determined here
 @param wildCardRanks   The ranks of the wild card or cards in this game - e.g., 7s are wild, 12s (Queens) are wild
 */
+(NSDictionary*)evaluateHighLowAndBothWinners:(NSArray<Player*>*)players playerBetType:(HighLowBetType)playerBetType wildCardRanks:(NSArray<NSNumber*>*)wildCardRanks;

+(NSArray<Card*>*)getHandWithoutWildCards:(NSArray<Card*>*)hand wildCardRanks:(NSArray<NSNumber*>*)wildCardRanks;

@end
