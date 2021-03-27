//
//  HGPGameAnacondaViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 7/21/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPGameAnacondaViewController.h"

@interface HGPGameAnacondaViewController ()

@end

@implementation HGPGameAnacondaViewController

#pragma mark Presentation logic

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //////////////////////////////////////////////////
    // Anaconda-specific UI elements
    
    // Set up the holdings display
    holdingsDisplayView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, 0.0f, self.view.frame.size.width - MARGIN_STANDARD * 2, 50.0f)];  // We're tucking this up above the top border because we don't yet need the character portrait area
    [self.view addSubview:holdingsDisplayView];

    CGRect bettingStatusFrame = bettingStatusLabel.frame;
    //bettingStatusFrame.origin.y += bettingStatusLabel.frame.size.height;
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

    // Draw view elements
    [self displayHoldings];
    [self displayBetButtons];
    
    // Pot starts at 0
    pot = 0;
    
    // With the view established, initialize the game
    [self initializeGame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Game - Anaconda"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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

// Update the holdings labels to the current values
-(void)updateHoldings {
    UIImage* deselectedBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_deselected" ofType:@"png"]];
    UIImage* selectedBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_selected" ofType:@"png"]];
    UIImage* deselectedFreeFloatingBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_freefloating_deselected" ofType:@"png"]];
    UIImage* selectedFreeFloatingBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_freefloating_selected" ofType:@"png"]];
    
    for (int i = 0; i < [playerHoldingsLabels count]; i++) {
        [playerHoldingsLabels[i] setText:[NSString stringWithFormat:@"$%d", [players[i + 1] holdings]]];
        [playerHoldingsBackgrounds[i] setImage:playerIndex == i + 1 ? selectedBackground : deselectedBackground];
    }
    
    [playerHoldingsLabel setText:[NSString stringWithFormat:@"$%d", [players[0] holdings]]];
    [playerHoldingsBackgroundImageView setImage:playerIndex == 0 ? selectedFreeFloatingBackground : deselectedFreeFloatingBackground];
    
    [potHoldingsLabel setText:[NSString stringWithFormat:@"$%d", pot]];
}

-(void)styleHoldingsLabel:(UILabel*)label isOnLightBackground:(bool)isOnBackground {
    [label setNumberOfLines:1];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontForBody]];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setTextColor:(isOnBackground ? [UIColor blackColor] : [UIColor whiteColor])];
}

-(void)displayBetButtons {
    if (bets && [bets count] > 0) {
        CGFloat buttonAvailableSpaceWidth = betButtonDisplayView.frame.size.width * 0.8;
        
        CGFloat buttonBackgroundWidth = CGRectGetHeight(betButtonDisplayView.frame) * 1.44f; // The height-to-width ratio observed on the actual image asset
        
        CGFloat currentPositionX = buttonBackgroundWidth / 2;
        
        CGFloat spaceBetweenButtons = (buttonAvailableSpaceWidth - (currentPositionX * 2.0f) - (buttonBackgroundWidth * ([bets count] + 1))) / ([bets count] + 1);
        
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
    
    // And most important of all: Pass the Trash
    passCardsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, betButtonDisplayView.frame.size.width, betButtonDisplayView.frame.size.height)];
    [passCardsButton setTitle:@"Pass the Trash" forState:UIControlStateNormal];
    [super styleButton:passCardsButton];
    [passCardsButton addTarget:self action:@selector(passCards) forControlEvents: UIControlEventTouchUpInside];
    [betButtonDisplayView addSubview:passCardsButton];
    
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
    
    // Finally, set up the Quit button that we see if the game ends abruptly (like if all but one player is eliminated)
    quitButton = [[UIButton alloc] initWithFrame:betButtonDisplayView.frame];
    [quitButton setTitle:@"That’s the Game" forState:UIControlStateNormal];
    [self styleButton:quitButton];
    [quitButton addTarget:self action:@selector(displayReplayModal) forControlEvents: UIControlEventTouchUpInside];
    [quitButton setHidden:YES];
    
    [self.view addSubview:quitButton];
    
    // Initialize it to our first state, Pass Cards. This takes care of hiding all the buttons we don't need yet
    [self updateActionButtons:ActionButtonStatePassCards];
}

