//
//  Player.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "Player.h"

@implementation Player

- (instancetype)init:(NSString*)n holdings:(int)h playerType:(PlayerType)type {
    self = [super init];
    if (self) {
        [self setName:n];
        [self setHoldings:h];
        [self setPlayerType:type];
        [self setIsStillInGame:YES];
    }
    
    return self;
}

- (int)holdings {
    return holdings;
}
- (void)setHoldings:(int)h {
    holdings = h;
}

- (PlayerType)playerType {
    return playerType;
}
- (void)setPlayerType:(PlayerType)type {
    playerType = type;
}

- (NSString*)name {
    return name;
}

- (void)setName:(NSString*)n {
    name = n;
}

- (NSArray<Card*>*)hand {
    return hand;
}
- (void)setHand:(NSArray<Card*>*)h {
    hand = h;
}

- (void)addCardToHand:(Card*)card {
    NSMutableArray* h = [[NSMutableArray alloc] initWithArray:hand];
    [h addObject:card];
    
    // We can sort or rearrange the hand now as needed
    hand = h;
}

- (NSArray<Card*>*)getFaceupCards {
    NSMutableArray* h = [[NSMutableArray alloc] init];
    for (Card* c in hand) {
        if ([c isFaceup]) {
            [h addObject:c];
        }
    }
    
    return h;
}

-(bool)isStillInGame {
    return isStillInGame;
}

-(void)setIsStillInGame:(bool)inGame {
    isStillInGame = inGame;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ $%d Is Still In Game: %d", name, hand, holdings, isStillInGame];
}

@end
