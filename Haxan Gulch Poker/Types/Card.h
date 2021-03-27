//
//  Card.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Diamonds = 1,
    Hearts = 2,
    Spades = 3,
    Clubs = 4
} Suit;

static const int SIZE_OF_DECK = 52;

@interface Card : NSObject
{
    Suit suit;
    int rank;
    bool isFaceup;
}

- (UIImage*)getImage;
+ (UIImage*)getCardBackImage;
+ (UIImage*)getCardBackSmallImage;
+ (UIImage*)getCardBackRevealedImage;
- (NSString*)getImageFilepath;
- (NSString*)getImageFilename;
- (NSString*)getDisplayName;
+ (NSString*)getDisplayNameForSuit:(int)s;
+ (NSString*)getDisplayNameForRank:(int)r;

- (bool)isFaceup;
- (void)setIsFaceup:(bool)b;

- (Suit)suit;
- (void)setSuit:(Suit)s;

- (int)rank;
- (void)setRank:(int)r;

- (BOOL)isEqual:(id)object;

- (instancetype)initWithRank:(int)r suit:(Suit)s;
- (instancetype)initWithRank:(int)r suit:(Suit)s isFaceup:(bool)faceup;

- (NSString*)description;

@end