-(void)updateActionButtons:(ActionButtonState)state {
    for (UIButton* b in betButtons) {
        [b setHidden:YES];
    }
    [passCardsButton setHidden:YES];
    [nextButton setHidden:YES];
    [matchBetButton setHidden:YES];
    [foldButton setHidden:YES];
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
                
                // Disable the button interactions until the animation is done
                [betButtons[i] setUserInteractionEnabled:NO];
            }
            
            // The last button, FOLD, is always available ... if yer a quitter
            [[betButtons lastObject] setHidden:NO];
            
            // Update the holdings, which also makes sure that the YOU background goes to its selected state
            [self updateHoldings];
            
            // And we lump the sliding menu view in with these as well
            [slidingMenuView setHidden:NO];
            [slidingMenuHitTargetAreaView setHidden:NO];
            
            break;
        }
        case ActionButtonStateNextButton: {
            [nextButton setHidden:NO];
            break;
        }
        case ActionButtonStatePassCards: {
            [passCardsButton setHidden:NO];
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

- (void)createCardDisplay {
    ////////////////////////////////////////////////////////
    // Clear any older displays
    int delayInCardAppearance = 0.0f;
    
    if (npcCardViews && [npcCardViews count] > 0) {
        delayInCardAppearance = 1.0f;
        for(UIView* view in npcCardViews) {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [view setAlpha:0.0f];
                             }
                             completion:^(BOOL finished){
                                    [view removeFromSuperview];
                             }];
        }
    }

    ////////////////////////////////////////////////////////
    // Set up the rectangles in which we're going to display each hand
    int countNPCs = (int)[players count] - 1;
    
    CGFloat heightNPCFrames = CGRectGetHeight(cardDisplayView.frame) * 0.45f;
    CGFloat widthNPCFrames = CGRectGetWidth(cardDisplayView.frame) / countNPCs;
    
    NSMutableArray* npcViews = [[NSMutableArray alloc] init];
    
    // Set up the array that holds the set of card image views for each NPC
    npcCardViewCollections = [[NSMutableArray alloc] initWithCapacity:[players count] - 1];
    
    int npcIndex = 0;
    for (Player* p in players) {
        if ([p playerType] != PlayerTypeHuman) {
            CGFloat rectY = 0.0f;
            UIView* npcView = [[UIView alloc] initWithFrame:CGRectMake(widthNPCFrames * npcIndex, rectY, widthNPCFrames, heightNPCFrames)];
            [npcView setAlpha:0.0f];
            [self populateCardDisplayWithHand:[p hand] inView:npcView isHumanPlayer:NO];
            [npcViews addObject:npcView];
            [UIView animateWithDuration:0.5
                                  delay:delayInCardAppearance
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [npcView setAlpha:1.0f];
                             }
                             completion:^(BOOL finished){
                                 // No action
                             }];
            
            npcIndex++;
        }
    }
    
    npcCardViews = npcViews;
    
    Player* human = [super getHumanPlayer];
    UIView* playerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, heightNPCFrames + MARGIN_THIN, CGRectGetWidth(cardDisplayView.frame), CGRectGetHeight(cardDisplayView.frame) - heightNPCFrames)];
    [self populateCardDisplayWithHand:[human hand] inView:playerView isHumanPlayer:YES];
}

-(void)populateCardDisplayWithHand:(NSArray<Card*>*)hand inView:(UIView*)playerView isHumanPlayer:(bool)isHuman {
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
    
    if (isHuman) {
        // We're going to fade in the cards. This delay can be set in case we need to fade out the old cards first
        int delayInCardAppearance = 0.0f;
        
        // If the human player cards were already drawn (say, for a previous round), clear them out
        if (playerCardButtons) {
            delayInCardAppearance = 1.0f;
            for (UIButton* button in playerCardButtons) {
                [UIView animateWithDuration:0.5
                                      delay:0.0
                                    options: UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     [button setAlpha:0.0f];
                                 }
                                 completion:^(BOOL finished){
                                     [button removeFromSuperview];
                                 }];
            }
        }
        
        NSMutableArray* buttons = [[NSMutableArray alloc] init];
        for (Card* card in hand) {
            // For the player, initialize the buttons that they can tap
            UIButton* cardButton = [[UIButton alloc] initWithFrame:CGRectMake(currentPositionX, currentPositionY, cardWidth, cardHeight)];
            [cardButton setImage:[card getImage] forState:UIControlStateNormal];
            [cardButton setTag:[buttons count]];
            [cardButton addTarget:self action:@selector(selectCard:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add the swipe recogizers
            UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
            swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
            [cardButton addGestureRecognizer:swipeRight];
            
            UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
            swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            [cardButton addGestureRecognizer:swipeLeft];
            
            [cardButton setAlpha:0.0f];
            
            [UIView animateWithDuration:0.5
                                  delay:delayInCardAppearance
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [cardButton setAlpha:1.0f];
                             }
                             completion:^(BOOL finished){
                                 // No action
                             }];
            
            [buttons addObject:cardButton];
            [playerView addSubview:cardButton];
            
            currentPositionX += spacingX;
        }
        
        playerCardButtons = buttons;
    }
    else {
        NSMutableArray<UIImageView*>* cardImageViews = [[NSMutableArray alloc] init];
        for (Card* card in hand) {
            UIImageView* cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(currentPositionX, currentPositionY, cardWidth, cardHeight)];
            
            if ([card isFaceup]) {
                [cardImage setImage:[card getImage]];
            }
            else {
                [cardImage setImage:[Card getCardBackImage]];
            }
            
            [playerView addSubview:cardImage];
            [cardImageViews addObject:cardImage];
            
            currentPositionX += spacingX;
        }
        
        // TODO: This assumes that we're calling this method in order from the first NPC to the last. Add a belt and suspenders to this
        [npcCardViewCollections addObject:cardImageViews];
    }
    
    [cardDisplayView addSubview:playerView];
}

// At the end of a round, update the player card buttons to show the player's current hand and to set the buttons back to their correct positions
-(void)updatePlayerCards {
    NSArray<Card*>* playerHand = [[self getHumanPlayer] hand];
    for (int i = 0; i < [playerCardButtons count]; i++) {
        UIButton* button = playerCardButtons[i];
        Card* card = playerHand[i];
        
        [button setImage:[card getImage] forState:UIControlStateNormal];
        [button setImage:[card getImage] forState:UIControlStateSelected];
        
        if ([button isSelected])
        {
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.y =  buttonFrame.origin.y + 10.0f;
            button.frame = buttonFrame;
        }
        
        [button setSelected: false];
    }
}

