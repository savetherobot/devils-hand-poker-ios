//
//  HGPBaseSevenCardStudGameViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/21/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPBaseSevenCardStudGameViewController.h"

@interface HGPBaseSevenCardStudGameViewController ()

@end

@implementation HGPBaseSevenCardStudGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //////////////////////////////////////////////////
    // Seven card stud-specific UI elements
    
    // Set up the holdings display
    holdingsDisplayView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, 0.0f, self.view.frame.size.width - MARGIN_STANDARD * 2, 50.0f)];  // We're tucking this up above the top border because we don't yet need the character portrait area
    [self.view addSubview:holdingsDisplayView];

    CGRect bettingStatusFrame = bettingStatusLabel.frame;
    bettingStatusFrame.size.height = LABEL_HEIGHT * 2;
    bettingStatusFrame.origin.x = bettingStatusFrame.origin.x + 50.0f;  // TODO: Set up the side label width as a constant or something, anyway, don't use a magic number
    bettingStatusFrame.size.width =  bettingStatusFrame.size.width - (50.0f * 2);
    bettingStatusLabel.frame = bettingStatusFrame;
    
    // For this game, it's two lines
    [bettingStatusLabel setNumberOfLines:2];
    [bettingStatusLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    // For the card display view, cover the game status label and increase the height
    CGFloat cardDisplayViewY = CGRectGetMaxY(holdingsDisplayView.frame) + MARGIN_THIN;
    cardDisplayView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, cardDisplayViewY, CGRectGetWidth(self.view.frame) - (MARGIN_STANDARD * 2.0f), CGRectGetMinY(bettingStatusLabel.frame) - cardDisplayViewY - MARGIN_THIN)];
    [self.view addSubview:cardDisplayView];
    // Do any additional setup after loading the view.
    
    // Pot starts at 0
    pot = 0;
    
    // Draw view elements
    [self displayHoldings];
    [self displayBetButtons];
    
    // Add seven-card stud-specific buttons
    CGFloat twinButtonWidth = (betButtonDisplayView.frame.size.width - MARGIN_STANDARD) / 2;
    
    // Match Bet or Fold
    matchBetButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, twinButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:matchBetButton];
    [matchBetButton setTitle:@"Match the Bet" forState:UIControlStateNormal];
    [matchBetButton addTarget:self action:@selector(matchBet) forControlEvents:UIControlEventTouchUpInside];
    [matchBetButton setTag:ActionButtonTypeMatchBet];
    [betButtonDisplayView addSubview:matchBetButton];
    
    foldButton = [[UIButton alloc] initWithFrame:CGRectMake(twinButtonWidth + MARGIN_STANDARD, 0.0f, twinButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:foldButton];
    [foldButton setTitle:@"Fold" forState:UIControlStateNormal];
    [foldButton addTarget:self action:@selector(foldInsteadOfMatch) forControlEvents:UIControlEventTouchUpInside];
    [foldButton setTag:ActionButtonTypeFold];
    [betButtonDisplayView addSubview:foldButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Initialize the display of all of the players' (PC and NPC) holdings
- (void)displayHoldings {
    NSMutableArray* labels = [[NSMutableArray alloc] init];
    NSMutableArray<UIImageView*>* backgrounds = [[NSMutableArray alloc] init];
    
    CGFloat aiPlayerDisplayAvailableWidth = holdingsDisplayView.frame.size.width / ([players count] - 1);
    CGFloat currentPositionX = 0.0f;
    
    UIImage* deselectedBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_deselected" ofType:@"png"]];
    UIImage* deselectedFreeFloatingBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_freefloating_deselected" ofType:@"png"]];
    UIImage* selectedFreeFloatingBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_freefloating_selected" ofType:@"png"]];
    
    // Display the NPCs
    if (players && [players count] > 1) {
        for (int i = 1; i < [players count]; i++) {
            // Background
            CGFloat backgroundHeight = CGRectGetHeight(holdingsDisplayView.frame);
            CGFloat backgroundWidth = backgroundHeight * 2.8f;   // Image is 290 x 233, but we need a decent width on this, so we're stretching it
            CGFloat backgroundX = currentPositionX + ((aiPlayerDisplayAvailableWidth - backgroundWidth) / 2);
            
            UIImageView* holdingsBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(backgroundX, 0.0f, backgroundWidth, backgroundHeight)];
            [holdingsBackgroundImageView setImage:deselectedBackground];
            [holdingsDisplayView addSubview:holdingsBackgroundImageView];
            
            [backgrounds addObject:holdingsBackgroundImageView];
            
            // Name label
            UILabel* displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(backgroundX, backgroundHeight * 0.1f, backgroundWidth, LABEL_HEIGHT)];
            
            [displayLabel setText:[NSString stringWithFormat:@"%@", [players[i] name]]];
            [self styleHoldingsLabel:displayLabel isOnLightBackground:YES];
            
            // Holdings label
            UILabel* holdingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(currentPositionX + MARGIN_STANDARD, CGRectGetMaxY(displayLabel.frame), aiPlayerDisplayAvailableWidth - (MARGIN_STANDARD * 2.0f), LABEL_HEIGHT)];
            [holdingsLabel setText:[NSString stringWithFormat:@"$%d", i < [players count] ? [players[i] holdings] : pot]];
            [self styleHoldingsLabel:holdingsLabel isOnLightBackground:YES];
            [labels addObject:holdingsLabel];
            
            [holdingsDisplayView addSubview:displayLabel];
            [holdingsDisplayView addSubview:holdingsLabel];
            currentPositionX += aiPlayerDisplayAvailableWidth;
        }
    }
    
    playerHoldingsLabels = labels;
    playerHoldingsBackgrounds = backgrounds;
    
    CGFloat sideLabelWidth = 65.0f;
    
    // Insert the holdings for YOU and POT off to the left and right near the bottom
    CGFloat backgroundImageHeight = LABEL_HEIGHT * 2 + MARGIN_THIN;
    
    // "You"
    playerHoldingsHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_THIN, CGRectGetMinY(bettingStatusLabel.frame) + (MARGIN_THIN - 3.0f), sideLabelWidth, LABEL_HEIGHT - 2)];
    [self styleHoldingsLabel:playerHoldingsHeaderLabel isOnLightBackground:YES];
    [playerHoldingsHeaderLabel setText:@"YOU"];
    playerHoldingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_THIN, CGRectGetMaxY(playerHoldingsHeaderLabel.frame), sideLabelWidth, LABEL_HEIGHT)];
    [self styleHoldingsLabel:playerHoldingsLabel isOnLightBackground:YES];
    [playerHoldingsLabel setText:[NSString stringWithFormat:@"$%d", [players[0] holdings]]];
    
    // Add a background
    playerHoldingsBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(playerHoldingsHeaderLabel.frame), CGRectGetMinY(bettingStatusLabel.frame), CGRectGetWidth(playerHoldingsHeaderLabel.frame), backgroundImageHeight)];
    [playerHoldingsBackgroundImageView setImage:selectedFreeFloatingBackground];
    
    [self.view addSubview:playerHoldingsBackgroundImageView];
    [self.view addSubview:playerHoldingsHeaderLabel];
    [self.view addSubview:playerHoldingsLabel];
    
    // "Pot"
    potHoldingsHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - MARGIN_THIN - sideLabelWidth, CGRectGetMinY(bettingStatusLabel.frame) + (MARGIN_THIN - 3.0f), sideLabelWidth, LABEL_HEIGHT - 2)];
    [potHoldingsHeaderLabel setText:@"POT"];
    [self styleHoldingsLabel:potHoldingsHeaderLabel isOnLightBackground:YES];
    
    potHoldingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) -  MARGIN_THIN - sideLabelWidth, CGRectGetMaxY(playerHoldingsHeaderLabel.frame), sideLabelWidth, LABEL_HEIGHT)];
    [potHoldingsLabel setText:@"$0"];
    [self styleHoldingsLabel:potHoldingsLabel isOnLightBackground:YES];
    
    potHoldingsBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(potHoldingsHeaderLabel.frame), CGRectGetMinY(bettingStatusLabel.frame), CGRectGetWidth(potHoldingsHeaderLabel.frame), backgroundImageHeight)];
    [potHoldingsBackgroundImageView setImage:deselectedFreeFloatingBackground];
    
    [self.view addSubview:potHoldingsBackgroundImageView];
    [self.view addSubview:potHoldingsHeaderLabel];
    [self.view addSubview:potHoldingsLabel];
}

