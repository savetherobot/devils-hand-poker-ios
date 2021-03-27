//
//  HandEvaluation.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 7/19/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "Card.h"
#import "Enums.h"

@interface HandEvaluation : NSObject
{
    // 0.0 means no chance; 1.0 means the hand is already formed; a number in between is the likelihood of finishing this hand (e.g. you have three cards that are the same; you have a 1.0 chance of a three of a kind, but a certain chance of a four of a kind)
    float probability;
    
    // The type of hand in this evaluation
    HandType type;
    
    // You should keep these cards ...
    NSArray<Card*>* cardsToKeep;
    
    // ... these, you can get rid of
    NSArray<Card*>* cardsToReject;
    
    // Wild cards used
    int wildCardsUsed;
    
    // Wild cards remaining
    int wildCardsRemaining;
}

-(float)probability;
-(void)setProbability:(float)p;

-(HandType)type;
-(void)setType:(HandType)t;

-(NSArray<Card*>*)cardsToKeep;
-(void)setCardsToKeep:(NSArray<Card*>*)cards;

-(NSArray<Card*>*)cardsToReject;
-(void)setCardsToReject:(NSArray<Card*>*)cards;

-(int)wildCardsUsed;
-(void)setWildCardsUsed:(int)cards;

-(int)wildCardsRemaining;
-(void)setWildCardsRemaining:(int)cards;

- (instancetype)init:(float)p type:(HandType)t cardsToKeep:(NSArray<Card*>*)keep cardsToReject:(NSArray<Card*>*)reject;

- (instancetype)init:(float)p type:(HandType)t cardsToKeep:(NSArray<Card*>*)keep cardsToReject:(NSArray<Card*>*)reject wildCardsUsed:(int)wildCardsUsed wildCardsRemaining:(int)wildCardsRemaining;

- (NSString*)getDisplayNameOfHandType;

+ (NSString*)getDisplayNameOfHandType:(HandType)t;

- (NSString*)getDisplayNameOfHandTypeForDisplayInASentence;

+ (NSString*)getDisplayNameOfHandTypeForDisplayInASentence:(HandType)t;

- (NSString*)description;

@end

