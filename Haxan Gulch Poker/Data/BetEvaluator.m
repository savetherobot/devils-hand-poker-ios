//
//  BetEvaluator.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 11/15/17.
//  Copyright © 2017 Round the Fire Entertainment. All rights reserved.
//

#import "BetEvaluator.h"

@implementation BetEvaluator

+(NSDictionary*)evaluateHighLowAndBothWinners:(NSArray<Player*>*)players playerBetType:(HighLowBetType)playerBetType wildCardRanks:(NSArray<NSNumber*>*)wildCardRanks {
    NSMutableArray<NSNumber*>* betTypes = [[NSMutableArray alloc] init];
    NSMutableArray<HandEvaluation*>* highHandEvaluations = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber*>* lowHandValues = [[NSMutableArray alloc] init];
    
    if (playerBetType != HighLowBetNone) {
        HandEvaluation* playerHighHandEvaluation = [self evaluateFinalPlayerHighHand:[players[0] hand] wildCardRanks:wildCardRanks];
        NSNumber* playerLowHandValue = [self evaluateFinalPlayerLowHand:[players[0] hand] wildCardRanks:wildCardRanks];
        
        // TODO: A little data object or dictionary would be a nice way to manage all this crap and keep it together with player indices ...
        [betTypes addObject:[NSNumber numberWithInteger:playerBetType]];
        [highHandEvaluations addObject:playerHighHandEvaluation];
        [lowHandValues addObject:playerLowHandValue];
    }
    
    // Okay. So what are the AIs going to do?
    for (int i = 1; i < [players count]; i++) {
        Player* player = players[i];
        HandEvaluation* highHandEvaluation = [self evaluateFinalPlayerHighHand:[player hand] wildCardRanks:wildCardRanks];
        NSNumber* lowHandValue = [self evaluateFinalPlayerLowHand:[player hand] wildCardRanks:wildCardRanks];
        
        // Default to a high hand
        HighLowBetType npcBetType = HighLowBetHigh;
        
        // If there's no valid low hand, the choice is made. Otherwise:
        if (-1 != [lowHandValue intValue]) {
            
            // If we get the wheel, take it. On average there are more high bets than low, so a sure-win low hand is an easy choice
            if ([lowHandValue intValue] == 54321) {
                // TODO: Are there any cases where the wheel is also a great contendor for high hand - maybe if it's a Flush? Or does that just open up too much craziness (e.g. the other two cards let us produce a Royal Flush, but only if we use wilds, and what if they're different than the wilds we used to make the Wheel ... )
                npcBetType = HighLowBetLow;
            }
            
            // A 7* low hand is probably better than a Pair
            else if ([lowHandValue intValue] > 70000 && [highHandEvaluation type] >= 9) {
                npcBetType = HighLowBetLow;
            }
            
            // If we get close to the wheel, take it and bet both ways
            else if ([lowHandValue intValue] == 65432 && (highHandEvaluation.type == Straight || highHandEvaluation.type == StraightFlush)) {
                // TODO: What if it's a Flush? That beats a Straight ... but is it too hard to figure out ...
                
                // Does the high hand match this?
                int highHandHighCardRank = [HandEvaluator findHighCardRankInStraight:highHandEvaluation];
                
                // TODO: Think about what this eliminates ... a 7? What if we still have a straight that has six cards in it? Hmmm ...
                if (highHandHighCardRank == 6) npcBetType = HighLowBetBoth;
                else npcBetType = HighLowBetLow;
                
                // FIXME: ... so ... I'm not convinced this really works. If you go for the low hand it should lock in your straight before we do comparisons ... I guess in this case, we're not betting unless it's already a very low straight, and the methods above account for the wild cards already. But for the human player we should lock in their wild cards.
            }
            
            // Finally, a 6* is better than anything less than a flush
            else if ([lowHandValue intValue] > 60000 && [highHandEvaluation type] >= 5) {
                npcBetType = HighLowBetLow;
            }
        }
        
        NSLog(@"HIGH-LOW: Player %@ goes with bet type %ld on hand %@", [players[i] name], (long)npcBetType, highHandEvaluation);
        
        [betTypes addObject:[NSNumber numberWithInteger:npcBetType]];
        [highHandEvaluations addObject:highHandEvaluation];
        [lowHandValues addObject:lowHandValue];
    }
    
    // Determine the actual winners, and divvy up the pot. If the pot doesn't divide evenly, the bigger half goes to the high card winner
    int indexOfPlayerWithBestHighHand = -1;
    int indexOfPlayerWithBestLowHand = -1;
    
    // We have to keep the players who are betting high and low in a separate batch, because they have to be evaluated at the end and they have to beat all comers
    NSMutableArray<NSNumber*>* playersWhoBetHighAndLow = [[NSMutableArray alloc] init];
    
    for (uint i = 0; i < [players count]; i++) {
        // Only count the players who are still in the game. (We could have eliminated them earlier, but that makes it harder to keep track of which player has which hand)
        if ([players[i] isStillInGame]) {
            HighLowBetType currentBetType = (HighLowBetType)[[betTypes objectAtIndex:i] integerValue];
            switch(currentBetType) {
                    // If the player is only betting low or high, then their hand is only in contention for one or the other type of hand. Even if it would win both (or lose the selected one but win the other one), too bad, we're only comparing it the way you wanted to bet
                case HighLowBetHigh: {
                    if (-1 == indexOfPlayerWithBestHighHand) indexOfPlayerWithBestHighHand = i;
                    else if ([HandEvaluator compareHand:[highHandEvaluations objectAtIndex:indexOfPlayerWithBestHighHand] toHand:[highHandEvaluations objectAtIndex:i]] == NSOrderedAscending) {
                        indexOfPlayerWithBestHighHand = i;
                    }
                    break;
                }
                case HighLowBetLow:{
                    if (-1 == indexOfPlayerWithBestLowHand) indexOfPlayerWithBestLowHand = i;
                    else {
                        if ([[lowHandValues objectAtIndex:indexOfPlayerWithBestLowHand] intValue] > [[lowHandValues objectAtIndex:i] intValue]) {
                            indexOfPlayerWithBestLowHand = i;
                        }
                    }
                    break;
                }
                default:
                case HighLowBetBoth: {
                    [playersWhoBetHighAndLow addObject:[NSNumber numberWithInteger:i]];
                    NSLog(@"%@ bets on high and low with %@", [players[i] name], [players[i] hand]);
                    // We have to evaluate "both" at the end, once we know the best high and low hands
                    break;
                }
            }
        }
    }
    
    int indexOfPlayerWithBestHighAndLowHand = -1;
    if ([playersWhoBetHighAndLow count] > 0) {
        for (NSNumber* playerIndex in playersWhoBetHighAndLow) {
            // First, make sure that the indices of the best high and low hands aren't empty. That's super unlikely but if every single player bets on a high and low hand, it could happen
            int contenderPlayerIndex = [playerIndex intValue];
            
            if ((-1 == indexOfPlayerWithBestHighHand || ([HandEvaluator compareHand:[highHandEvaluations objectAtIndex:indexOfPlayerWithBestHighHand] toHand:[highHandEvaluations objectAtIndex:contenderPlayerIndex]] == NSOrderedAscending))
                && (-1 == indexOfPlayerWithBestLowHand || [[lowHandValues objectAtIndex:indexOfPlayerWithBestLowHand] intValue] > [[lowHandValues objectAtIndex:contenderPlayerIndex] intValue])) {
                // We have a contender - this hand beat all the high and low hands. Is there another player who's doing well with the high and low hand?
                if (indexOfPlayerWithBestHighAndLowHand > -1) {
                    if ([HandEvaluator compareHand:[highHandEvaluations objectAtIndex:indexOfPlayerWithBestHighAndLowHand] toHand:[highHandEvaluations objectAtIndex:contenderPlayerIndex]] == NSOrderedAscending && [[lowHandValues objectAtIndex:indexOfPlayerWithBestLowHand] intValue] > [[lowHandValues objectAtIndex:contenderPlayerIndex] intValue]) {
                        // Yup, this is the best high-and-low-hand so far
                        indexOfPlayerWithBestHighAndLowHand = contenderPlayerIndex;
                    }
                }
                else {
                    indexOfPlayerWithBestHighAndLowHand = contenderPlayerIndex;
                }
            }
        }
    }
    
    NSString* namesOfPlayersWhoBetHighAndLow = [self concatenateNamesOfPlayersInList:players betTypes:betTypes whoBetType:HighLowBetBoth];
    
    NSDictionary* results = @{ kHGPIndexOfPlayerWithWinningHighHand : [NSNumber numberWithInt:indexOfPlayerWithBestHighHand],
                               kHGPIndexOfPlayerWithWinningLowHand : [NSNumber numberWithInt:indexOfPlayerWithBestLowHand],
                               kHGPIndexOfPlayerWithWinningHighAndLowHand : [NSNumber numberWithInt:indexOfPlayerWithBestHighAndLowHand],
                               kHGPWinningHighHandDescription : indexOfPlayerWithBestHighHand > -1 ? [highHandEvaluations[indexOfPlayerWithBestHighHand] getDisplayNameOfHandTypeForDisplayInASentence] : @"",
                               kHGPPlayersBettingHighAndLow : namesOfPlayersWhoBetHighAndLow
                               };
    
    return results;
}