-(void)styleHoldingsLabel:(UILabel*)label isOnLightBackground:(bool)isOnBackground {
    [label setNumberOfLines:1];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontForBody]];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setTextColor:(isOnBackground ? [UIColor blackColor] : [UIColor whiteColor])];
}

// FIXME: In these games and the other ones, it would be ideal if players who are out of the game are greyed out

// Update the holdings labels to the current values
-(void)updateHoldings {
    UIImage* deselectedBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_deselected" ofType:@"png"]];
    UIImage* selectedBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_selected" ofType:@"png"]];
    UIImage* deselectedFreeFloatingBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_freefloating_deselected" ofType:@"png"]];
    UIImage* selectedFreeFloatingBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_freefloating_selected" ofType:@"png"]];
    
    // FIXME: This little dance around the separate array of NPC labels is confusing - put all the players labels in one array even if they're laid out in different parts of the screen. Fix this in Anaconda, too
    for (int i = 0; i < [playerHoldingsLabels count]; i++) {
        [playerHoldingsLabels[i] setText:[NSString stringWithFormat:@"$%d", [players[i + 1] holdings]]];
        [playerHoldingsBackgrounds[i] setImage:playerIndex == i + 1 ? selectedBackground : deselectedBackground];
    }
    
    [playerHoldingsLabel setText:[NSString stringWithFormat:@"$%d", [players[0] holdings]]];
    [playerHoldingsBackgroundImageView setImage:playerIndex == 0 ? selectedFreeFloatingBackground : deselectedFreeFloatingBackground];
    
    [potHoldingsLabel setText:[NSString stringWithFormat:@"$%d", pot]];
}

