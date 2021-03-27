//
//  HandEvaluator.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 7/19/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HandEvaluator.h"

@implementation HandEvaluator

+(NSArray<HandEvaluation*>*)evaluatePokerHand:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {

    // Sort the cards from highest to lowest, so that it shakes out to find the most valuable cards
    NSArray *sortedHand = [self sortHandByRank:hand];
    
    // Go hand by hand, evaluating the chance of each one
    NSMutableArray<HandEvaluation*>* evaluations = [[NSMutableArray alloc] init];
    
    /*
    RoyalFlush = 1,
    StraightFlush,
    FourOfAKind,
    FullHouse,
    Flush,
    Straight,
    ThreeOfAKind,
    TwoPair,
    Pair,
    None
     */
    
    HandEvaluation* royalFlush = [HandEvaluator isRoyalFlush:hand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([royalFlush probability] > 0.0) [evaluations addObject:royalFlush];
    
    HandEvaluation* straightFlush = [HandEvaluator isStraightFlush:sortedHand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([straightFlush probability] > 0.0) [evaluations addObject:straightFlush];
    
    HandEvaluation* fourOfAKind = [HandEvaluator isFourOfAKind:sortedHand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([fourOfAKind probability] > 0.0) [evaluations addObject:fourOfAKind];
    
    HandEvaluation* fullHouse = [HandEvaluator isFullHouse:sortedHand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([fullHouse probability] > 0.0) [evaluations addObject:fullHouse];
    
    HandEvaluation* flush = [HandEvaluator isFlush:sortedHand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([flush probability] > 0.0) [evaluations addObject:flush];
    
    HandEvaluation* straight = [HandEvaluator isStraight:sortedHand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([straight probability] > 0.0) [evaluations addObject:straight];
    
    HandEvaluation* threeOfAKind = [HandEvaluator isThreeOfAKind:sortedHand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([threeOfAKind probability] > 0.0) [evaluations addObject:threeOfAKind];
    
    HandEvaluation* twoPair = [HandEvaluator isTwoPair:sortedHand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([twoPair probability] > 0.0) [evaluations addObject:twoPair];
    
    HandEvaluation* pair = [HandEvaluator isPair:sortedHand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    if ([pair probability] > 0.0) [evaluations addObject:pair];
    
    return evaluations;
}

#pragma mark Compare and rank hands that have been evaluated

+(HandEvaluation*)selectLikeliestHandEvaluation:(NSArray<HandEvaluation*>*)evaluations {
    if (!evaluations || [evaluations count] == 0) {
        return nil;
    }
    
    // This just takes the first most likely one in the list. Obviously other parts of the game can compare the full set and go for better but riskier hands over safer and cheaper ones
    HandEvaluation* bestEvaluation = [evaluations firstObject];
    
    for(HandEvaluation* eval in evaluations) {
        if ([eval probability] > [bestEvaluation probability]) {
            bestEvaluation = eval;
        }
    }
    
    return bestEvaluation;
}

+(HandEvaluation*)getFinalRankingOfHand:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards {
    NSArray<HandEvaluation*>* evaluations = [HandEvaluator evaluatePokerHand:hand wildCards:countOfWildCards unknownCards:@[] handSize:(int)[hand count] + countOfWildCards];
    
    // Evaluations are returned in order from most valuable type to least, so the first one that has a probability of 1.0 is returned
    for (HandEvaluation* evaluation in evaluations) {
        if ([evaluation probability] == 1.0) return evaluation;
    }
    
    // The user has nothing; return whatever they've got in case it outranks somebody else's garbage
    return [[HandEvaluation alloc] init:1.0 type:NoRank cardsToKeep:hand cardsToReject:@[]];
}

// Sort hands in descending order, from best to worst
+(NSArray<HandEvaluation*>*)sortHandsByRank:(NSArray<HandEvaluation*>*)hands {
    // Check to make sure we actually have a parameter
    if (!hands || [hands count] == 0) return @[];

    NSMutableArray<HandEvaluation*>* sortedHands = [[NSMutableArray alloc] initWithArray:hands];
    
    int sortCount = 0;
    
    bool isSorted = false;
    while (!isSorted && sortCount < 100) {
        if (sortCount == 90) {
            NSError* error = [[NSError alloc] initWithDomain:kHGPErrorDomain code:kHGPErrorCodeProgrammingError userInfo:@{@"sortHandsByRank ran over 90 times":sortedHands}];
            [CrashlyticsKit recordError:error];
        }
        sortCount++;    // This is a fallback, just in case the loop gets stuck ... which it shouldn't ...
        isSorted = true;
        for (int i = 0; i < [sortedHands count] - 1; i++) {
            NSComparisonResult comparison = [self compareHand:sortedHands[i] toHand:sortedHands[i+1]];
            if (comparison == NSOrderedAscending) {
                [sortedHands exchangeObjectAtIndex:i+1 withObjectAtIndex:i];
                isSorted = false;
            }
            else if (comparison == NSOrderedSame) {
                // FIXME: Handle ties by splitting the pot
            }
        }
    }
    
    return sortedHands;
}


+(NSComparisonResult)compareHand:(HandEvaluation*)handA toHand:(HandEvaluation*)handB {
    // This is a little counterintuitive, but if the type is lower (e.g. first in the enum), it is actually higher in the rankings that we want to produce (where we list the hands from most valuable to least)
    if ([handA type] < [handB type]) return NSOrderedDescending;
    
    if ([handA type] == [handB type]) {
        switch([handA type]) {
            case RoyalFlush:
                // The keeper cards are going to be the same, so compare the kicker cards
                return [self compareKickerCardsFromHand:handA toKickerCardsFromHand:handB];
            case FullHouse:
            case TwoPair:
                return [self compareHandWithMultipleSetsOfMatchingCards:handA againstAnotherHandOfSameType:handB];
            case Flush:
                return [self compareAFlush:handA withAnotherFlush:handB];
            case StraightFlush:
            case Straight:
                return [self compareHandsWithSeriesOfCards:handA and:handB];
            case FourOfAKind:
            case ThreeOfAKind:
            case Pair:
                return [self compareNofAKindHandsBetween:handA and:handB]; 
            case NoRank:
            default:
                // If it's just junk, rank it, kicker by kicker.
                // We can assume that wild cards don't matter here because if we had any, the hand would at least be a Pair
                return [self compareKickerCards:[handA cardsToKeep] toKickerCards:[handB cardsToKeep]];
        }
    }
    
    // Default
    return NSOrderedAscending;
}

// Compare a flush
+(NSComparisonResult)compareAFlush:(HandEvaluation*)handA withAnotherFlush:(HandEvaluation*)handB {
    // When comparing two flushes, the highest cards in each sequence are compared, then in the case of a tie, we go to the next highest cards.
    
    // First, who has more wild cards in their flush?
    // FIXME: This isn't a great method - the player without wild cards could still have an Ace of their own
    if ([handA wildCardsUsed] != [handB wildCardsUsed]) {
        return [handA wildCardsUsed] > [handB wildCardsUsed] ? NSOrderedDescending : NSOrderedAscending;
    }
    
    // Next, try to compare the keeper cards in the style of kicker cards
    NSComparisonResult result = [self compareKickerCards:[handA cardsToKeep] toKickerCards:[handB cardsToKeep]];
    if (result == NSOrderedSame) {
        // Now compare the reject cards - but use the compareKickerCardsWithHand method so that any left-over wild cards are factored in
        result = [self compareKickerCardsFromHand:handA toKickerCardsFromHand:handB];
    }
    
    return result;
}

// Compare a straight or straight flush
+(NSComparisonResult)compareHandsWithSeriesOfCards:(HandEvaluation*)handA and:(HandEvaluation*)handB {
    // Basically we know which type these cards are, so there's no reason to check for a straight flush vs a plain straight. We just have to find the higher-valued hand

    int highCardRankA = [self findHighCardRankInStraight:handA];
    int highCardRankB = [self findHighCardRankInStraight:handB];
    if (highCardRankA != highCardRankB) {
        return highCardRankA > highCardRankB ? NSOrderedDescending : NSOrderedAscending;
    }
    else  {
        // If that doesn't work, compare the reject cards - but use the compareKickerCardsWithHand method so that any left-over wild cards are factored in
        return [self compareKickerCardsFromHand:handA toKickerCardsFromHand:handB];
    }
}

// Finds the highest card in a straight. Takes into account the wild cards that were used to form the straight and checks if they can be the high card(s)
+(int)findHighCardRankInStraight:(HandEvaluation*)hand {
    NSArray<Card*>* cardsInStraight = [self sortHandByRank:[hand cardsToKeep]];
    
    // FIXME: We're making an assumption about taking the wildCardsRemaining because we know that findAStraight doesn't know how to make use of them. Fix that in the other method so that we're not doing this hack
    int wildCardsAvailable = [hand wildCardsUsed] + [hand wildCardsRemaining];
    
    // If there are no wild cards, then just grab the highest card
    int naturalHighCardRank = [[cardsInStraight firstObject] rank];
    if (0 == wildCardsAvailable) return naturalHighCardRank;
    
    // Otherwise, see how high the wild cards can take us, maxing out at an Ace. 
    int wildCardsUsedInsideSequence = ([[cardsInStraight firstObject] rank] - [[cardsInStraight lastObject] rank]) + 1 - (int)[cardsInStraight count];
    
    wildCardsAvailable -= wildCardsUsedInsideSequence;
    int wildHighCardRank = naturalHighCardRank;
   
    while (wildHighCardRank <= 14 && wildCardsAvailable > 0) {
        wildHighCardRank++;
        wildCardsAvailable--;
    }
 
    return wildHighCardRank;
}

// Compare a hand that has two sets of matching cards - for example, a Full House, or Two Pair
+(NSComparisonResult)compareHandWithMultipleSetsOfMatchingCards:(HandEvaluation*)handA againstAnotherHandOfSameType:(HandEvaluation*)handB {
    // This method assumes that the cardsToKeep in each hand include cards of two ranks
    NSArray<NSArray<Card*>*>* groupedHandA = [self groupCardsOfTwoRanks:[handA cardsToKeep]];
    NSArray<NSArray<Card*>*>* groupedHandB = [self groupCardsOfTwoRanks:[handB cardsToKeep]];
    
    // The groups were sorted by groupCardsOfTwoRanks. So first compare the first group ...
    NSComparisonResult result = [self rankArraysOfMatchingCards:groupedHandA[0] and:groupedHandB[0]];
    
    if (result == NSOrderedSame) {
        // ... if that doesn't work, go with the second group ...
       result = [self rankArraysOfMatchingCards:groupedHandA[1] and:groupedHandB[1]];
        if (result == NSOrderedSame) {
            // ... and finally, go through the kicker cards, factoring in any wild cards left over from all these other evaluations
            result = [self compareKickerCardsFromHand:handA toKickerCardsFromHand:handB];
        }
    }
 
    return result;
}

// Sort an array of cards into two groups of matching ranks. The larger or more valuable group is the first in the array (so, a trips comes before a pair, or a more valuable pair comes before a less valuable one)
+(NSArray<NSArray<Card*>*>*)groupCardsOfTwoRanks:(NSArray<Card*>*)hand {
    if (!hand || [hand count] < 2) return nil;
    
    NSArray<Card*>* sortedHand = [self sortHandByRank:hand];
    int rank1 = [[hand firstObject] rank];
    int rank2 = [[hand lastObject] rank];
    
    NSMutableArray<Card*>* setOne = [[NSMutableArray alloc] init];
    NSMutableArray<Card*>* setTwo = [[NSMutableArray alloc] init];
    
    for (Card* c in sortedHand) {
        if ([c rank] == rank1) [setOne addObject:c];
        else if ([c rank] == rank2) [setTwo addObject:c];
        else {
            NSError* error = [[NSError alloc] initWithDomain:kHGPErrorDomain code:kHGPErrorCodeProgrammingError userInfo:@{@"hand":sortedHand}];
            [CrashlyticsKit recordError:error];
            return nil;
        }
    }
    
    // Always lead with the larger set (for example for a Full House, return the trips before the pair)
    if ([setOne count] != [setTwo count])
    {
        if ([setOne count] > [setTwo count]) return @[setOne, setTwo];
        else return @[setTwo, setOne];
    }
    
    // They're the same size (for example, Two Pair) - return the more valuable group first. To avoid making assumptions about the size of each group, just grab one card from each for comparison
    Card* groupOneCard = [setOne firstObject];
    Card* groupTwoCard = [setTwo firstObject];
    
    if ([groupOneCard rank] > [groupTwoCard rank]) {
        return @[setOne, setTwo];
    }
    else {
        return @[setTwo, setOne];
    }
}

// A helper method to compare two arrays that each contain cards of the same rank. For example, to compare a Pair to a Pair, or Trips to Trips. The method makes no assumption about how many cards are in each array - it just compares a sample card from each and returns the result
+(NSComparisonResult)rankArraysOfMatchingCards:(NSArray<Card*>*)groupA and:(NSArray<Card*>*)groupB {
    Card* groupACard = [groupA firstObject];
    Card* groupBCard = [groupB firstObject];
    
    // If one card is higher than the other, then just compare them
    if ([groupACard rank] != [groupBCard rank]) {
        return [groupACard rank] > [groupBCard rank] ? NSOrderedDescending : NSOrderedAscending;
    }
    
    return NSOrderedSame;
}

// Compare two n of a kind hands (e.g. pair hands, or four of a kind hands)
+(NSComparisonResult)compareNofAKindHandsBetween:(HandEvaluation*)handA and:(HandEvaluation*)handB {
    // There must be at least one card to keep for each one - we can't determine this solely using wild cards. So let's go with that
    if ([[handA cardsToKeep] count] > 0 && [[handB cardsToKeep] count] > 0) {
        NSComparisonResult result = [self rankArraysOfMatchingCards:[handA cardsToKeep] and:[handB cardsToKeep]];
       
        if (result != NSOrderedSame) return result;
        
        // If the hands have the same rank, and we already determined (factoring in wild cards) that they have the same type, then compare the kicker cards
        else {
            return [self compareKickerCardsFromHand:handA toKickerCardsFromHand:handB];
        }
    }

    //  I don't know why this would even have happened but a fallback is to go straight to the kicker cards
    return [self compareKickerCardsFromHand:handA toKickerCardsFromHand:handB];
}

// Compare the kicker cards of two hands in the context of the whole hand - so, we can also evaluate the wild cards
+(NSComparisonResult)compareKickerCardsFromHand:(HandEvaluation*)handA toKickerCardsFromHand:(HandEvaluation*)handB {
    // FIXME: This isn't a safe assumption, the other player could have an Ace in their kicker cards. Need a more refined way of working down the list and treating wild cards as real cards while we go - "Okay, I've got a wild, do you have an Ace? Okay, next ... "
    
    // If either hand has more wild cards left than the other, we can use those wild cards as kicker cards and they guarantee a win - e.g. if I have two wild cards left and you have one, I win with an assumed 2 Aces
    if (handA.wildCardsRemaining > handB.wildCardsRemaining) return NSOrderedDescending;
    else if (handA.wildCardsRemaining < handB.wildCardsRemaining) return NSOrderedDescending;
    else {
        return [self compareKickerCards:[handA cardsToReject] toKickerCards:[handB cardsToReject]];
    }
}

// Compare two sets of non-wild kicker cards
+(NSComparisonResult)compareKickerCards:(NSArray<Card*>*)handA toKickerCards:(NSArray<Card*>*)handB {
    // Sort the kickers ...
    NSArray<Card*>* sortedKickerCardsA = [self sortHandByRank:handA];
    NSArray<Card*>* sortedKickerCardsB = [self sortHandByRank:handB];
    
    // ... and go one by one comparing them. Either one will beat another or we keep going and find a tie
    for (int i = 0; i < [sortedKickerCardsA count] && i < [sortedKickerCardsB count]; i++) {
        NSComparisonResult comparison = [[NSNumber numberWithInt:[sortedKickerCardsA[i] rank]] compare:[NSNumber numberWithInt:[sortedKickerCardsB[i] rank]]];
        if (comparison != NSOrderedSame) return comparison;
    }
    
    // Nope. The kickers are the same
    return NSOrderedSame;
}

#pragma mark Flush and Straight tests

+(HandEvaluation*)isRoyalFlush:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    int drawOpportunities = totalHandSize - (int)[hand count] - countOfWildCards;
    if (drawOpportunities < 0) drawOpportunities = 0;
    
    NSString* filter = @"rank > 9";
    NSPredicate* predicate = [NSPredicate predicateWithFormat:filter];
    NSArray* eligibleCards = [hand filteredArrayUsingPredicate:predicate];
    if ([eligibleCards count] > 0) {
        // Get a sequence of each suit
        NSMutableArray* candidateSequences = [[NSMutableArray alloc] init];
        for (int i = 1; i <= 4; i++) {
            NSString* filter = @"suit == %ld";
            NSPredicate* predicate = [NSPredicate predicateWithFormat:filter, (Suit)i];
            NSArray* sequence = [eligibleCards filteredArrayUsingPredicate:predicate];
            
            if (sequence && [sequence count] > 0) [candidateSequences addObject:sequence];
        }
        
        if ([candidateSequences count] > 0) {
            NSArray* longestSequence;
            
            for(NSArray* sequence in candidateSequences) {
                if (!longestSequence || [longestSequence count] < [sequence count]) longestSequence = sequence;
            }
            
            // And now we have the likeliest sequence of cards. Hey: actually, are we done?
            if ([longestSequence count] + countOfWildCards >= 5)  {
                // Note: If we weren't going for the top five cards, we would check if longestSequence might have six or more cards and might need to be trimmed down
                int wildCardsUsed = 5 - (int)[longestSequence count];
                if (wildCardsUsed < 0) wildCardsUsed = 0;
                int wildCardsRemaining = countOfWildCards - wildCardsUsed;
                
                return [[HandEvaluation alloc] init:1.0 type:RoyalFlush cardsToKeep:longestSequence cardsToReject:[HandEvaluator setAsideCardsToReject:hand cardsToKeep:longestSequence] wildCardsUsed:wildCardsUsed wildCardsRemaining:wildCardsRemaining];
            }
            // Check if we have enough cards to fill the gaps, and if so, we have a match - it's just a question of what the odds are of getting it
            if (drawOpportunities + [longestSequence count] >= 5) {
                longestSequence = [self sortHandByRank:longestSequence];
                
                // ... and identify which cards we're missing.
                // Get the suit we're trying to match
                Suit suit = [[longestSequence firstObject] suit];
                
                NSMutableArray* missingCards = [[NSMutableArray alloc] init];
                for (int i = 10; i <= 14; i++) {
                    NSString* filter = @"rank == %ld";
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:filter, i];
                    NSArray* matchingCard = [hand filteredArrayUsingPredicate:predicate];
                    if ([matchingCard count] == 0) {
                        [missingCards addObject:[[Card alloc] initWithRank:i suit:suit]];
                    }
                }
                
                CGFloat probability = [HandEvaluator chanceToFindCards:missingCards unknownCards:unknownCards drawOpportunities:drawOpportunities wildCards:countOfWildCards ignoreSuit:NO];
                
                return [[HandEvaluation alloc] init:probability type:RoyalFlush cardsToKeep:longestSequence cardsToReject:[HandEvaluator setAsideCardsToReject:hand cardsToKeep:longestSequence]];
            }
        }
    }
    
    // Five wild cards with nothing else to latch onto will still come back as a Royal Flush
    if (countOfWildCards >= 5) {
          return [[HandEvaluation alloc] init:1.0 type:RoyalFlush cardsToKeep:@[] cardsToReject:[hand copy] wildCardsUsed:5 wildCardsRemaining:5 - countOfWildCards];
    }

    // If all else failed, return a zilched evaluation
    return [[HandEvaluation alloc] init:0.0 type:RoyalFlush cardsToKeep:@[] cardsToReject:[hand copy]];
}

+(HandEvaluation*)isStraightFlush:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    return [self findStraight:hand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize ignoreSuit:NO type:StraightFlush];
}

+(HandEvaluation*)isStraight:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    return [self findStraight:hand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize ignoreSuit:YES type:Straight];
}

+(HandEvaluation*)isFlush:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    int numberOfMatchesSought = 5; // Must have 5 for a flush
    
    float probability = 0.0f;
    
    Suit bestSuit = [self getMostCommonSuit:hand];

    // Do we already have the hand we need?
    int currentMatchCount = 0;

    for (Card* c1 in hand) {
        if ([c1 suit] == bestSuit) currentMatchCount++;
    }
    
    currentMatchCount += countOfWildCards;
    
    if (currentMatchCount >= numberOfMatchesSought) {
        probability = 1.0f;
    }
    
    // If not, what are the odds of getting it?
    if (probability < 1.0f) {
        // Find the most likely match based on the cards we have now and the cards that are still out there. Again, go card by card ... and consider that the suit with the best odds is not the one that we currently have the most cards in (e.g. if you have 2 Diamonds and 1 Club, there may be far more Clubs out there; also, you might have 1 Diamond and 1 Club, and the Diamond originally came back as the better suit because it was a higher card)
        for (Card* c1 in hand) {
            int matchCount = 0;
            for (Card* c2 in hand) {
                if ([c1 suit] == [c2 suit]) matchCount++;
            }
            
            matchCount += countOfWildCards;
            
            // How many more cards does this suit need - and how many of them are still out there?
            int remainingCardsNeeded = numberOfMatchesSought - matchCount;
            
            int availableCards = 0;
            for (Card* c0 in unknownCards) {
                if ([c1 suit] == [c0 suit]) {
                    availableCards++;
                }
            }
            
            // How many more cards can we draw?
            int drawOpportunities = totalHandSize - (int)[hand count] - countOfWildCards;
            if (drawOpportunities < 0) drawOpportunities = 0;
            
            if (availableCards > 0 && availableCards >= remainingCardsNeeded) {
                float currentProbability = [HandEvaluator calculateProbabilityOfDraws:availableCards unknownCards:(int)[unknownCards count] drawOpportunities:drawOpportunities remainingCardsNeeded:remainingCardsNeeded];
                if (currentProbability > probability) {
                    // This is the best match so far
                    bestSuit = [c1 suit];
                    probability = currentProbability;
                }
            }
        }
    }
    
    // Return the evaluation
    HandEvaluation* evaluation;
    
    if (probability > 0) {
        // Make an array of the matching cards and the discard-able cards
        NSMutableArray* cardsToKeep = [[NSMutableArray alloc] init];
        NSMutableArray* cardsToReject = [[NSMutableArray alloc] init];
        
        for (Card* c1 in hand) {
            if ([c1 suit] == bestSuit) [cardsToKeep addObject:c1];
            else [cardsToReject addObject:c1];
        }
        
        // Deduce how many wild cards were used by how far cardsToKeep falls short. The assumption is that we will use all available cards until we run out
        int wildCardsUsed = numberOfMatchesSought - (int)[cardsToKeep count];
        if (wildCardsUsed > countOfWildCards) wildCardsUsed = countOfWildCards;
        
        // ... and if we didn't even use all of the wild cards, then keep track of the remainder
        int wildCardsRemaining = countOfWildCards - wildCardsUsed;
        
        evaluation = [[HandEvaluation alloc] init:probability type:Flush cardsToKeep:cardsToKeep cardsToReject:cardsToReject wildCardsUsed:wildCardsUsed wildCardsRemaining:wildCardsRemaining];
    }
    else {
        // There is no chance of a match
        evaluation = [[HandEvaluation alloc] init:probability type:Flush cardsToKeep:@[] cardsToReject:[hand copy]];
    }
    
    return evaluation;
}

#pragma mark N of a kind

+(HandEvaluation*)isFourOfAKind:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    return [HandEvaluator findNOfAKind:4 type:FourOfAKind hand:hand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
}

+(HandEvaluation*)isFullHouse:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    int wildCardsRemaining = countOfWildCards;
    HandEvaluation* trips = [HandEvaluator findNOfAKind:3 type:ThreeOfAKind hand:hand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    HandEvaluation* pair = nil;
    
    // Only check for a pair if we have a shot at trips
    if (trips && [trips probability] > 0.0f) {
        // To get the trips, we may have used a number of wild cards. This can be detected if trips has a 100% probability but fewer than three cards. The trips is more important than the pair, so we will exhaust the wild cards on that first, and then the pairs can take what they want
        wildCardsRemaining -= [trips wildCardsUsed];
        if (wildCardsRemaining <= 0) wildCardsRemaining = 0;
        
        pair = [HandEvaluator findNOfAKind:2 type:Pair hand:trips.cardsToReject wildCards:wildCardsRemaining unknownCards:unknownCards handSize:totalHandSize - 3];
        
        // If we have a shot at a pair, update how many wild cards we've gone through
        if (pair && [pair probability] > 0.0f) {
            wildCardsRemaining -=  [pair wildCardsUsed];
            if (wildCardsRemaining <= 0) wildCardsRemaining = 0;
        }
    }
    
    if (trips && pair) {
        CGFloat probability = [trips probability] * [pair probability];
        
        NSMutableArray* completeHand = [[NSMutableArray alloc] init];
        [completeHand addObjectsFromArray:[trips cardsToKeep]];
        [completeHand addObjectsFromArray:[pair cardsToKeep]];
        
        return [[HandEvaluation alloc] init:probability type:FullHouse cardsToKeep:completeHand cardsToReject: [pair cardsToReject] wildCardsUsed:countOfWildCards - wildCardsRemaining wildCardsRemaining:wildCardsRemaining];
    }
    else {
        return [[HandEvaluation alloc] init:0.0f type:FullHouse cardsToKeep:@[] cardsToReject:hand];
    }
}

+(HandEvaluation*)isThreeOfAKind:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    return [HandEvaluator findNOfAKind:3 type:ThreeOfAKind hand:hand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
}

+(HandEvaluation*)isPair:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    return [HandEvaluator findNOfAKind:2 type:Pair hand:hand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
}

+(HandEvaluation*)isTwoPair:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    int wildCardsRemaining = countOfWildCards;
    
    HandEvaluation* firstPair = [HandEvaluator findNOfAKind:2 type:Pair hand:hand wildCards:countOfWildCards unknownCards:unknownCards handSize:totalHandSize];
    HandEvaluation* secondPair = nil;
    
    // To get the first pair, we may have used a number of wild cards. This can be detected if the first pair has a 100% probability but fewer than two cards. The trips is more important than the pair, so we will exhaust the wild cards on that first, and then the pairs can take what they want
    if (firstPair && [firstPair probability] == 1.0) {
        wildCardsRemaining -= [firstPair wildCardsUsed];
        if (wildCardsRemaining == 0) wildCardsRemaining = 0;
    }
    
    if (firstPair && [firstPair probability] > 0.0f) {
        secondPair = [HandEvaluator findNOfAKind:2 type:Pair hand:firstPair.cardsToReject wildCards:wildCardsRemaining unknownCards:unknownCards handSize:totalHandSize - 2];
        if ([secondPair probability] > 0.0f) {
            wildCardsRemaining -= [secondPair wildCardsUsed];
            if (wildCardsRemaining == 0) wildCardsRemaining = 0;
        }
    }
    
    if (firstPair && secondPair) {
        // TODO Validate this approach to probability
        CGFloat probability = [firstPair probability] * [secondPair probability];
        
        NSMutableArray* completeHand = [[NSMutableArray alloc] init];
        [completeHand addObjectsFromArray:[firstPair cardsToKeep]];
        [completeHand addObjectsFromArray:[secondPair cardsToKeep]];
        
        return [[HandEvaluation alloc] init:probability type:TwoPair cardsToKeep:completeHand cardsToReject: [secondPair cardsToReject] wildCardsUsed:countOfWildCards - wildCardsRemaining wildCardsRemaining:wildCardsRemaining];
    }
    else {
        return [[HandEvaluation alloc] init:0.0f type:TwoPair cardsToKeep:@[] cardsToReject:hand];
    }
}

#pragma mark Helper Methods

+(HandEvaluation*)findStraight:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize ignoreSuit:(bool)ignoreSuit type:(HandType)type {
    
    CGFloat probability = 0.0f;
    NSArray* bestSequence = @[];
    
    // Find the possible straights
    NSArray<NSArray<Card*>*>* sequences = [self findPossibleStraights:hand ignoreSuit:ignoreSuit handSize:totalHandSize];
 
    // Do we already have a straight?
    
    // FIXME: Do we need to pay attention to suit here if we already did in findPossibleStraights?
    for(NSArray<Card*>* sequence in sequences) {
        if ([sequence count] + countOfWildCards >= 5) {
            if (ignoreSuit) {
                probability = 1.0f;
                bestSequence = sequence;
                break;
            }
            else {
                Suit suit = [[sequence firstObject] suit];
                bool isFlush = true;
                for (Card* c in sequence) {
                    if ([c suit] != suit) {
                        isFlush = false;
                        break;
                    }
                }
                
                if (isFlush) {
                    probability = 1.0f;
                    bestSequence = sequence;
                    break;
                }
            }
        }
    }
    
    // If not, find the likeliest one
    if (probability < 1.0f) {
        NSArray<Card*>* bestPartialSequence = @[];
        CGFloat probabilityForBestPartialSequence = 0.0f;

        for (NSArray<Card*>* sequence in sequences) {
            NSMutableArray<NSNumber*>* probabilitiesOfCompletingThisSequence = [[NSMutableArray alloc] init];
            
            // Calculate our draw opportunities
            int drawOpportunities = totalHandSize - (int)[hand count] - countOfWildCards;
            if (drawOpportunities < 0) drawOpportunities = 0;
            
            NSArray<NSArray<Card*>*>* cardsToCompleteSequence = [self findCardsToCompleteStraight:sequence drawOpportunities:drawOpportunities countOfCardsNeeded:(5 - countOfWildCards)];
            
            for (NSArray<Card*>* cards in cardsToCompleteSequence) {
                CGFloat probabilityOfFindingCardsToCompleteSequence = [self chanceToFindCards:cards unknownCards:unknownCards drawOpportunities:drawOpportunities wildCards:countOfWildCards ignoreSuit:ignoreSuit];
                [probabilitiesOfCompletingThisSequence addObject:[NSNumber numberWithFloat:probabilityOfFindingCardsToCompleteSequence]];
            }
            
            CGFloat cumulativeProbabilityForThisSequence = [HandEvaluator accumulateProbabilites:probabilitiesOfCompletingThisSequence];
            if (cumulativeProbabilityForThisSequence > probabilityForBestPartialSequence) {
                // There is the new best partial sequence
                bestPartialSequence = sequence;
                probabilityForBestPartialSequence = cumulativeProbabilityForThisSequence;
            }
        }
        
        // http://www.pokerology.com/lessons/drawing-odds/ ?
        
        // Now use the winner (if there is one; if not, we're still at 0.0 and an empty array)
        probability = probabilityForBestPartialSequence;
        bestSequence = bestPartialSequence;
    }
    
    HandEvaluation* evaluation;
    
    NSArray<Card*>* cardsToReject = [HandEvaluator setAsideCardsToReject:hand cardsToKeep:bestSequence];
    
    // We will exhaust the wild cards we've got, and may still not have enough to reach five cards
    int wildCardsUsed = 5 - (int)[bestSequence count];
    if (wildCardsUsed < 0) wildCardsUsed = 0;
    else if (wildCardsUsed > countOfWildCards) wildCardsUsed = countOfWildCards;
    
    // FIXME: So here's the problem - you won't necessarily have any wild cards left, because unless you hit an Ace, you could always use wild cards to get a better high card. So ... address that
    int wildCardsRemaining = countOfWildCards - wildCardsUsed;
    
    evaluation = [[HandEvaluation alloc] init:probability type:type cardsToKeep:bestSequence cardsToReject:cardsToReject wildCardsUsed:wildCardsUsed wildCardsRemaining:wildCardsRemaining];
    
    return evaluation;
}

// Finds all possible sequences of cards from the given hand. This evalues consecutive cards as well as sequences that have gaps (e.g. given 5, 6, 8, and 9, what are your odds of completing a straight with a 7, or a 3 and 4, or a 10, J and Q
+(NSArray<NSArray<Card*>*>*)findPossibleStraights:(NSArray<Card*>*)hand ignoreSuit:(bool)ignoreSuit handSize:(int)totalHandSize {
    NSMutableArray* sequences = [[NSMutableArray alloc] init];
    
    // We assume the hand was sorted because we're sitting here looking at the code

    if (!ignoreSuit) {
        // Split the hand up by suit and for each case where we have more than two of a suit, look for possible straights
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"suit"
                                                     ascending:YES];
        NSArray* handSortedBySuit = [hand sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        Suit currentSuit = [[handSortedBySuit firstObject] suit];
        NSMutableArray* currentHand = [[NSMutableArray alloc] init];
        for (Card* c in handSortedBySuit) {
            // We're in the same suit
            if (currentSuit == [c suit]) {
                [currentHand addObject:c];
            }
            // ... or we moved on to the next one
            else {
                if ([currentHand count] > 1) {
                    // Call this method recursively to find a straight for each suit
                    [sequences addObjectsFromArray:[self findPossibleStraightsinHand:currentHand handSize:totalHandSize]];
                }
                
                currentHand = [[NSMutableArray alloc] init];
                [currentHand addObject: c];
                currentSuit = [c suit];
            }
        }
        
        // Cleanup
        if ([currentHand count] > 1) {
            // Call this method recursively but with ignoreSuit set to yes
            [sequences addObjectsFromArray:[self findPossibleStraightsinHand:currentHand handSize:totalHandSize]];
        }
    }
    
    else {
         [sequences addObjectsFromArray:[self findPossibleStraightsinHand:hand handSize:totalHandSize]];
    }

    
    return sequences;
}

// Helper method to findPossibleStraights
// Note: This method does not worry about suits, as it assumes the method that calls it has already done any filtering by suit
+(NSArray<NSArray<Card*>*>*)findPossibleStraightsinHand:(NSArray<Card*>*)hand handSize:(int)totalHandSize {
    NSMutableArray<NSMutableArray<Card*>*>* sequences = [[NSMutableArray alloc] init];
    // Now get the sequences that have gaps. Basically look for every range of cards that are up to five apart and add them to the pile
    int count = (int)[hand count];
    for (int i = 0; i < count - 1; i++) {
        NSMutableArray* potentialSequence = [[NSMutableArray alloc] init];
        
        // Find what will be the highest card in the potential sequence (for example, 10)
        Card* rootCard = hand[i];
        
        // Always add the root card to the sequence
        [potentialSequence addObject:rootCard];
        
        // Look through the rest of the cards in the hand, and if any of them are within four cards of the first one (for example, 9 through 6, but not 5). Also ignore cards of the same rank
        // TODO: If you have a choice of three 7s, go for the one that is of the most common suit in your hand. For example, if every other card is a Hearts, pick the 7 that is also a Hearts, since it is most likely to pay off later. Yeah?
        for (int j = i + 1; j < count; j++) {
            Card* thisCard = hand[j];
            Card* previousCard = hand[j - 1];
            if ([thisCard rank] != [previousCard rank] && [rootCard rank] - [thisCard rank] < 5) {
                [potentialSequence addObject:thisCard];
                
                // If we just added the last card in the hand to this sequence, then stop looking for more potential sequences - we just worked our way through the hand. (If we don't interrupt it this way, then we'll keep finding sequences that are just a subset of this one)
                if ([thisCard rank] == [[hand lastObject] rank]) {
                    i = count;
                    j = count;
                }
            }
        }
        
        // We're going to cut this off so that the potential sequence has at least 2 cards. Arguably it should be 3
        if ([potentialSequence count] > 1) {
            [sequences addObject:potentialSequence];
        }
    }
    
    return sequences;
}

// Note: This method doesn't worry about suit, because we're assuming that any sequence it gets is already organized by suit if necessary
+(NSArray<NSArray<Card*>*>*)findCardsToCompleteStraight:(NSArray<Card*>*)sequence drawOpportunities:(int)drawOpportunities countOfCardsNeeded:(int)countOfCardsNeeded {
    // Can we even draw enough cards to complete a straight?
    if (!sequence || ([sequence count] + drawOpportunities) < countOfCardsNeeded) return @[];
    
    // Iterate through the combination of cards before and after the sequence that we could use to form the full sequence that we need. Remember that the ranks go from 1 (Ace) to 13 (King)
    // TODO: Or, ace can be at the other end ... ? Shit
    Card* lowCard = [sequence lastObject];
    Card* highCard = [sequence firstObject];
    
    int span = ([highCard rank] - [lowCard rank]) + 1; // For example, if the sequence runs from 4 to 7, the span is 4
    int overhang = 5 - span;                            // If it's 4 to 7, we need 1 surrounding card
    
    // Identify the gap cards. Then find the separate surrounding cards. Then assemble every combination of them
    NSMutableArray<Card*>* availablePrecedingCards = [[NSMutableArray alloc] init];
    NSMutableArray<Card*>* availableFollowingCards = [[NSMutableArray alloc] init];
    NSMutableArray<Card*>* gapCards = [[NSMutableArray alloc] init];
    
    // Find the cards that we will need before and/or after this sequence
    if (overhang > 0) {
        // Get the lower surrounding cards
        int lowestRank = [lowCard rank] - overhang >= 1 ? [lowCard rank] - overhang : 1;
        for (int i = lowestRank; i < [lowCard rank]; i++) {
            Card* c = [[Card alloc] initWithRank:i suit:[lowCard suit]];    // Arbitrarily using the low card's suit
            [availablePrecedingCards addObject:c];
        }
        
        // ... and the higher ones
        int highestRank = [highCard rank] + overhang <= 14 ? [highCard rank] + overhang : 14;
        for (int i = [highCard rank] + 1; i <= highestRank; i++) {
            Card* c = [[Card alloc] initWithRank:i suit:[highCard suit]];   // Arbitrarily using the high card's suit
            [availableFollowingCards addObject:c];
        }
    }
    
    // Find the gap cards
    int rank = [highCard rank];

    for (Card* c in sequence) {
        while ([c rank] < rank) {
            Card* c = [[Card alloc] initWithRank:rank suit:[lowCard suit]];
            [gapCards addObject:c];
            rank--;
        }
        
        rank--;
    }
    
    // Put all of the cards that we could use in an array
    NSMutableArray<Card*>* cardsThatCompleteSequence = [[NSMutableArray alloc] init];
    [cardsThatCompleteSequence addObjectsFromArray:availablePrecedingCards];
    [cardsThatCompleteSequence addObjectsFromArray:gapCards];
    [cardsThatCompleteSequence addObjectsFromArray:availableFollowingCards];
    
    // Now form an array from each combination of cards to complete the sequence
    NSMutableArray<NSArray<Card*>*>* cardCombinationsThatCompleteSequence = [[NSMutableArray alloc] init];
    
    int cardsNeeded = 5 - (int)[sequence count];
    
    for (int i = 0; i <= [cardsThatCompleteSequence count] - cardsNeeded; i++) {
        NSIndexSet* range = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, cardsNeeded)];
        NSArray<Card*>* completingSequence = [cardsThatCompleteSequence objectsAtIndexes:range];
        [cardCombinationsThatCompleteSequence addObject:completingSequence];
    }
    
    return cardCombinationsThatCompleteSequence;
}

+(HandEvaluation*)findNOfAKind:(int)numberOfMatchesSought type:(HandType)type hand:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    float probability = 0.0f;
    
    int bestRank = -1;

    // Do we already have the hand we need?
    for (Card* c1 in hand) {
        int matchCount = 0;
        
        for (Card* c2 in hand) {
            if ([c1 rank] == [c2 rank])  matchCount++;
        }
        
        matchCount += countOfWildCards;
        
        if (matchCount >= numberOfMatchesSought) {
            probability = 1.0f;
            bestRank = [c1 rank];
            break;
        }
    }
    
    // If not, what are the odds of getting it?
    if (probability < 1.0f) {
        // Find the most likely match based on the cards we have now and the cards that are still out there. Again, go card by card ...
        for (Card* c1 in hand) {
            int matchCount = 0;
            for (Card* c2 in hand) {
                if ([c1 rank] == [c2 rank]) matchCount++;
            }
            
            matchCount += countOfWildCards;
            
            // How many more cards does this rank need - and how many of them are still out there?
            int remainingCardsNeeded = numberOfMatchesSought - matchCount;
            
            int availableCards = 0;
            for (Card* c0 in unknownCards) {
                if ([c1 rank] == [c0 rank]) {
                    availableCards++;
                }
            }
            
            // How many more cards can we draw?
            int drawOpportunities = totalHandSize - (int)[hand count] - countOfWildCards;
            if (drawOpportunities < 0) drawOpportunities = 0;
            
            if (availableCards > 0 && availableCards >= remainingCardsNeeded) {
                float currentProbability = [HandEvaluator calculateProbabilityOfDraws:availableCards unknownCards:(int)[unknownCards count] drawOpportunities:drawOpportunities remainingCardsNeeded:remainingCardsNeeded];
                if (currentProbability > probability) {
                    // This is the best match so far
                    bestRank = [c1 rank];
                    probability = currentProbability;
                }
            }
        }
    }
    
    HandEvaluation* evaluation;
 
    if (bestRank > -1) {
        // Make an array of the matching cards and the discard-able cards. Only keep as many cards as we need for the match (e.g. if we're looking for a pair, only keep 2 cards, even if there are 3 or more matches)
        NSMutableArray* cardsToKeep = [[NSMutableArray alloc] init];
        NSMutableArray* cardsToReject = [[NSMutableArray alloc] init];
        
        for (Card* c1 in hand) {
            if ([c1 rank] == bestRank && [cardsToKeep count] < numberOfMatchesSought) [cardsToKeep addObject:c1];
            else [cardsToReject addObject:c1];
        }
        
        // Deduce how many wild cards were used by how far cardsToKeep falls short. The assumption is that we will use all available cards until we run out
        int wildCardsUsed = numberOfMatchesSought - (int)[cardsToKeep count];
        if (wildCardsUsed > countOfWildCards) wildCardsUsed = countOfWildCards;
        
        // ... and if we didn't even use all of the wild cards, then keep track of the remainder
        int wildCardsRemaining = countOfWildCards - wildCardsUsed;
        
        evaluation = [[HandEvaluation alloc] init:probability type:type cardsToKeep:cardsToKeep cardsToReject:cardsToReject wildCardsUsed:wildCardsUsed wildCardsRemaining:wildCardsRemaining];
    }
    else {
        // There is no chance of a match
        evaluation = [[HandEvaluation alloc] init:probability type:type cardsToKeep:@[] cardsToReject:[hand copy]];
    }
    
    return evaluation;
}

