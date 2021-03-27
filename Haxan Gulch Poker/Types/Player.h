//
//  Player.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

typedef enum {
    PlayerTypeHuman,
    PlayerTypeNPC_Simple,
    PlayerTypeNPC_CardCounter,
    PlayerTypeNPC_Beast
} PlayerType;

// Pass this constant to show that a particular bet is impossible.  For example: if an AI is weighing between options for a low, medium and high bet, but the value of the high bet is greater than the pot can handle, this constant will indicate that that bet can't be placed
static const int INVALID_BET = -1;

@interface Player : NSObject
{
    int holdings;
    PlayerType playerType;
    NSString* name;
    bool isStillInGame;
    NSArray<Card*>* hand;
}

- (instancetype)init:(NSString*)name holdings:(int)holdings playerType:(PlayerType)type;

// The cash the player has in hand
- (int)holdings;
- (void)setHoldings:(int)h;

// The type of player
- (PlayerType)playerType;
- (void)setPlayerType:(PlayerType)type;

// The player's name
- (NSString*)name;
- (void)setName:(NSString*)n;

// The player's hand
- (NSArray<Card*>*)hand;
- (void)setHand:(NSArray<Card*>*)h;

- (void)addCardToHand:(Card*)card;

- (NSArray<Card*>*)getFaceupCards;

// Player is still in the game?
-(bool)isStillInGame;
-(void)setIsStillInGame:(bool)inGame;

@end