- (void)createCardDisplay {
    playerCardViews = [[NSMutableArray alloc] initWithCapacity:[players count]];
    
    ////////////////////////////////////////////////////////
    // Set up the rectangles in which we're going to display each hand
    int countNPCs = (int)[players count] - 1;
    
    CGFloat heightNPCFrames = CGRectGetHeight(cardDisplayView.frame) * 0.45f;
    CGFloat widthNPCFrames = CGRectGetWidth(cardDisplayView.frame) / countNPCs;
    
    NSMutableArray* cardDisplayViews = [[NSMutableArray alloc] init];
    
    // Populate the player display ...
    Player* human = [super getHumanPlayer];
    UIView* humanPlayerCardView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, heightNPCFrames, CGRectGetWidth(cardDisplayView.frame), CGRectGetHeight(cardDisplayView.frame) - heightNPCFrames)];
    [self populateCardDisplayWithHand:[human hand] inView:humanPlayerCardView playerIndex:0];    // TODO: I hate that we're making that assumption
    
    [cardDisplayViews addObject:humanPlayerCardView];
    
    // ... and the NPC display
    int npcIndex = 0;
    for (Player* p in players) {
        if ([p playerType] != PlayerTypeHuman) {
            CGFloat rectY = 0.0f;
            UIView* npcView = [[UIView alloc] initWithFrame:CGRectMake(widthNPCFrames * npcIndex, rectY, widthNPCFrames, heightNPCFrames)];
            [self populateCardDisplayWithHand:[p hand] inView:npcView playerIndex:npcIndex + 1];
            
            [cardDisplayViews addObject:npcView];
            npcIndex++;
        }
    }
    
    playerCardDisplayViews = cardDisplayViews;
}

-(void)populateCardDisplayWithHand:(NSArray<Card*>*)hand inView:(UIView*)playerView playerIndex:(int)index {
    bool isHuman = [players[index] playerType] == PlayerTypeHuman;
    
    NSMutableArray<UIImageView*>* cardImageViews = [[NSMutableArray alloc] init];
    if (index < [playerCardViews count]) [cardImageViews addObjectsFromArray:playerCardViews[index]];
    
    CGRect rect = playerView.frame;
    
    CGFloat cardHeight = CGRectGetHeight(rect);
    CGFloat cardWidth = cardHeight * WIDTH_IS_PERCENTAGE_OF_HEIGHT;
    CGFloat cardExposedWidth = cardWidth * 0.3;
    
    // Rather than just using a margin, add a horizontal offset to center the cards
    CGFloat offsetX = isHuman ? (CGRectGetWidth(rect) - (cardWidth * [hand count] + MARGIN_SUPER_THIN * ([hand count] - 1))) / 2 : (CGRectGetWidth(rect) - cardExposedWidth * ([hand count] - 1) - cardWidth) / 2;
    if (offsetX < 0.0f) offsetX = 0.0f;
    
    CGFloat spacingX = isHuman ? cardWidth + MARGIN_SUPER_THIN : cardExposedWidth;
    
    // If this spacing is going to push cards off the screen, reduce it
    CGFloat availableWidth = CGRectGetWidth(rect);
    CGFloat anticipatedWidth = spacingX * ([hand count] - 1) + cardWidth;
    
    if (anticipatedWidth > availableWidth) {
        spacingX -= (anticipatedWidth - availableWidth) / [hand count];
    }
    
    CGFloat currentPositionX = offsetX;
    CGFloat currentPositionY = MARGIN_SUPER_THIN / 2;
    
    for (int i = 0; i < [hand count]; i++)  {
        Card* card = hand[i];
        
        UIImageView* cardImageView;
        
        // Either we already have a UIImageView for this card, and we need to move it ...
        if (i < [cardImageViews count]) {
            cardImageView = cardImageViews[i];
            
            [self setCardImage:cardImageView card:card isHuman:isHuman];
            
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
            cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(currentPositionX, currentPositionY, cardWidth, cardHeight)];
            
            [self setCardImage:cardImageView card:card isHuman:isHuman];
            
            // Fade the new card in
            [cardImageView setAlpha:0.0f];
            [playerView addSubview:cardImageView];
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [cardImageView setAlpha:1.0f];
                             }
                             completion:^(BOOL finished){
                             }];
            
            // For the player, attach swipes to the cards
            if (isHuman) {
                [cardImageView setUserInteractionEnabled:YES];
                cardImageView.tag = i;
                
                UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
                swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
                [cardImageView addGestureRecognizer:swipeRight];
                
                UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
                swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
                [cardImageView addGestureRecognizer:swipeLeft];
            }
            
            [cardImageViews addObject:cardImageView];
        }
        
        currentPositionX += spacingX;
    }

    // If this is the first time through, add the view to the card display and the array of card image views to the array of arrays of card image views - basically, get it all set up
    if ([playerCardViews count] <= index) {
        [cardDisplayView addSubview:playerView];
        [playerCardViews insertObject:cardImageViews atIndex:index];
    }
    // Otherwise, just update the card images
    else {
        playerCardViews[index] = cardImageViews;
    }
}