#pragma mark Probability helper methods

// Chance to find the specific cards needed out of the remaining cards
+(float)chanceToFindCards:(NSArray<Card*>*)cardsNeeded unknownCards:(NSArray<Card*>*)unknownCards drawOpportunities:(int)drawOpportunities wildCards:(int)countOfWildCards ignoreSuit:(bool)ignoreSuit {
    
    // Make sure it's not trying to find more cards than we have a chance to get
    if (drawOpportunities < [cardsNeeded count]) return 0.0f;
    
    int countOfCardsToFind = (int)[cardsNeeded count] - countOfWildCards;
    if (countOfCardsToFind <= 0) return 1.0f;
    
    int countOfUnknownCards = (int)[unknownCards count];
    
    CGFloat probability = 1.0f;
    
    for (Card* c1 in cardsNeeded) {
        int availableCards = 0;
        for (Card* c0 in unknownCards) {
            if (ignoreSuit) {
                if ([c1 rank] == [c0 rank]) {
                    availableCards++;
                }
            } else {
                if ([c1 isEqual:c0]) {
                    availableCards++;
                }
            }
        }

        if (availableCards > 0) {
            CGFloat distinctProbability = [HandEvaluator calculateProbabilityOfDraw:availableCards unknownCards:countOfUnknownCards drawOpportunities:drawOpportunities];
            
            probability = probability * distinctProbability;
            
            // TODO: Does this make sense? If I have three chances to get the first card, I only have two to get the second, right? And if I need three cards and only have two chances then I'm sunk anyway ...
            drawOpportunities--;
            
            // We just found a card - so that's one fewer unknown card
            countOfUnknownCards--;
            
            // If we've found enough cards (say, we need three but we have one wildcard, so we really only need two), then stop here
            countOfCardsToFind--;
            if (countOfCardsToFind < 1) break;
        }
        else {
            probability = 0.0f;
            break;
        }
    }
    
    return probability;
}