// Update the player cards with animation
-(void)updatePlayerCards:(Player*)player cardViews:(NSArray<UIView*>*)cardViews outgoingCards:(NSArray<Card*>*)outgoingCards incomingCards:(NSArray<Card*>*)incomingCards slideLeft:(bool)slideLeft {
    
    // First, update the hand itself
    NSMutableArray<Card*>* playerHand = [NSMutableArray arrayWithArray:[player hand]];
    
    NSMutableIndexSet *indicesOfOutgoingCards = [[NSMutableIndexSet alloc] init];
    
    for (int i = 0; i < [playerHand count]; i++) {
        for (Card* c in outgoingCards) {
            if ([c isEqual:playerHand[i]]) {
                [indicesOfOutgoingCards addIndex:i];
                break;
            }
        }
    }
    
    // Remove the outgoing cards ...
    [playerHand removeObjectsAtIndexes:indicesOfOutgoingCards];
    
    // ... insert the incoming cards at the end
    [playerHand addObjectsFromArray:incomingCards];

    [player setHand:playerHand];
    
    //////////////////////////////////////////////////////
    // Now we mess around with the buttons.
    NSMutableArray<UIView*>* cardViewsToReorder = [NSMutableArray arrayWithArray:cardViews];
    
    // Make sure the card views are in the correct order in the array. Not sure why this is even necessary, but after the first round, they are sometimes re-sorted
    NSSortDescriptor *tagSortDescriptor;
    tagSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag"
                                                 ascending:YES];
    cardViewsToReorder = [NSMutableArray arrayWithArray:[cardViewsToReorder sortedArrayUsingDescriptors:@[tagSortDescriptor]]];
    
    //First, capture their locations (without a selection state), this will come in handy when the cards start flying around
    NSMutableArray* cardRects = [[NSMutableArray alloc] init];
    for (UIView* cardView in cardViewsToReorder) {
        CGRect frame = cardView.frame;

        [cardRects addObject:[NSValue valueWithCGRect:frame]];
    }
    
    // Set up the final array of card views
    NSArray<UIView*>* outgoingCardViews = [cardViewsToReorder objectsAtIndexes:indicesOfOutgoingCards];
    [cardViewsToReorder removeObjectsAtIndexes:indicesOfOutgoingCards];
    
    // Grab the keeper card buttons while we have a sec ...
    NSArray<UIView*>* keptCardViews = [NSArray arrayWithArray:cardViewsToReorder];
    
    // ... and now reinsert the outgoing buttons at the end of the array
    [cardViewsToReorder addObjectsFromArray:outgoingCardViews];

    // Clean up the card button tags and selection states
    for (int i = 0; i < [cardViewsToReorder count]; i++) {
        cardViewsToReorder[i].tag = i;
    }
    
    // Update the card views collection with the reordered cards
    cardViews = cardViewsToReorder;
    
    // Also sort the subviews so that they land correctly when we're done moving them around
    cardViewsToReorder = [NSMutableArray arrayWithArray:[cardViewsToReorder sortedArrayUsingDescriptors:@[tagSortDescriptor]]];
    
    // Now the fun part. Use the indices of the cards we changed to trigger the animations
    // Sweep out the old cards ...
    for (int i = 0; i < [outgoingCardViews count]; i++) {
        UIView* cardView = outgoingCardViews[i];
        
        CGRect offscreenRect = cardView.frame;
        
        offscreenRect.origin.x = slideLeft ? 0 - CGRectGetWidth(cardView.frame) : CGRectGetWidth(self.view.frame);
        
        [UIView animateWithDuration:1.0
                              delay:0.5
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cardView.frame = offscreenRect;
                         }
                         completion:^(BOOL finished){
                             // Now, replace it with a new image and slide it onto the end
                             if ([cardView isKindOfClass:[UIButton class]]) {
                                 [((UIButton*)cardView) setImage:[incomingCards[i] getImage] forState:UIControlStateNormal];
                                 [((UIButton*)cardView) setImage:[incomingCards[i] getImage] forState:UIControlStateSelected];
                             }
                             else if ([cardView isKindOfClass:[UIImageView class]]) {
                                 if ([incomingCards[i] isFaceup]) {
                                     [(UIImageView*)cardView setImage:[incomingCards[i] getImage]];
                                 }
                                 else {
                                     [(UIImageView*)cardView setImage:[Card getCardBackImage]];
                                 }
                             }
                                 
                             CGRect returnOffscreenRect = cardView.frame;
                             returnOffscreenRect.origin.x = slideLeft ? CGRectGetWidth(self.view.frame) : 0 - CGRectGetWidth(self.view.frame);  // For slideRight, the x is exaggerated, but we need to push it off pretty far to ensure it starts off-screen
                             cardView.frame = returnOffscreenRect;
                             
                             // We can still use i to set the card's destination at the end of the hand; outgoing cards 0, 1, 2 become incoming cards 5, 6, 7
                             int updatedIndexForView = (int)([playerHand count] - [outgoingCards count]) + i;
                             
                             // Correct/confirm its zIndex now so that when it slides in, it's in the right order
                             [[cardView superview] insertSubview:cardView atIndex:updatedIndexForView];
                             
                             CGRect destinationRect = [cardRects[updatedIndexForView] CGRectValue];
                             
                             // Run the animation for a little longer if we're sliding from the right, as it has to travel farter
                             [UIView animateWithDuration:slideLeft ? 1.0 : 1.5
                                                   delay:1.0
                                                 options: UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  cardView.frame = destinationRect;
                                              }
                                              completion:^(BOOL finished){
                                                  // Reenable the bet buttons. (I realize this will happen seven times, but that should be fine)
                                                  for (UIButton* b in betButtons) {
                                                      [b setUserInteractionEnabled:YES];
                                                  }
                                              }];
                         }];
    }
    
    // While that's going on, collapse the cards we're keeping to fill the gaps (e.g. if cards 1 and 2 leave, push 3 next to 0). Hopefully we use the delay to time this to happen before the cards start coming in at the end
    for (int i = 0; i < [keptCardViews count]; i++) {
        // Ensure that it lands at the correct destination, if it is not already there
        UIView* cardView = keptCardViews[i];
        CGRect destinationRect = [cardRects[i] CGRectValue];
        if (CGRectGetMinX(cardView.frame) != CGRectGetMinX(destinationRect)) {
            [UIView animateWithDuration:1.0
                                  delay:1.5
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cardView.frame = destinationRect;
                             }
                             completion:^(BOOL finished){
                             }];
        }
    }
}