// Set the image to display on the card, factoring in whether it's faceup, facedown, or revealed to the (human) player
-(void)setCardImage:(UIImageView*)cardImageView card:(Card*)card isHuman:(bool)isHuman {
    if ([card isFaceup]) {
        [cardImageView setImage:[card getImage]];
    }
    else {
        if (isHuman) {
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

// At the end of a round, update the player card buttons to show the player's current hand and to set the buttons back to their correct positions
-(void)updatePlayerCards:(int)index {
    // ... and populate the new ones
    [self populateCardDisplayWithHand:[players[index] hand] inView:playerCardDisplayViews[index] playerIndex:index];
}

// Allow the player to swipe cards back and forth for easier review
- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture
{
    UIView* view = gesture.view;
    NSMutableArray<Card*>* playerHand = [[NSMutableArray alloc] initWithArray:[[self getHumanPlayer] hand]];
    NSMutableArray<UIImageView*>* cardImageViews = playerCardViews[0];
    
    int cardIndex = (int)view.tag;
    
    // Swap the cards in the player's hand
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight && cardIndex < [playerHand count]) {
        [playerHand exchangeObjectAtIndex:cardIndex withObjectAtIndex:cardIndex + 1];
        [cardImageViews exchangeObjectAtIndex:cardIndex withObjectAtIndex:cardIndex + 1];
        [self exchangeCardImageView:cardImageViews[cardIndex] withCardImageView:cardImageViews[cardIndex + 1]];
    }

    else if (gesture.direction == UISwipeGestureRecognizerDirectionLeft && view.tag > 0) {
        [playerHand exchangeObjectAtIndex:cardIndex withObjectAtIndex:cardIndex - 1];
        [cardImageViews exchangeObjectAtIndex:cardIndex withObjectAtIndex:cardIndex - 1];
        [self exchangeCardImageView:cardImageViews[cardIndex] withCardImageView:cardImageViews[cardIndex - 1]];
    }
    
    [[self getHumanPlayer] setHand:playerHand];
    
    // Track this event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"
                                                          action:@"Swipe Cards"
                                                           label:NSStringFromClass([self class])
                                                           value:@1] build]];
}

// Move the buttons and reassign their tags to keep them sequential
-(void)exchangeCardImageView:(UIImageView*)imageViewA withCardImageView:(UIImageView*)imageViewB {

    // Swap the tags
    int exchangeTag = (int)imageViewA.tag;
    imageViewA.tag = imageViewB.tag;
    imageViewB.tag = exchangeTag;
    
    CGRect destinationRectA = imageViewB.frame;
    CGRect destinationRectB = imageViewA.frame;
    
    // ... and then swap the buttons on-screen
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageViewB.frame = destinationRectB;
                         imageViewA.frame = destinationRectA;
                     }
                     completion:^(BOOL finished){
                     }];
}

-(void)displayBetButtons {
    if (bets && [bets count] > 0) {
        CGFloat buttonBackgroundWidth = CGRectGetHeight(betButtonDisplayView.frame) * 1.44f; // The height-to-width ratio observed on the actual image asset
        
        CGFloat currentPositionX = buttonBackgroundWidth / 2;
        CGFloat buttonAvailableSpaceWidth = betButtonDisplayView.frame.size.width * 0.8;
        
        CGFloat spaceBetweenButtons = (buttonAvailableSpaceWidth - (currentPositionX * 2.0f) - (buttonBackgroundWidth * ([bets count] + 1))) / [bets count] + 1;
        
        NSMutableArray* buttons = [[NSMutableArray alloc] init];
        
        for (int i = 0; i <= [bets count]; i++) {
            UIButton* betButton = [[UIButton alloc] initWithFrame:CGRectMake(currentPositionX, 0.0f, buttonBackgroundWidth, CGRectGetHeight(betButtonDisplayView.frame))];
            
            UILabel* customTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(betButton.frame) *0.4f, CGRectGetWidth(betButton.frame), 20.0f)];
            
            [customTitleLabel setText:i < [bets count] ? [NSString stringWithFormat:@"$%@", bets[i]] : @"FOLD"];
            [customTitleLabel setFont:[UIFont fontForButton]];
            [customTitleLabel setTextColor:[UIColor blackColor]];
            [customTitleLabel setTextAlignment:NSTextAlignmentCenter];
            [betButton addSubview:customTitleLabel];
            
            if (i < [bets count]) {
                [betButton addTarget:self action:@selector(playerBets:) forControlEvents: UIControlEventTouchUpInside];
            }
            else {
                [betButton addTarget:self action:@selector(foldInsteadOfBet) forControlEvents: UIControlEventTouchUpInside];
            }
            [betButton setTag:i];
            [betButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                                            pathForResource:@"BetBarButton"
                                                                            ofType:@"png"]] forState:UIControlStateNormal];
            
            [buttons addObject:betButton];
            
            [betButtonDisplayView addSubview:betButton];
            currentPositionX += (buttonBackgroundWidth + spaceBetweenButtons);
        }
        
        betButtons = buttons;
    }
    
    // Finally, add the menu popup as part of this work
    [self displaySlidingMenu];
    
    // Establish the next button that the player taps when the AI is playing
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, betButtonDisplayView.frame.size.width, betButtonDisplayView.frame.size.height)];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [super styleButton:nextButton];
    [nextButton addTarget:self action:@selector(next) forControlEvents: UIControlEventTouchUpInside];
    [betButtonDisplayView addSubview:nextButton];
    
    [foldButton setHidden:YES];
    [nextButton setHidden:YES];
    
    // Finally, set up the Quit button that we see if the game ends abruptly (like if all but one player is eliminated)
    quitButton = [[UIButton alloc] initWithFrame:betButtonDisplayView.frame];
    [quitButton setTitle:@"That’s the Game" forState:UIControlStateNormal];
    [self styleButton:quitButton];
    [quitButton addTarget:self action:@selector(displayReplayModal) forControlEvents: UIControlEventTouchUpInside];
    [quitButton setHidden:YES];
    
    [self.view addSubview:quitButton];
}

