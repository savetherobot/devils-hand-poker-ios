//
//  HandEvaluator.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 7/19/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Card.h"
#import "HandEvaluation.h"

@interface HandEvaluator : NSObject

/**
 Evaluate the specified poker hand and return a set of evaluations that represents every possible type of hand that the player has a chance to make (e.g., if there is a non-zero chance that with the cards in hand and the ones they can still draw, they could form this type of hand)
 */
+(NSArray<HandEvaluation*>*)evaluatePokerHand:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize;

/**
 Out of a set of evaluations, identify the best one. This is a crude method right now, that is best used against partial hands to find the one that's most likely to turn up
 */
+(HandEvaluation*)selectLikeliestHandEvaluation:(NSArray<HandEvaluation*>*)evaluations;

/**
 At the end of a game, find the best rank of hand that the player has formed
 */
+(HandEvaluation*)getFinalRankingOfHand:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards;

/**
 Given a set of hands, sort them by rank; if multiple hands have the same rank, sort them against themselves by card values
 */
+(NSArray<HandEvaluation*>*)sortHandsByRank:(NSArray<HandEvaluation*>*)hands;

+(NSComparisonResult)compareHand:(HandEvaluation*)handA toHand:(HandEvaluation*)handB;

/**
 Evaluate the specified poker hand and return an evaluation that represents the best low hand the player can make
 */
+(HandEvaluation*)evaluateLowPokerHand:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize;

/**
 A method to filter a hand and return the cards that could be used to make a low hand

 @param hand A partial or complete hand
 @return An array of cards with discrete ranks that qualify for a low hand
 */
+(NSArray<Card*>*)getLowHandCards:(NSArray<Card*>*)hand;

/**
 Get the low hand value of this hand by taking the lowest cards in the specified hand (with Ace == 1) and returning them as integer, e.g, 64321, or 65432, or 84321. This can be directly compared to the low hand value of any other HandEvaluation. If there is no valid low hand (e.g. we can't find five unique ranks that are 8 or below), this method returns -1. Note that this only reflects the current cards in hand and doesn't work well on a partial hand
 
 @param hand    The hand to evaluate. This should not include the wild cards that are getting counted later
 @param countOfWildCards    How many wild cards can we use?
 @return An int representing the low hand value, or a -1 if there is no valid low hand
 */
+(int)getFinalLowHandValue:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards;

/** Finds the highest card in a straight. Takes into account the wild cards that were used to form the straight and checks if they can be the high card(s)
 */
+(int)findHighCardRankInStraight:(HandEvaluation*)hand;


@end