-(void)updateNPCCards:(int)npcIndex {
    Player* p = players[npcIndex];
    
    // TODO: I hate this transposition, that we're going from an array that includes the human player to one that doesn't. Seems very prone to error. Would it be easier for the player to have a property for their card view?
    UIView* npcCardView = npcCardViews[npcIndex - 1];
    
    // Remove the old cards
    [[npcCardView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // ... and populate the new ones
    [self populateCardDisplayWithHand:[p hand] inView:npcCardView isHumanPlayer:NO];
}

// Allow the player to swipe cards back and forth for easier review
- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture
{
    UIView* view = gesture.view;
    NSMutableArray<Card*>* playerHand = [[NSMutableArray alloc] initWithArray:[[self getHumanPlayer] hand]];
    NSSortDescriptor *tagSortDescriptor;
    
    // Make sure the buttons are sorted by tag or else this will get confused
    tagSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag"
                                                    ascending:YES];
    NSMutableArray<UIButton*>* playerButtons = [NSMutableArray arrayWithArray:[playerCardButtons sortedArrayUsingDescriptors:@[tagSortDescriptor]]];
    
    int cardIndex = (int)view.tag;
    
    // Swap the cards in the player's hand
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight && cardIndex < [playerHand count]) {
        [playerHand exchangeObjectAtIndex:cardIndex withObjectAtIndex:cardIndex + 1];
        [playerButtons exchangeObjectAtIndex:cardIndex withObjectAtIndex:cardIndex + 1];
        
        // This method moves the buttons on-screen. The current method reassigns them in the array. I hate doing this in two places but it's practical for now ...
        [self exchangeCardButton:playerButtons[cardIndex] withCardButton:playerButtons[cardIndex + 1]];
    }
    
    else if (gesture.direction == UISwipeGestureRecognizerDirectionLeft && cardIndex > 0) {
        [playerHand exchangeObjectAtIndex:view.tag withObjectAtIndex:cardIndex - 1];
        [playerButtons exchangeObjectAtIndex:cardIndex withObjectAtIndex:cardIndex - 1];
        
        [self exchangeCardButton:playerButtons[cardIndex] withCardButton:playerButtons[cardIndex - 1]];
    }
    
    [[self getHumanPlayer] setHand:playerHand];
    playerCardButtons = playerButtons;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"
                                                          action:@"Swipe Cards"
                                                           label:NSStringFromClass([self class])
                                                           value:@1] build]];
}

// Move the buttons and reassign their tags to keep them sequential
-(void)exchangeCardButton:(UIButton*)buttonA withCardButton:(UIButton*)buttonB {
    
    [self makeSureButtonIsDeselected:buttonA];
    [self makeSureButtonIsDeselected:buttonB];
    
    // Swap the tags
    int exchangeTag = (int)buttonA.tag;
    buttonA.tag = buttonB.tag;
    buttonB.tag = exchangeTag;
    
    CGRect destinationRectA = buttonB.frame;
    CGRect destinationRectB = buttonA.frame;
    
    // ... and then swap the buttons on-screen
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         buttonB.frame = destinationRectB;
                         buttonA.frame = destinationRectA;
                     }
                     completion:^(BOOL finished){
                     }];
}

-(void)makeSureButtonIsDeselected:(UIButton*)button {
    if ([button isSelected]) {
        CGRect buttonFrame = button.frame;
        buttonFrame.origin.y = buttonFrame.origin.y + 10.0f;
        button.frame = buttonFrame;
        
        [button setSelected:NO];
    }
}