# pragma mark UI interactions

-(void)setIsEnabledForBetButtons:(bool)isEnabled {
    for (UIButton* b in betButtons) {
        [b setEnabled:isEnabled];
    }
}

#pragma mark Calculate information about the deck or player status

-(bool)isCardDealtFaceUpThisRound {
    return (currentRound > 2 && currentRound < 7);
}

// Get all the cards remaining in the deck and facedown on the table
-(NSArray<Card*>*)getUnknownCards {
    NSMutableArray* unknownCards = [[NSMutableArray alloc] initWithArray:[deck objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(deckIndex, 52 - deckIndex)]]];
    
    for (Player* p in players) {
        for (Card* c in [p hand]) {
            if (![c isFaceup]) [unknownCards addObject:c];
        }
    }
    
    return unknownCards;
}

#pragma mark Game logic methods

-(void)resetGame {
    if (replayModal) [replayModal removeFromSuperview];
    if (resultsModal) [resultsModal removeFromSuperview];
    
    // Make sure all of the players are in the game
    for (Player* p in players) {
        [p setIsStillInGame:YES];
    }
    
    // Clear any older card displays
    if (playerCardDisplayViews && [playerCardDisplayViews count] > 0) {
        for(UIView* view in playerCardDisplayViews) {
            [view removeFromSuperview];
        }
    }
    
    [self initializeGame];
}

-(void)initializeGame {
    // The pot starts at 0
    pot = 0;
    
    // The deck starts at 0, too
    deckIndex = 0;
    
    // Set up cards
    deck = [self shuffleDeck:[self createDeck:NO]];
    
    // Deal their hands
    for (Player* p in players) {
        // Deal two cards each
        NSIndexSet* range = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(deckIndex, 2)];
        NSArray<Card*>* hand = [deck objectsAtIndexes:range];
        [p setHand:hand];
        deckIndex += 2;
        
        // The first two cards are dealt facedown
        for (Card* c0 in hand) {
            [c0 setIsFaceup:NO];
        }
    }
    
    // Each player antes up at the start of the game, starting the pot
    int ante = [bets[0] intValue];
    for (Player* p in players) {
        p.holdings -= ante;
        pot += ante;
    }
    
    [self updateHoldings];
    
    if (replayModal) [replayModal removeFromSuperview];
    
    // Draw the cards
    [self createCardDisplay];
    
    // Clear the betting bar
    [self updateActionButtons:ActionButtonStateNone];
    
    // This is counterintuitive, but the first two cards are dealt at the start of the game, and we want to end with 7 - so it's easiest to say that the first round is number three, with the third card being dealt
    currentRound = 3;
    
    // Set the index to -1 so that when the round starts, it pushes us to 0
    playerIndex = -1;
    
    // Kick off the first round
    [self advanceRound];
}

-(bool)moveToNextPlayerAndCheckForNextRound {
    int startingPlayer = playerIndex;
    bool isANewRound = false;
    
    playerIndex++;
    while (startingPlayer != playerIndex) {
        if (playerIndex == [players count]) {
            playerIndex = 0;
            currentRound++;
            isANewRound = true;
        }
        if ([players[playerIndex] isStillInGame]) break;
        else playerIndex++;
    }
    
    return isANewRound;
}

// The specified player folds. Returns true if the game can continue or false if we're out of players and the game is ending
-(bool)playerFolds:(int)index {
    [players[index] setIsStillInGame:NO];
    
    // If the player just beat the beast, that interrupts the game
    if ([self checkIfBeastIsBeaten:players[index]]) return false;
    
    if ([super getCountOfPlayersLeft] < 2) {
        [self endGame];
        return false;
    }
    else return true;
}