// Given the number of cards that you need that are in the deck or otherwise not revealed, calculate the odds of finding one of those cards based on the size of the deck and the number of attempts available
+(CGFloat)calculateProbabilityOfDraw:(int)availableCards unknownCards:(int)unknownCards drawOpportunities:(int)drawOpportunities {
    // Just to make sure: If there are no draw opportunities, or no available or unknown cards, there is no chance
    if (drawOpportunities <= 0 || availableCards <= 0 || unknownCards <= 0) return 0.0f;
    
    CGFloat probability = 1.0f - pow((1.0f - (CGFloat)availableCards / (CGFloat)unknownCards), drawOpportunities);
    return probability;
}

// Calculates the probability of finding all of the cards you need to complete a hand
+(CGFloat)calculateProbabilityOfDraws:(int)availableCards unknownCards:(int)unknownCards drawOpportunities:(int)drawOpportunities remainingCardsNeeded:(int)remainingCardsNeeded {
    CGFloat probability = [self calculateProbabilityOfDraw:availableCards unknownCards:unknownCards drawOpportunities:drawOpportunities];
    for (int i = 1; i < remainingCardsNeeded; i++) {
        // There are less cards to choose from, and less opportunities to choose ...
        drawOpportunities--;
        unknownCards--;
        availableCards--;
        
        probability *= [self calculateProbabilityOfDraw:availableCards unknownCards:unknownCards drawOpportunities:drawOpportunities];
    }
    
    return probability;
}