// The player tries to select a card. If they select all of the cards they need for this round, the bet buttons enable and we can end the round
-(void)selectCard:(id)sender {
    // This only works if we're passing, not betting
    if (passCardsButton.isHidden) {
        return;
    }
    
    // How many cards are already selected?
    int countOfSelectedButtons = 0;
    for (UIButton* b in playerCardButtons) {
        if ([b isSelected]) countOfSelectedButtons++;
    }
    
    UIButton* cardButton = (UIButton*)sender;
    
    // If the player has already selected as many cards as we can, and the player tries to select another one, ignore it
    if (countOfSelectedButtons == cardsToSelectThisRound) {
        if (![cardButton isSelected]) return;
    }
    
    // Flip the card's selected state
    [cardButton setSelected:![cardButton isSelected]];
    countOfSelectedButtons += [cardButton isSelected] ? 1 : -1;
    
    // TODO: Find a better presentation for selection
    CGRect buttonFrame = cardButton.frame;
    buttonFrame.origin.y =  buttonFrame.origin.y + ([cardButton isSelected] ? -10.0f : 10.0f);
    cardButton.frame = buttonFrame;
    
    // If the necessary number of cards is selected, the bet buttons should enable
    [passCardsButton setEnabled:(countOfSelectedButtons == cardsToSelectThisRound)];
}

#pragma mark Game logic methods

-(void)resetGame {
    if (replayModal) [replayModal removeFromSuperview];
    if (resultsModal) [resultsModal removeFromSuperview];
    
    // Make sure all of the players are back in the game
    for (Player* p in players) {
        [p setIsStillInGame:YES];
    }
    
    [self initializeGame];
}

-(void)initializeGame {
    // The pot starts at 0
    pot = 0;
    
    // Set up cards
    deck = [self shuffleDeck:[self createDeck:NO]];
    
    // Deal their hands
    int deckIndex = 0;
    for (Player* p in players) {
        NSIndexSet* range = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(deckIndex, HAND_SIZE)];
        NSArray<Card*>* hand = [deck objectsAtIndexes:range];
        [p setHand:hand];
        deckIndex += HAND_SIZE;
        
        // The NPC's cards start facedown
        if ([p playerType] != PlayerTypeHuman) {
            for (Card* c0 in hand) {
               [c0 setIsFaceup:NO];
            }
        }
    }
    
    // Each player antes up at the start of the game, starting the pot
    int ante = [bets[0] intValue];
    for (Player* p in players) {
        p.holdings -= ante;
        pot += ante;
    }
    [self updateHoldings];
    
    // Draw the cards
    [self createCardDisplay];

    currentRound = RoundThreeLeft;
    
    
    // Kick off the first round
    [self initializeRound];
}

-(void)initializeRound {
    // The round always starts with the human player going first - but they may be out of the game
    bool isHumanPlayerStillInTheGame = [[self getHumanPlayer] isStillInGame];
    
    switch(currentRound) {
        case RoundThreeLeft:
            [bettingStatusLabel setText:@"Pass three cards to the player on your left, and bet."];
            cardsToSelectThisRound = 3;
            break;
        case RoundTwoRight:
            [bettingStatusLabel setText:[NSString stringWithFormat:@"Next, pass two cards to the player on your right, and bet."]];
            cardsToSelectThisRound = 2;
            break;
        case RoundOneLeft:
            [bettingStatusLabel setText:[NSString stringWithFormat:@"Finally, pass one card to the player on your left, and bet."]];
            cardsToSelectThisRound = 1;
            break;
    }
    
    // Whether or not the player is in, their cards are disabled right now
    [passCardsButton setEnabled:NO];
    
    if (isHumanPlayerStillInTheGame) {
        // ... and now we wait for the player to make their selections
        [self updateActionButtons:ActionButtonStatePassCards];
    }
    else {
        // Pass the cards without waiting for the player. Clear out any messages that come up when that method runs
        [self passCards];
        [bettingStatusLabel setText:@""];
    }
}