// This player placed a bet; take their money and update the display
-(void)playerPlacesBet:(int)index bet:(int)bet {
    // Don't count the "I fold" indicator as a money bet ... 
    if (bet > -1) {
        [players[index] setHoldings:[players[index] holdings] - bet];
        pot += bet;
        [self updateHoldings];
    }
}

-(void)next {
    [self advanceRound];
}

// TODO: This method may be overridden if there are other buttons - see if we can cover most of the cases in the base class and only the extra cases in the subclass
-(void)updateActionButtons:(ActionButtonState)state {
    for (UIButton* b in betButtons) {
        [b setHidden:YES];
    }
    [matchBetButton setHidden:YES];
    [foldButton setHidden:YES];
    [nextButton setHidden:YES];
    [quitButton setHidden:YES];
    [slidingMenuView setHidden:YES];
    [slidingMenuHitTargetAreaView setHidden:YES];
    
    switch(state) {
        case ActionButtonStatePlayerBets: {
            for (int i = 0; i < [betButtons count] - 1; i++) {
                // Only show buttons with bets the player and the pot can afford
                if ([bets[i] intValue] <= [players[playerIndex] holdings]) {
                    [betButtons[i] setHidden:NO];
                }
                else {
                    [betButtons[i] setHidden:YES];
                }
            }
            
            // The last button, FOLD, is always available ... if yer a quitter
            [[betButtons lastObject] setHidden:NO];
            
            // And we lump the sliding menu view in with these as well
            [slidingMenuView setHidden:NO];
            [slidingMenuHitTargetAreaView setHidden:NO];
            
            break;
        }
        case ActionButtonStateNextButton: {
            [nextButton setHidden:NO];
            break;
        }
        case ActionButtonStateMatchOrFoldButton: {
            [matchBetButton setHidden:NO];
            [foldButton setHidden:NO];
            
            // If the player can't afford to raise, disable that button
            if (currentBet + currentRaiseAmount > [[super getHumanPlayer] holdings]) {
                [matchBetButton setEnabled:NO];
            }
            break;
        }
        case ActionButtonStateGameOver: {
            [quitButton setHidden:NO];
            break;
        }
        case ActionButtonStateNone:
        default:
            break;
    }
}

#pragma mark End the game