// If there are a few ways to get the hand you want, accumulate those probabilities
+(CGFloat)accumulateProbabilites:(NSArray<NSNumber*>*) a {
    if (!a || [a count] == 0) return 0.0f;
 
    CGFloat cumulativeProbabilities = 1.0f;
    for(NSNumber* n in a) {
        cumulativeProbabilities *= 1.0 - [n floatValue];
    }
    
    return 1.0 - cumulativeProbabilities;
}

// Helper method to quickly identify, given a set of cards to keep from a hand, which are the cards to reject
+(NSArray<Card*>*)setAsideCardsToReject:(NSArray<Card*>*)hand cardsToKeep:(NSArray<Card*>*)cardsToKeep {
    if ([hand count] == [cardsToKeep count]) return @[];
    NSMutableArray<Card*>* cardsToReject = [[NSMutableArray alloc] init];
    for (Card* c in hand) {
        bool isReject = true;
        for (Card* c1 in cardsToKeep) {
            if ([c isEqual:c1]) {
                isReject = false;
                break;
            }
        }
        
        if (isReject) [cardsToReject addObject:c];
    }
    
    return cardsToReject;
}

# pragma mark Hand sorting methods

// Sort a hand by rank, from highest to lowest
+(NSArray<Card*>*)sortHandByRank:(NSArray<Card*>*)hand {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                 ascending:NO];
    return [hand sortedArrayUsingDescriptors:@[sortDescriptor]];
}