-(void)advancePlayer {
    // Queue up the next player and determine if we've advanced a round
    bool isANewRound = [self moveToNextPlayerAndCheckForNextRound];

    // Check to see if the game is over
    if (currentRound > 3 || ([super getCountOfPlayersLeft] == 1)) {
        [self endGame];
    }
    else {
        // If we're back to the human, advance to the next round
        if (playerIndex == 0) {
            [self initializeRound];
        }
        // It's an AI - have it bet
        else {
            // If we just advanced to a new round but the human player did NOT go, it must be because they folded. Take care of initializing the round here. That method will update the button display, but it will be overridden in a sec once the AI bets
            if (isANewRound) {
                [self initializeRound];
            }
            
            Player* currentAi = players[playerIndex];
            
            int bet = [self calculateAiBet:currentAi];
            [self playerPlacesBet:playerIndex bet:bet];
            
            // Does the AI fold?
            if (-1 == bet) {
                [self playerFolds:playerIndex];
                [bettingStatusLabel setText:[NSString stringWithFormat:@"%@ folds.", [currentAi name]]];
                [self updateActionButtons:ActionButtonStateNextButton];
            }
            // Nope, they bet:
            else {
                // If the AI feels good, it'll raise
                if (bet > currentBet) {
                    currentRaiseAmount = bet - currentBet;
                    
                    // The player is the first to match. Once they do, the matchBet method will work through the other AIs' response
                    if ([[super getHumanPlayer] isStillInGame]) {
                        [bettingStatusLabel setText:[NSString stringWithFormat:@"%@ bets $%d. Do you match?", [currentAi name], bet]];
                        
                        [self updateActionButtons:ActionButtonStateMatchOrFoldButton];
                    }
                    else {
                        // Skip straight to the AI actions
                        [bettingStatusLabel setText:[NSString stringWithFormat:@"%@ bets $%d", [currentAi name], bet]];
                        [self aiMatchesBet];
                    }
                }
                // Otherwise, they call
                else {
                    [bettingStatusLabel setText:[NSString stringWithFormat:@"%@ bets $%d", [currentAi name], bet]];
                    [self updateActionButtons:ActionButtonStateNextButton];
                }
            }
        }
    }
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

// Review all of the AIs who have already gone this turn and see if they will match the current player's raise
-(void)aiMatchesBet {
    // Display this with a timer ...
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    // Work through the AIs
    for (int i = 1; i < playerIndex; i++) {
        if ([players[i] isStillInGame]) {
            // TODO: Each player should decide if they want to raise
            if (currentRaiseAmount > [players[i] holdings]) {
                [results addObject:[NSString stringWithFormat:@"%@ is out of the game.", [players[i] name]]];
                if (![self playerFolds:i]) {
                    break;
                }
            }
            else {
                [results addObject:[NSString stringWithFormat:@"%@ sees the bet.", [players[i] name]]];
                [self playerPlacesBet:i bet:currentRaiseAmount];
            }
        }
    }

    // A number of people may have folded just now - make sure we still have some players left before we proceed
    if ([super getCountOfPlayersLeft] > 1) {
        // TODO: This is a shameless kludge. Basically if the player is still around they can try to match the bet, and you don't need to repeat the bettingStatusLabel text - we already had time to read it. If the player is NOT around and we're racing straight into this, then we DO want to concatenate the text. Note that it would be simpler if we could just update the label from anywhere statelessly ... then we wouldn't have to communicate about player actions down here
        if ([[self getHumanPlayer] isStillInGame]) {
            // If there are no AI actions to report, and the player just acted, then we need to say something or the screen will be blank
            if (!results || [results count] == 0) {
                [bettingStatusLabel setText:@"Nobody’s gonna push you out of the game."];
            }
            // If we do have AI actions, list 'em out
            else {
                [bettingStatusLabel setText:[results componentsJoinedByString:@" "]];
            }
        } else {
            // The player has folded and nobody else needs to match the bet. If anyone else took an action, report it
            if (results && [results count] > 0) {
                [bettingStatusLabel setText:[results componentsJoinedByString:@" "]];
            }
        }
        
        // Update the current bet
        currentBet += currentRaiseAmount;
        
        [self updateActionButtons:ActionButtonStateNextButton];
    }
    else {
        // No action needed - the playerFolds method will trigger the end of the game
    }
}

// The specified player folds. Returns true if the game can continue or false if we're out of players and the game is ending
-(bool)playerFolds:(int)index {
    // TODO: What else do we need to do to clean up?
    [players[index] setIsStillInGame:NO];
    
    // If the player just beat the beast, that interrupts the game
    if ([self checkIfBeastIsBeaten:players[index]]) return false;
    
    if ([super getCountOfPlayersLeft] < 2) {
        [self endGame];
        return false;
    }
    else return true;
}

#pragma mark Button Actions

// Player hits "Next" while waiting for an AI to go
- (void)next {
    [self advancePlayer];
}

// Player passes the cards and gets ready to bet
- (void)passCards
{
    // FIXME: There's an error that happens sometimes during this animation:
    // 2017-10-08 23:22:22.786837-0400 Haxan Gulch Poker[32297:2444172] *** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayM objectAtIndexedSubscript:]: index 2 beyond bounds [0 .. 1]'
    [bettingStatusLabel setText:@"Place your bet."];
    
    bool isGoingLeft = (currentRound == RoundThreeLeft || currentRound == RoundOneLeft);
    
    // Identify the cards that each player is passing
    NSMutableArray<NSArray<Card*>*>* trashCards = [[NSMutableArray alloc] init];
    for (Player* p in players) {
        NSArray<Card*>* trash = [self identifyCardsToReject:p number:cardsToSelectThisRound];
        [trashCards addObject:trash];
    }
    
    // Pass the trash
    int playerCount = (int)[players count];
    for (int i = 0; i < playerCount; i++) {
        int outgoingCardsPlayerIndex = i;

        // Find the player we're getting cards from, skipping any eliminated players
        int incomingCardsPlayerIndex = outgoingCardsPlayerIndex;
        if (isGoingLeft) {
            incomingCardsPlayerIndex--;
            while (incomingCardsPlayerIndex != outgoingCardsPlayerIndex) {
                if (incomingCardsPlayerIndex < 0) {
                    incomingCardsPlayerIndex = playerCount - 1;
                }
                if ([players[incomingCardsPlayerIndex] isStillInGame]) break;
                else incomingCardsPlayerIndex--;
            }
            // If the incoming player index is back to the current player index, we have an error / the game is over
            if (incomingCardsPlayerIndex == outgoingCardsPlayerIndex) {
                CLS_LOG(@"While trying to reach the incoming player index, we ended up back at the player index: %d", outgoingCardsPlayerIndex);
                NSError* error = [[NSError alloc] initWithDomain:kHGPErrorDomain code:kHGPErrorCodeProgrammingError userInfo:@{}];
                [CrashlyticsKit recordError:error];
            }
        }
        else {
            incomingCardsPlayerIndex++;
            while (incomingCardsPlayerIndex != outgoingCardsPlayerIndex) {
                if (incomingCardsPlayerIndex == (int)[players count]) {
                    incomingCardsPlayerIndex = 0;
                }
                if ([players[incomingCardsPlayerIndex] isStillInGame]) break;
                else incomingCardsPlayerIndex++;
            }
            // If the incoming player index is back to the current player index, we have an error / the game is over
            if (incomingCardsPlayerIndex == outgoingCardsPlayerIndex) {
                CLS_LOG(@"While trying to reach the incoming player index, we ended up back at the outgoing player: %d", outgoingCardsPlayerIndex);
                NSError* error = [[NSError alloc] initWithDomain:kHGPErrorDomain code:kHGPErrorCodeProgrammingError userInfo:@{}];
                [CrashlyticsKit recordError:error];
            }
        }
        
        // If the trash is coming from or going to the human player, make sure it's face up
        if ([players[incomingCardsPlayerIndex] playerType] == PlayerTypeHuman) {
            for(Card* c in trashCards[incomingCardsPlayerIndex]) {
                [c setIsFaceup:YES];
            }
        }
        if ([players[outgoingCardsPlayerIndex] playerType] == PlayerTypeHuman) {
            for(Card* c in trashCards[outgoingCardsPlayerIndex]) {
                [c setIsFaceup:YES];
            }
        }

        // Only move the cards around for players who are still in the game
        if (players[i].isStillInGame) {
            if (i == 0) {
                for(UIButton* b in playerCardButtons) {
                    // Clear out the selected state of the cards before moving them around
                    if ([b isSelected]) {
                        CGRect buttonFrame = b.frame;
                        buttonFrame.origin.y += 10.0f;
                        [UIView animateWithDuration:0.2
                                              delay:0.0
                                            options: UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             b.frame = buttonFrame;
                                         }
                                         completion:^(BOOL finished){
                                         }];
                        
                        [b setSelected: false];
                    }
                }
                
                [self updatePlayerCards:[self getHumanPlayer] cardViews:playerCardButtons outgoingCards:trashCards[outgoingCardsPlayerIndex] incomingCards:trashCards[incomingCardsPlayerIndex] slideLeft:isGoingLeft];
            }
            else {
                // TODO: I hate that this has to offset the index by one because it's just the NPC card view collection ... we might as well make all of these buttons or UIViews and just stick them all in one array, player and NPC
                NSArray<UIImageView*>* cardImageViews = npcCardViewCollections[i - 1];
                [self updatePlayerCards:players[i] cardViews:cardImageViews outgoingCards:trashCards[outgoingCardsPlayerIndex] incomingCards:trashCards[incomingCardsPlayerIndex] slideLeft:isGoingLeft];
            }
        }
    }
    
    [self updateActionButtons:ActionButtonStatePlayerBets];
}