// Call this method whenever the game ends
// This should be overridden by subclasses, for example to do the final results and deal with wild cards
-(void)endGame {
    // If only 0 players are left, we had an error
    if ([super getCountOfPlayersLeft] == 0) {
        NSError* error = [[NSError alloc] initWithDomain:kHGPErrorDomain code:kHGPErrorCodeProgrammingError userInfo:@{@"playersLeft":@0}];
        [CrashlyticsKit recordError:error];
    }
    
    // If the game ended because only one player is left standing, they get the pot
    if ([super getCountOfPlayersLeft] == 1) {
        Player* lastPlayerStanding;
        for (Player* p in players) {
            if ([p isStillInGame]) {
                lastPlayerStanding = p;
                break;
            }
        }
        
        if (lastPlayerStanding.playerType == PlayerTypeHuman) {
            [bettingStatusLabel setText:@"You are the last player standing, and you win the pot!"];
        } else {
            [bettingStatusLabel setText:[NSString stringWithFormat:@"%@ is the last player standing, and wins the pot!", [lastPlayerStanding name]]];
        }
        
        [lastPlayerStanding setHoldings:[lastPlayerStanding holdings] + pot];
        pot = 0;
        
        // Trigger the "Step Away From the Table" button
        [self updateActionButtons:ActionButtonStateGameOver];
    }
    // If we made it all the way through, show the winners
    else {
        NSMutableArray<HandEvaluation*>* rankings = [[NSMutableArray alloc] init];
        NSMutableArray<NSString*>* results = [[NSMutableArray alloc] init];
        
        for (Player* p in players) {
            if ([p isStillInGame]) {
                NSArray<Card*>* handWithoutWildCards = [self getHandWithoutWildCards:[p hand]];
                int countOfWildCards = (int)([[p hand] count] - [handWithoutWildCards count]);
                HandEvaluation* finalRank = [HandEvaluator getFinalRankingOfHand:handWithoutWildCards wildCards:countOfWildCards];
                [rankings addObject:finalRank];
            }
        }
        
        rankings = [NSMutableArray arrayWithArray:[HandEvaluator sortHandsByRank:rankings]];
        
        // So, now you have to match the player back to the ranking ... then you can post a result
        // TODO: This is a silly way to do this ...
        for (int i = 0; i < [rankings count]; i++) {
            HandEvaluation* ranking = rankings[i];
            Player* p = [self getPlayerForHandEvaluation:ranking];
            
            if (p) {
                // If this is the winning player, they take the pot
                bool isWinner = (0 == i) ;
                if (isWinner) {
                    [p setHoldings:[p holdings] + pot];
                    pot = 0;
                }
                
                [results addObject: [NSString stringWithFormat:@"%@ got %@! %@", [p name], [ranking getDisplayNameOfHandTypeForDisplayInASentence], isWinner ? @" The winner!" : @""]];
            }
        }
        
        // Reveal the NPCs hands
        for (int i = 1; i < [players count]; i++) {
            for (Card* c in [players[i] hand]) {
                [c setIsFaceup:YES];
            }
            
            [self updatePlayerCards:i];
        }
        
        // Pop the results modal
        resultsModal = [super showModal:[results componentsJoinedByString:@"\n"]];
        [resultsModal.closeButton addTarget:self action:@selector(displayReplayModal) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Update the player's holdings
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    int currentPlayerHoldings = [[super getHumanPlayer] holdings];
    int winnings = currentPlayerHoldings - [player holdings];
    
    [PlayerRecordProvider addWinnings:winnings];
    [player setHoldings:currentPlayerHoldings];
    [PlayerRecordProvider updatePlayerRecord:player];
    
    [self updateHoldings];
}

// Return the evaluations of the player's hand, taking into account wild cards
-(NSArray<HandEvaluation*>*)evaluatePlayerHand:(NSArray<Card*>*)hand {
    NSArray<Card*>* remainingDeck = [self getUnknownCards];
    
    // Pull out (and count) the wild cards
    NSArray<Card*>* handWithoutWildCards = [self getHandWithoutWildCards:hand];
    int countOfWildCards = (int)([hand count] - [handWithoutWildCards count]);
    
    NSArray<HandEvaluation*>* evaluations = [HandEvaluator evaluatePokerHand:handWithoutWildCards wildCards:countOfWildCards unknownCards:remainingDeck handSize:SEVEN_CARD_STUD_HAND_SIZE];
    
    return evaluations;
}

// Determine the specified AI player's bet based on their hand and their opponents. Returns the bet amount (one of the recognized bets), or -1 if the AI folds
-(int)calculateAiBet:(Player*)aiPlayer {
    // If the player is broke, fold right away
    if ([aiPlayer holdings] < [bets[0] intValue]) {
        return -1;
    }
    
    // Okay, we assume there are three bets at this point - small, medium, whammo
    NSArray<HandEvaluation*>* evaluations = [self evaluatePlayerHand:[aiPlayer hand]];
    
    // What is the likeliest hand?
    HandEvaluation* likeliestHand = [HandEvaluator selectLikeliestHandEvaluation:evaluations];
    
    // The hand that the player wants to get
    HandEvaluation* targetedHand = likeliestHand;
    
    int aiBet = [bets[0] intValue];
    
    // The maximum bet drops as the games goes on
    int maximumBetForThisHand = currentRound < 6 ? [bets[1] intValue] : [bets[0] intValue];
    
    for (HandEvaluation* evaluation in evaluations) {
        // For the three best types of hands, it'll accept a 0.1 risk
        if ([evaluation type] < 4 && [evaluation probability] > 0.1f) {
            targetedHand = evaluation;
            aiBet = [bets[2] intValue];
            maximumBetForThisHand = [bets[2] intValue];
            break;
        }
        // For the next three, a 0.3 risk
        else if ([evaluation type] < 7 && [evaluation probability] > 0.3f) {
            targetedHand = evaluation;
            aiBet = [bets[1] intValue];
            maximumBetForThisHand = [bets[2] intValue];
            break;
        }
        // For the next two, just set it to the lowest bet, but tolerate a high risk
        else if ([evaluation type] < 9 && [evaluation probability] > 0.9f)  {
            aiBet = [bets[0] intValue];
            maximumBetForThisHand = [bets[1] intValue];
            
            // Special exception: If we're in a later room, the AI is more likely to match a high bet and not be bluffed out of a game
            if (self.currentRoom >= 2) maximumBetForThisHand = [bets[2] intValue];
        }
        
        // Otherwise, we're just holding garbage - keep everything at the lowest bet
    }
    
    // How do the other players look?
    for (Player* p in players) {
        HandEvaluation* bestOpponentHand = nil;
        
        if ([p isStillInGame] && p != aiPlayer) {
            NSArray<Card*>* opponentFaceupCards = [p getFaceupCards];
            
            // Don't bother going through this evaluation for a hand unless at least two cards are showing
            if ([opponentFaceupCards count] > 2) {
                NSArray<HandEvaluation*>* evaluations = [self evaluatePlayerHand:opponentFaceupCards];
                
                // What is the likeliest hand?
                HandEvaluation* opponentLikeliestHand = [HandEvaluator selectLikeliestHandEvaluation:evaluations];
                
                // TODO: Add a method to compare incomplete hands on HandEvaluator. This is sloppy but good enough for now
                if ([opponentLikeliestHand type] < [bestOpponentHand type]) {
                    bestOpponentHand = opponentLikeliestHand;
                }
            }
        }
        
        // Compare the AI's target hand to what the best-looking opponent is showing
        if (bestOpponentHand) {
            // If the AI is basically tied with someone else, play the safest bet
            if ([bestOpponentHand type] == [targetedHand type]) {
                return [bets[0] intValue];
            }
            else if ([bestOpponentHand type] == [targetedHand type] - 1) {
                return [bets[0] intValue];
            }
            // If it looks like we might get clobbered, fold
            else if ([bestOpponentHand type] < [targetedHand type] - 2) {
                return -1;
            }
        }
    }
    
    // If the AI bet beats the user's holdings, then lower it to what we can afford
    if (aiBet > [aiPlayer holdings]) {
        // Jump down to the lowest bet (we're running out, so just go low to save money for later)
        if ([bets[0] intValue] < [aiPlayer holdings]) {
            aiBet = [bets[0] intValue];
        }
        // Nope. There's nowhere to go but out
        else {
            return -1;
        }
    }
    
    // Ditto the maximum bet
    if (maximumBetForThisHand > [aiPlayer holdings]) {
        // If we can afford the lowest bet, go with that
        if ([bets[0] intValue] < maximumBetForThisHand && [bets[0] intValue] < [aiPlayer holdings]) {
            maximumBetForThisHand = [bets[0] intValue];
        }
        else maximumBetForThisHand = -1;    // Fold
    }
    
    // Okay - now see how this compares to the bet on the table
    if (aiBet < currentBet) {
        // If the betting's gotten a little too rich, fold
        if (currentBet > [aiPlayer holdings]) return -1;
        if (maximumBetForThisHand < currentBet) return -1;
        
        // Otherwise, let's do it
        aiBet = currentBet;
    }
    
    // If we can't afford what we want to bet, try to go lower ...
    if (aiBet > [aiPlayer holdings]) {
        // Is the lowest bet still available?
        if ([bets[0] intValue] >= currentBet) {
            aiBet = [bets[0] intValue];
        }
        // Nope. There's nowhere to go but out
        else {
            return -1;
        }
    }
    
    NSLog(@"Turn %d. Player %@ bets %d with hand %@ and evaluation: %@", currentRound, [aiPlayer name], aiBet, [aiPlayer hand], targetedHand);
    
    return aiBet;
}

// Figure out which player holds the hand in this ranking
-(Player*)getPlayerForHandEvaluation:(HandEvaluation*)ranking {
    if (ranking) {
        for (Player* p in players) {
            Card* sampleCard = [[ranking cardsToKeep] firstObject];
            for (Card* c in [p hand]) {
                if ([sampleCard isEqual:c]) {
                    return p;
                }
            }
        }
    }
    
    // For some reason the player couldn't be matched - this is an error
    return nil;
}

// After the results modal is closed, pop the replay modal
-(void)displayReplayModal {
    // Make sure everyone can go. Each player must be able to cover five minimum bets. We make an exception for the Beast of course, because the point is to wipe him out
    bool everyoneIsStillIn = true;
    for (Player* p in players) {
        if (p.playerType != PlayerTypeNPC_Beast && p.holdings < [bets[0] intValue] * 5) {
            everyoneIsStillIn = false;
            break;
        }
    }
    
    // The player can only try again if they can at least make the minimum bet for three rounds
    [super showReplayModal:everyoneIsStillIn];

//    // TODO: Should players with too little money to cover a round of betting just fold?
//
//    // If the player and at least one NPC are in, offer to go another round
//    if ([[self getHumanPlayer] isStillInGame] && [[self getHumanPlayer] holdings] > [bets[0] intValue] * 5 && [self atLeastOneOtherPlayerCanAffordToKeepBetting:[bets[0] intValue] * 5]) {
//        [super showReplayModal:YES];
//    }
//    // Otherwise, the table is dead
//    else {
//        [super showReplayModal:NO];
//    }
}

#pragma mark Methods to be implemented by subclasses


-(NSArray<Card*>*)getHandWithoutWildCards:(NSArray<Card*>*)hand {
    NSAssert(NO, @"Method should be overridden by subclasses");
    return nil;
}


-(void)advanceRound {
    NSAssert(NO, @"Method should be overridden by subclasses");
}

// The player bets at the start of the round
- (void)playerBets:(id)sender
{
    UIButton* betButton = (UIButton*)sender;
    int playerBet = [bets[betButton.tag] intValue];
    
    int bet = playerBet;
    [self playerPlacesBet:0 bet:bet];
    [self updatePlayerCards:0];
    
    NSLog(@"Human player bets %d on the hand: %@", bet, [players[0] hand]);
    
    currentBet = bet;
    
    [self advanceRound];
}

// The player folds rather than bet
-(void)foldInsteadOfBet {
    if ([self playerFolds:0])
    {
        [bettingStatusLabel setText:@"Better part o’ valor, a’yup."];
        
        // If we're continuing the game, show the Next button so the player can advance it
        [self updateActionButtons:ActionButtonStateNextButton];
    }
}

@end
