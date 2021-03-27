//
//  HGPCardDisplay.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/14/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface HGPCardDisplay : UIView


/**
 Create the display for a hand of cards

 @param rect The dimensions of the display
 @param hand The hand of cards to display
 @param isHuman Is the player human? NPC cards overlap and may be facedown (with no peeking)
 @return The populated card display view
 */
- (instancetype _Nullable )initWithFrame:(CGRect)rect cards:(NSArray<Card*>*_Nonnull)hand isHuman:(bool)isHuman;

/**
 Create the display for a hand of cards. Adds another parameter that controls whether a human player can peek at their cards (for example, in Anaconda they can; in Acey Deucey, they can't)
 
 @param rect The dimensions of the display
 @param hand The hand of cards to display
 @param isHuman Is the player human? NPC cards overlap and may be facedown (with no peeking)
 @param allowPeek Determines whether a human player can peek at their facedown cards. Really indicates whether the cards are in your hand or on the table
 @return The populated card display view
 */
- (instancetype _Nullable )initWithFrame:(CGRect)rect cards:(NSArray<Card*>*_Nonnull)hand isHuman:(bool)isHuman allowPeekOnFaceDownCards:(bool)allowPeek;

/**
 Add cards to the display, dealing them next to any cards that were dealt when we initialized the view
 */
- (void)dealCardsToDisplay:(NSArray<Card*>* _Nonnull)dealtCards;

@property (nonatomic, strong) NSArray<UIImageView*>* _Nullable cardImages;
@property (nonatomic) bool isHuman;
@property (nonatomic) bool allowPeekOnFaceDownCards;

@end