// The player places a bet
-(void)playerBets:(id)sender {
    UIButton* betButton = (UIButton*)sender;
    int playerBet = [bets[betButton.tag] intValue];
    
    int bet = playerBet;
    [self playerPlacesBet:0 bet:bet];
 
    currentBet = bet;
    
    [self advancePlayer];
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

// Determine the specified AI player's bet based on their hand and their opponents. Returns the bet amount (one of the recognized bets), or -1 if the AI folds
-(int)calculateAiBet:(Player*)aiPlayer {
    // If the player is broke, fold
    if ([aiPlayer holdings] < [bets[0] intValue]) {
        return -1;
    }
    
    // We assume there are three bets at this point - small, medium, whammo
    NSArray<Card*>* remainingDeck = [self getUnknownCards];
    
    NSArray<HandEvaluation*>* evaluations = [HandEvaluator evaluatePokerHand:[aiPlayer hand] wildCards:0 unknownCards:remainingDeck handSize:HAND_SIZE];
    
    // What is the likeliest hand?
    HandEvaluation* likeliestHand = [HandEvaluator selectLikeliestHandEvaluation:evaluations];
    
    // The hand that the player wants to get
    HandEvaluation* targetedHand = likeliestHand;
    
    int aiBet = [bets[0] intValue];
    
    // The maximum bet is more forgiving the first two rounds than the third
    int maximumBetForThisHand =  currentRound < 3 ? [bets[1] intValue] : [bets[0] intValue]; [bets[0] intValue];
    
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
        // For the next two, just set it to the lowest bet, but tolerate a slightly higher one
        else if ([evaluation type] < 9 && [evaluation probability] > 0.9f) {
            aiBet = [bets[0] intValue];
            maximumBetForThisHand = [bets[1] intValue];
            
            // Special exception: If we're in a later room, the AI is more likely to match a high bet and not be bluffed out of a game
            if (self.currentRoom >= 2) maximumBetForThisHand = [bets[2] intValue];
            
            break;
        }
        
        // Otherwise, we're just holding garbage - keep everything at the lowest bet
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
        else maximumBetForThisHand = 0.0;
    }
    
    // Okay - now see how this compares to the bet on the table
    if (aiBet < currentBet) {
        // If the betting's gotten a little too rich, fold
        if (currentBet > [aiPlayer holdings]) return -1;
        if (maximumBetForThisHand < currentBet) return -1;
        
        // Otherwise, let's do it
        aiBet = currentBet;
    }
    
    // TODO: What if you can match, but it's the higehst bet and you're holding garbage? Day Baseball partly took care of this by letting you look at other players' cards - in Anaconda, you'll have to make your own assessment, and hopefully also based on the round
    
    // TODO: Also, don't blow the bank this turn if we'll run out of money later ...
    
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

// The player matches another player's raise. Take their money and see if the other players who have already bet will also match it
-(void)matchBet {
    if ([[super getHumanPlayer] isStillInGame]) {
        // The human player matches the bet
        [self playerPlacesBet:0 bet:currentRaiseAmount];
    }
    
    [self aiMatchesBet];
}

// The player folds rather than matching another player's raise
-(void)foldInsteadOfMatch {
    if ([self playerFolds:0]) {
        [self aiMatchesBet];
    }
}

// This player placed a bet; take their money and update the display
-(void)playerPlacesBet:(int)index bet:(int)bet {
    if (bet > -1) {
        [players[index] setHoldings:[players[index] holdings] - bet];
        pot += bet;
        [self updateHoldings];
    }
}

// Helper method to identify the cards a player is going to pass
-(NSArray<Card*>*)identifyCardsToReject:(Player*)p number:(int)countOfCardsToTrash {
    // For the human player, we use the player's selections ...
    if ([p playerType] == PlayerTypeHuman) {
        NSMutableArray<Card*>* playerTrash = [[NSMutableArray alloc] init];
        
        // Identify the cards the user has selected
        for (UIButton* button in playerCardButtons) {
            if (button.isSelected) {
                [playerTrash addObject:[p hand][button.tag]];
            }
        }
        
        return playerTrash;
    }
    // ... for NPCs, we use the evaluations
    else {
        NSMutableArray<Card*>* npcTrash = [[NSMutableArray alloc] init];
        NSMutableArray<Card*>* npcKeep = [[NSMutableArray alloc] init];
        
        NSArray<Card*>* remainingDeck = [deck objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(HAND_SIZE * [players count], [deck count] - (HAND_SIZE * [players count]))]];
        
        NSArray<HandEvaluation*>* evaluations = [HandEvaluator evaluatePokerHand:[p hand] wildCards:0 unknownCards:remainingDeck handSize:HAND_SIZE];
        HandEvaluation* evaluation = [HandEvaluator selectLikeliestHandEvaluation:evaluations];
        
        [npcKeep addObjectsFromArray:[evaluation cardsToKeep]];
        [npcTrash addObjectsFromArray:[evaluation cardsToReject]];
        
        // TODO: Later on, the evaluator should sort the keeper cards from ... at least highest to lowest? Or this method should

        // If there aren't enough cards to trash or even identified to keep, we're going to run into an error when we go to throw away cards. This is usually caused because there were no evaluations, e.g. the player's holding total garbage so no hands were revealed. In that case, just throw away the last three cards
        if (!evaluation || [npcTrash count] + [npcKeep count] < countOfCardsToTrash) {
            npcKeep = [NSMutableArray arrayWithArray:[[p hand] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, HAND_SIZE - countOfCardsToTrash)]]];
            npcTrash = [NSMutableArray arrayWithArray:[[p hand] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(HAND_SIZE - countOfCardsToTrash, countOfCardsToTrash)]]];
        }
        
        // If we don't have enough trash, pull it from the keeper cards
        if ([npcTrash count] < countOfCardsToTrash) {
            int cardsToRedistribute = countOfCardsToTrash - (int)[npcTrash count];
            for (int i = 0; i < cardsToRedistribute; i++) {
                [npcTrash addObject:[npcKeep lastObject]];
                [npcKeep removeObject:[npcKeep lastObject]];
            }
        }
        else if ([npcTrash count] > countOfCardsToTrash) {
            int cardsToRedistribute = (int)[npcTrash count] - countOfCardsToTrash;
            for (int i = 0; i < cardsToRedistribute; i++) {
                [npcKeep addObject:[npcTrash firstObject]];
                [npcTrash removeObject:[npcTrash firstObject]];
            }
        }
        
        return npcTrash;
    }
}

