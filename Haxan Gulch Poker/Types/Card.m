//
//  Card.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "Card.h"

@implementation Card

#pragma mark Value and image accessors

- (instancetype)initWithRank:(int)r suit:(Suit)s {
    self = [super init];
    if (self) {
        self.suit = s;
        self.rank = r;
    }
    
    return self;
}

- (instancetype)initWithRank:(int)r suit:(Suit)s isFaceup:(bool)faceup {
    self = [self initWithRank:r suit:s];
    if (self) {
        self.isFaceup = faceup;
    }
    
    return self;
}

- (bool)isFaceup {
    return isFaceup;
}

- (void)setIsFaceup:(bool)b {
    isFaceup = b;
}

- (Suit)suit {
    return suit;
}
- (void)setSuit:(Suit)s {
    suit = s;
}

- (int)rank {
    return rank;
}
- (void)setRank:(int)r {
    rank = r;
}

- (UIImage*)getImage {
    NSString* fileName = [self getImageFilename];

    // Get this from the  property on AppDelegate
    UIImage* image = [((AppDelegate*)[[UIApplication sharedApplication] delegate]).cardImages objectForKey:fileName];
    
    // If for some reason that didn't work, do it the long way
    if (!image) {
        image = [UIImage imageWithContentsOfFile:[self getImageFilepath]];
    }
    
    return image;
}

+ (UIImage*)getCardBackImage {
    return [((AppDelegate*)[[UIApplication sharedApplication] delegate]).cardImages objectForKey:@"card_back.png"];
}

+ (UIImage*)getCardBackSmallImage {
    return [((AppDelegate*)[[UIApplication sharedApplication] delegate]).cardImages objectForKey:@"card_back_small.png"];
}

+ (UIImage*)getCardBackRevealedImage {
    return [((AppDelegate*)[[UIApplication sharedApplication] delegate]).cardImages objectForKey:@"card_back_reveal_to_player.png"];
}

- (NSString*)getImageFilepath {
    NSString* buttonBackgroundImagePath = [[NSBundle mainBundle]
                                           pathForResource:[[NSString stringWithFormat:@"%@_of_%@",
                                                            [Card getDisplayNameForRank:rank],
                                                            [Card getDisplayNameForSuit:suit]] lowercaseString]
                                           ofType:@"png"];
    return buttonBackgroundImagePath;
}

- (NSString*)getImageFilename {
    NSString* imageFilename = [NSString stringWithFormat:@"%@_of_%@.png",
                               [Card getDisplayNameForRank:rank],
                               [Card getDisplayNameForSuit:suit]];
    return [imageFilename lowercaseString];
}

#pragma mark Display methods

- (NSString*)getDisplayName {
    return [NSString stringWithFormat:@"%@ of %@", [Card getDisplayNameForRank:rank], [Card getDisplayNameForSuit:suit]];
}

+ (NSString*)getDisplayNameForSuit:(int)s {
    switch (s) {
        case Spades : return @"Spades";
        case Diamonds: return @"Diamonds";
        case Hearts: return @"Hearts";
        case Clubs: return @"Clubs";
    }
    
    return nil;
}

+ (NSString*)getDisplayNameForRank:(int)r {
    if (r == 1 || r == 14) return @"Ace";
    if (r < 11) return [NSString stringWithFormat:@"%d", r];
    switch (r) {
        case 11: return @"Jack";
        case 12: return @"Queen";
        case 13: return @"King";
    }
    
    return @"";
}

- (BOOL)isEqual:(id)object {
    if (nil == object || ![object isKindOfClass:[self class]]) return false;
        
    return (((Card*)object).suit == self.suit && ((Card*)object).rank == self.rank);
}

- (NSString*)description {
    return [self getDisplayName];
}

@end