// Sort by suit (really, group by suit)
+(NSArray<Card*>*)sortHandBySuit:(NSArray<Card*>*)hand {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"suit"
                                                 ascending:YES];
    return [hand sortedArrayUsingDescriptors:@[sortDescriptor]];
}

// Get the value of the cards that make up a hand. This method should only take the cards that are relevant to the hand type - for example, if it's a three of a kind, it should only get the three cards we need
+(NSNumber*)getSimpleValueOfHand:(NSArray<Card*>*)cards {
    int value = 0;
    for (Card* c in cards) {
        value += [c rank];
    }
    
    return [NSNumber numberWithInt:value];
}

+(Suit)getMostCommonSuit:(NSArray<Card*>*)hand {
    // Sort the cards by hand ...
    NSMutableDictionary* suits = [[NSMutableDictionary alloc] init];
    for (Card* c in hand) {
        NSNumber* suit = [NSNumber numberWithInt:[c suit]];
        if (suits[suit])
        {
            [(NSMutableArray*)suits[suit] addObject:c];
        }
            else {
                NSMutableArray<Card*>* cards = [[NSMutableArray alloc] init];
                [cards addObject: c];
                [suits setObject:cards forKey:suit];
            }
    }
    
    // ... and find the most common suit
    NSMutableArray<Card*>* cardsInMostCommonSuit = [[NSMutableArray alloc] init];
    
    for (id key in suits) {
        NSMutableArray<Card*>* cards = suits[key];
        if ([cards count] > [cardsInMostCommonSuit count]) cardsInMostCommonSuit = cards;
        
        // If two suits have the same number of cards, go with the one that has a higher overall ranking
        else if ([cards count] == [cardsInMostCommonSuit count]) {
            // We'll go with the compareKickerCards because it finds the highest card going card by card
            // TODO: The sorting is probably unnecessary because this came in sorted by rank, but it feels safer
            if ([self compareKickerCards:[self sortHandByRank:cards] toKickerCards:[self sortHandByRank:cardsInMostCommonSuit]] == NSOrderedDescending) {
                cardsInMostCommonSuit = cards;
            }
        }
    }
    
    return [[cardsInMostCommonSuit firstObject] suit];
}