-(void)endGame {
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
                HandEvaluation* finalRank = [HandEvaluator getFinalRankingOfHand:[p hand] wildCards:0];
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
        // TODO: Again, this is a bad way to identify NPCs
        for (int i = 1; i < [players count]; i++) {
            for (Card* c in [players[i] hand]) {
                [c setIsFaceup:YES];
            }
            
            [self updateNPCCards:i];
        }
        
        [self updateHoldings];
        
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

// After the results modal is closed, pop the replay modal
-(void)displayReplayModal {
    // The player can only try again if they can at least make the minimum bet for three rounds
    // Make sure the player and the AIs have enough money to keep playing
    bool everyoneIsStillIn = true;
    for (Player* p in players) {
        if (p.playerType != PlayerTypeNPC_Beast && [p holdings] < [bets[0] intValue] * 3) {
            everyoneIsStillIn = false;
            break;
        }
    }
    
    [super showReplayModal:everyoneIsStillIn];
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

#pragma mark Calculate information about the deck or player status

// Get all the cards remaining in the deck and facedown on the table
-(NSArray<Card*>*)getUnknownCards {
    // All of the cards that will be dealt, have been dealt
    int countOfCardsDealt = ((int)[players count] * HAND_SIZE);
    NSMutableArray* unknownCards = [[NSMutableArray alloc] initWithArray:[deck objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(countOfCardsDealt, 52 - countOfCardsDealt)]]];
    
    for (Player* p in players) {
        for (Card* c in [p hand]) {
            if (![c isFaceup]) [unknownCards addObject:c];
        }
    }
    
    return unknownCards;
}

@end
