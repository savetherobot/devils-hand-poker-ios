//
//  HGPCardDisplay.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/14/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPCardDisplay.h"

@implementation HGPCardDisplay


- (instancetype _Nullable )initWithFrame:(CGRect)rect cards:(NSArray<Card*>*)hand isHuman:(bool)isHuman {
    // Re allowPeekOnFaceDownCards: If the player is human, they can peek at their facedown cards
   return [self initWithFrame:rect cards:hand isHuman:isHuman allowPeekOnFaceDownCards:isHuman];
}

- (instancetype _Nullable )initWithFrame:(CGRect)rect cards:(NSArray<Card*>*_Nonnull)hand isHuman:(bool)isHuman allowPeekOnFaceDownCards:(bool)allowPeek {
    self = [super initWithFrame:rect];
    if (self) {
        self.allowPeekOnFaceDownCards = allowPeek;
        self.isHuman = isHuman;
        
        CGFloat cardHeight = CGRectGetHeight(rect);
        CGFloat cardWidth = cardHeight * WIDTH_IS_PERCENTAGE_OF_HEIGHT;
        CGFloat cardExposedWidth = cardWidth * 0.3;
        
        // Rather than just using a margin, add a horizontal offset to center the cards
        CGFloat offsetX = isHuman ? (CGRectGetWidth(rect) - (cardWidth * [hand count] + MARGIN_SUPER_THIN * ([hand count] - 1))) / 2 : (CGRectGetWidth(rect) - cardExposedWidth * ([hand count] - 1) - cardWidth) / 2;
        if (offsetX < 0.0f) offsetX = 0.0f;
        
        CGFloat spacingX = !isHuman ? cardExposedWidth : cardWidth + MARGIN_SUPER_THIN;
        
        // If this spacing is going to push cards off the screen, reduce it
        CGFloat availableWidth = CGRectGetWidth(rect) - (MARGIN_STANDARD * 2);
        CGFloat anticipatedWidth = spacingX * ([hand count] - 1) + cardWidth;
        
        if (anticipatedWidth > availableWidth) {
            spacingX -= (anticipatedWidth - availableWidth) / [hand count];
        }
        
        CGFloat currentPositionX = offsetX;
        CGFloat currentPositionY = MARGIN_SUPER_THIN;
        
        NSMutableArray* images = [[NSMutableArray alloc] init];
        
        for (Card* card in hand) {
            UIImageView* cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(currentPositionX, currentPositionY, cardWidth, cardHeight)];
            
            [self setImageOnCardView:cardImageView card:card];
            
            [self addSubview:cardImageView];
            [images addObject:cardImageView];
            
            currentPositionX += spacingX;
        }
        
        self.cardImages = images;
    }
    
    return self;
}

-(void)dealCardsToDisplay:(NSArray<Card*>*)dealtCards  {
    NSMutableArray<UIImageView*>* cardImageViews = [[NSMutableArray alloc] init];
    [cardImageViews addObjectsFromArray:self.cardImages];
    
    int cardCount = (int)([cardImageViews count] + [dealtCards count]);
    
    CGRect rect = self.frame;
    
    CGFloat cardHeight = CGRectGetHeight(rect);
    CGFloat cardWidth = cardHeight * WIDTH_IS_PERCENTAGE_OF_HEIGHT;
    CGFloat cardExposedWidth = cardWidth * 0.3;
    
    // Rather than just using a margin, add a horizontal offset to center the cards
    CGFloat offsetX = self.isHuman ? (CGRectGetWidth(rect) - (cardWidth * cardCount + MARGIN_SUPER_THIN * (cardCount - 1))) / 2 : (CGRectGetWidth(rect) - cardExposedWidth * (cardCount - 1) - cardWidth) / 2;
    if (offsetX < 0.0f) offsetX = 0.0f;
    
    CGFloat spacingX = self.isHuman ? cardWidth + MARGIN_SUPER_THIN : cardExposedWidth;
    
    // If this spacing is going to push cards off the screen, reduce it
    CGFloat availableWidth = CGRectGetWidth(rect);
    CGFloat anticipatedWidth = spacingX * (cardCount- 1) + cardWidth;
    
    if (anticipatedWidth > availableWidth) {
        spacingX -= (anticipatedWidth - availableWidth) / cardCount;  
    }
    
    CGFloat currentPositionX = offsetX;
    CGFloat currentPositionY = MARGIN_SUPER_THIN / 2;
    
    for (int i = 0; i < cardCount; i++)  {
        UIImageView* cardImageView;
        
        // Either we already have a UIImageView for this card, and we need to move it ...
        if (i < [cardImageViews count]) {
            cardImageView = cardImageViews[i];
            
            CGRect destinationRect = cardImageView.frame;
            destinationRect.origin.x = currentPositionX;
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cardImageView.frame = destinationRect;
                             }
                             completion:^(BOOL finished){
                             }];
        }
        
        // ... or it's new
        else {
            Card* card = dealtCards[i - [self.cardImages count]];
            cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(currentPositionX, currentPositionY, cardWidth, cardHeight)];
            
            [self setImageOnCardView:cardImageView card:card];
            
            // Fade the new card in
            [cardImageView setAlpha:0.0f];
            [self addSubview:cardImageView];
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [cardImageView setAlpha:1.0f];
                             }
                             completion:^(BOOL finished){
                             }];
            
            [cardImageViews addObject:cardImageView];
            
            [self addSubview: cardImageView];
        }
        
        currentPositionX += spacingX;
    }
    
    self.cardImages = cardImageViews;
}

// Helper method to display the appropriate image for the card, depending on whether it's faceup and whether it's the huamn player's card
-(void)setImageOnCardView:(UIImageView*)cardImageView card:(Card*)card {
    if ([card isFaceup]) {
        [cardImageView setImage:[card getImage]];
    }
    else {
        if (self.isHuman && self.allowPeekOnFaceDownCards) {
            // Give a visual indicator to show that this card is really facedown
            [cardImageView setImage:[card getImage]];
            UIImageView* facedownOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(cardImageView.frame), CGRectGetHeight(cardImageView.frame))];
            [facedownOverlay setImage:[Card getCardBackRevealedImage]];
            [cardImageView addSubview:facedownOverlay];
        } else {
            [cardImageView setImage:[Card getCardBackImage]];
        }
    }
}

@end
