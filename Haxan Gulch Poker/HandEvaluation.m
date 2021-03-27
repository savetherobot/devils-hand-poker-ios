//
//  HandEvaluation.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 7/19/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HandEvaluation.h"
#import "HandEvaluator.h"

@implementation HandEvaluation : NSObject

- (instancetype)init:(float)p type:(HandType)t cardsToKeep:(NSArray<Card*>*)keep cardsToReject:(NSArray<Card*>*)reject {
    
    self = [super init];
    if(self) {
        self->probability = p;
        self->type = t;
        self->cardsToKeep = keep;
        self->cardsToReject = reject;
        self->wildCardsUsed = 0;
        self->wildCardsRemaining = 0;
    }
    
    return self;
}

- (instancetype)init:(float)p type:(HandType)t cardsToKeep:(NSArray<Card*>*)keep cardsToReject:(NSArray<Card*>*)reject wildCardsUsed:(int)wildCardsUsed wildCardsRemaining:(int)wildCardsRemaining {
    
    self = [self init:p type:t cardsToKeep:keep cardsToReject:reject];
    if (self) {
        self->wildCardsUsed = wildCardsUsed;
        self->wildCardsRemaining = wildCardsRemaining;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"Hand Evaluation: Type = %@ Probability = %f\nCards To Keep = %@ Cards To Reject = %@ Wild Cards Used = %d and Remaining = %d",  [[self getDisplayNameOfHandType] uppercaseString], probability, [cardsToKeep componentsJoinedByString:@", "], [cardsToReject componentsJoinedByString:@", "], wildCardsUsed, wildCardsRemaining];
}

- (NSString*)getDisplayNameOfHandType {
    return [HandEvaluation getDisplayNameOfHandType:type];
}

+ (NSString*)getDisplayNameOfHandType:(HandType)t {
    switch(t) {
        case RoyalFlush:
            return @"Royal Flush";
        case StraightFlush:
            return @"Straight Flush";
        case FourOfAKind:
            return @"Four of a Kind";
        case FullHouse:
            return @"Full House";
        case Flush:
            return @"Flush";
        case Straight:
            return @"Straight";
        case ThreeOfAKind:
            return @"Three of a Kind";
        case TwoPair:
            return @"Two Pair";
        case Pair:
            return @"Pair";
        default:
            return @"None";
    }
    
    return @"";
}

- (NSString*)getDisplayNameOfHandTypeForDisplayInASentence {
    return [HandEvaluation getDisplayNameOfHandTypeForDisplayInASentence:type];
}

+ (NSString*)getDisplayNameOfHandTypeForDisplayInASentence:(HandType)t {
    switch(t) {
        case RoyalFlush:
            return @"a Royal Flush";
        case StraightFlush:
            return @"a Straight Flush";
        case FourOfAKind:
            return @"Four of a Kind";
        case FullHouse:
            return @"a Full House";
        case Flush:
            return @"a Flush";
        case Straight:
            return @"a Straight";
        case ThreeOfAKind:
            return @"Three of a Kind";
        case TwoPair:
            return @"Two Pair";
        case Pair:
            return @"a Pair";
        default:
            return @"a whole bunch of nothing";
    }
    
    return @"";
}

-(float)probability { return probability; }
-(void)setProbability:(float)p { probability = p; };

-(HandType)type { return type; }
-(void)setType:(HandType)t { type = t; }

-(NSArray<Card*>*)cardsToKeep { return cardsToKeep; }
-(void)setCardsToKeep:(NSArray<Card*>*)cards { cardsToKeep = cards; }

-(NSArray<Card*>*)cardsToReject { return cardsToReject; }
-(void)setCardsToReject:(NSArray<Card*>*)cards { cardsToReject = cards; }

-(int)wildCardsUsed { return wildCardsUsed; }
-(void)setWildCardsUsed:(int)cards { wildCardsUsed = cards; }

-(int)wildCardsRemaining { return wildCardsRemaining; }
-(void)setWildCardsRemaining:(int)cards { wildCardsRemaining = cards; }

@end