// Return the final evaluation of the player's low hand as a number (e.g. 54321 or 87432), taking into account wild cards
+(NSNumber*)evaluateFinalPlayerLowHand:(NSArray<Card*>*)hand wildCardRanks:(NSArray<NSNumber*>*)wildCardRanks {
    // Pull out (and count) the wild cards
    NSArray<Card*>* handWithoutWildCards = [self getHandWithoutWildCards:hand wildCardRanks:wildCardRanks];
    int countOfWildCards = (int)([hand count] - [handWithoutWildCards count]);
    
    int lowHandValue = [HandEvaluator getFinalLowHandValue:handWithoutWildCards wildCards:countOfWildCards];
    
    return [NSNumber numberWithInt:lowHandValue];
}

// Return the final evaluation of a player's high hand, taking into account wild cards
+(HandEvaluation*)evaluateFinalPlayerHighHand:(NSArray<Card*>*)hand wildCardRanks:(NSArray<NSNumber*>*)wildCardRanks{
    NSArray<Card*>* handWithoutWildCards = [self getHandWithoutWildCards:hand wildCardRanks:wildCardRanks];
    int countOfWildCards = (int)([hand count] - [handWithoutWildCards count]);
    HandEvaluation* playerHandEvaluation = [HandEvaluator getFinalRankingOfHand:handWithoutWildCards wildCards:countOfWildCards];
    
    return playerHandEvaluation;
}