#pragma mark Low hands

+(HandEvaluation*)evaluateLowPokerHand:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards unknownCards:(NSArray<Card*>*)unknownCards handSize:(int)totalHandSize {
    int drawOpportunities = totalHandSize - (int)[hand count] - countOfWildCards;
    if (drawOpportunities < 0) drawOpportunities = 0;
    
    // Prune the candidate hand down to a set of unique cards that are 8s or below
    // TODO: Use the getLowHandCards method, and then figure out from what we took which cards to put in cardsToReject
    NSMutableArray* filteredHand = [[NSMutableArray alloc] init];
    NSMutableArray* cardsToReject = [[NSMutableArray alloc] init];
    for (Card* c in hand) {
        // Make sure we only keep one card of each rank
        bool isDuplicate = false;
        for (Card* cd in filteredHand) {
            if ([c rank] == [cd rank]) {
                isDuplicate = true;
                break;
            }
        }
        
        // If it's good, take it - and on the way in, convert the Ace to a low card
        if (!isDuplicate && ([c rank] < 9 || [c rank] == 14)) {
            [filteredHand addObject:[[Card alloc] initWithRank:([c rank] == 14 ? 1 : [c rank]) suit:[c suit]]];
        }
        else [cardsToReject addObject:c];
    }
    
    // Sort the filtered hand so that we'll end up working with the lowest cards
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                 ascending:YES];
    filteredHand = [[filteredHand sortedArrayUsingDescriptors:@[sortDescriptor]] copy];
    
    // If we have any cards at all ...
    if ([filteredHand count] > 0) {
            // And now we have the likeliest sequence of cards. Hey: actually, are we done?
            if ([filteredHand count] == 5)  {
                return [[HandEvaluation alloc] init:1.0 type:NoRank cardsToKeep:filteredHand cardsToReject:cardsToReject];
            }
        // Check if we have enough cards to fill the gaps, and if so, we have a match - it's just a question of what the odds are of getting it
        // FIXME: Obviously the longest sequence may not be the best one ... have to take that into account, and maybe just return all of the options. (A complete 8-7 may not be as good as an almost-complete wheel).
        if (drawOpportunities + [filteredHand count] >= 5) {
            
            NSMutableArray* missingCards = [[NSMutableArray alloc] init];
            int countOfCardsNeeded = 5 - (int)[filteredHand count];
            for (int i = 1; i < 9 && [missingCards count] < countOfCardsNeeded; i++) {
                NSString* filter = @"rank == %ld";
                NSPredicate* predicate = [NSPredicate predicateWithFormat:filter, i == 14 ? 1 : i];
                NSArray* matchingCard = [filteredHand filteredArrayUsingPredicate:predicate];
                if ([matchingCard count] == 0) {
                    // Look for one of each suit
                    [missingCards addObject:[[Card alloc] initWithRank:i suit:Hearts]]; // Arbitrary suit
                }
            }
            
            // FIXME: This will probably end up going for the lowest cards. What about higher cards that still complete a valid low hand? Do we even care? Maybe this is fine for now
            CGFloat probability = [HandEvaluator chanceToFindCards:missingCards unknownCards:unknownCards drawOpportunities:drawOpportunities wildCards:countOfWildCards ignoreSuit:YES];
            
            return [[HandEvaluation alloc] init:probability type:NoRank cardsToKeep:filteredHand cardsToReject:cardsToReject];
        }
    }
    
    // If all else failed, return a zilched evaluation
    return [[HandEvaluation alloc] init:0.0 type:NoRank cardsToKeep:@[] cardsToReject:[filteredHand copy]];
}

+(NSArray<Card*>*)getLowHandCards:(NSArray<Card*>*)hand {
    NSMutableArray<Card*>* filteredHand = [[NSMutableArray alloc] init];
    for (Card* c in hand) {
        // Make sure we only keep one card of each rank
        bool isDuplicate = false;
        for (Card* cd in filteredHand) {
            // When checking for a duplicate, note that 1 and 14 are both Aces
            if ([c rank] == [cd rank] || ([c rank] == 1 && [cd rank] == 14) || ([c rank] == 14 && [cd rank] == 1)) {
                isDuplicate = true;
                break;
            }
        }
        
        // If it's good, take it - and on the way in, convert the Ace to a low card
        if (!isDuplicate && ([c rank] < 9 || [c rank] == 14)) {
            [filteredHand addObject:[[Card alloc] initWithRank:([c rank] == 14 ? 1 : [c rank]) suit:[c suit]]];
        }
    }
    
    return [filteredHand copy];
}

+(int)getFinalLowHandValue:(NSArray<Card*>*)hand wildCards:(int)countOfWildCards {
    // Pare the hand down to valid low cards (8 or lower)
    NSMutableArray<Card*>* lowHandCards = [[NSMutableArray alloc] initWithArray:[HandEvaluator getLowHandCards:hand]];
    
    if (lowHandCards && ([lowHandCards count] + countOfWildCards) >= 5) {
        // Apply the wild cards to get the best possible low hand.
        // After some basic research it seems that the wild cards are always best used by filling in the Wheel (5, then 4, then 3, etc.), because at worst yrouou bring in some lower cards in the second or third place, and at best, you get closer to having your five cards actually form the Wheel. So that's what we'll do
        for (int i = 5; i > 0 && countOfWildCards > 0; i--) {
            bool hasCardWithThisRank = false;
            for (Card* c in lowHandCards) {
                if ([c rank] == i) {
                    hasCardWithThisRank = true;
                }
            }
            
            if (!hasCardWithThisRank) {
                Card* wildCardPlacement = [[Card alloc] initWithRank:i suit:Diamonds];
                [lowHandCards addObject:wildCardPlacement];
                countOfWildCards--;
            }
        }
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                     ascending:YES];
        lowHandCards = [NSMutableArray arrayWithArray:[lowHandCards sortedArrayUsingDescriptors:@[sortDescriptor]]];
        
        // If we have too many, remove the last ones (which are presently the higher numbers - e.g. we could have 1234568, so lop off 6 and 8)
        if ([lowHandCards count] > 5) {
            [lowHandCards removeObjectsInRange: NSMakeRange(5, [lowHandCards count] - 5)];
        }
        
        // And now create the result integer (e.g. 54321 or 76321 or what have you)
        int result = 0;
        int place = 1;
        for (Card* c in lowHandCards) {
            result += [c rank] * place;
            place *= 10;
        }
        
        return result;
    }
    else {
        return -1;
    }
}

@end