// Remove wild cards from a player's hand, for evaluation purposes
+(NSArray<Card*>*)getHandWithoutWildCards:(NSArray<Card*>*)hand wildCardRanks:(NSArray<NSNumber*>*)wildCardRanks {
    NSMutableArray<Card*>* handWithoutWildCards = [[NSMutableArray alloc] init];
    for (Card* c in hand) {
        bool isWildCard = false;
        for (NSNumber* wildCardRank in wildCardRanks) {
            if ([wildCardRank intValue] == [c rank]) {
                isWildCard = true;
                break;
            }
        }
        
        if (!isWildCard) {
            [handWithoutWildCards addObject:c];
        }
    }
    
    return handWithoutWildCards;
}

+(NSString*)concatenateNamesOfPlayersInList:(NSArray<Player*>*)players betTypes:(NSArray<NSNumber*>*)playerBetTypes whoBetType:(HighLowBetType)requiredBetType {
    NSMutableArray<NSString*>* names = [[NSMutableArray alloc] init];
    for (int i = 0; i < [playerBetTypes count]; i++) {
        if ([players[i] isStillInGame] && [playerBetTypes[i] intValue] == requiredBetType) {
            [names addObject:[players[i] name]];
        }
    }
    
    if ([names count] == 0) return @"";
    else if ([names count] == 1) return names[0];
    else if ([names count] == 2) return [NSString stringWithFormat:@"%@ and %@", names[0], names[1]];
    else {
        NSMutableString* namesList = [[NSMutableString alloc] init];
        for (int i = 0; i < [names count] - 1; i++) {
            [namesList appendString:[NSString stringWithFormat:@"%@, ", names[i]]];
        }
        
        [namesList appendString:[NSString stringWithFormat:@"and %@", [names lastObject]]];
        
        return namesList;
    }
}


@end
