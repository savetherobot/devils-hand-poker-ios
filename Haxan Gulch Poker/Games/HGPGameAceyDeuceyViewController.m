//
//  HGPGameAceyDeuceyViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPGameAceyDeuceyViewController.h"

@interface HGPGameAceyDeuceyViewController ()

@end

@implementation HGPGameAceyDeuceyViewController

#pragma mark Presentation logic

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //////////////////////////////////////////////////
    // Acey Deucey specific UI elements
    
    // Each player's status
    holdingsDisplayView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, -5.0f, self.view.frame.size.width - MARGIN_STANDARD * 2, 75.0f)];  // We're tucking this up above the top border because we don't yet need the character portrait area
    [self.view addSubview:holdingsDisplayView];
    
    // The game status/bark label
    gameStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_STANDARD * 2, CGRectGetMaxY(holdingsDisplayView.frame) + MARGIN_THIN, self.view.frame.size.width - MARGIN_STANDARD * 4, LABEL_HEIGHT)];
    
    [gameStatusLabel setFont:[UIFont fontForBody]];
    [gameStatusLabel setTextColor:[UIColor colorWithRed:209/255.0 green:193/255.0 blue:80/255.0 alpha:1.0f]];
    [gameStatusLabel setText:@""];
    [gameStatusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:gameStatusLabel];
    
    // The card display
    
    // The height of the card is whatever fits between the holdings area and the betting area, accounting for the thin margin
    CGFloat cardHeight = CGRectGetMaxY(bettingStatusLabel.frame) - CGRectGetMaxY(gameStatusLabel.frame) - MARGIN_THIN * 3;
    CGFloat cardWidth = cardHeight * WIDTH_IS_PERCENTAGE_OF_HEIGHT;
    
    cardDisplayView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - (cardWidth * 3 + MARGIN_BETWEEN_CARDS * 2)) / 2, CGRectGetMaxY(gameStatusLabel.frame) + MARGIN_THIN, cardWidth * 3 + MARGIN_BETWEEN_CARDS * 2, cardHeight)];
    [self.view addSubview:cardDisplayView];
        
    // Draw view elements
    [self displayHoldings];
    [self displayBetButtons];
    
    // With the view established, initialize the game
    [self initializeGame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Game - Acey Deucey"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Initialize the display of all of the players' (PC and NPC) holdings
- (void)displayHoldings {
    NSMutableArray* labels = [[NSMutableArray alloc] init];
    NSMutableArray* displayLabels = [[NSMutableArray alloc] init];
    NSMutableArray<UIImageView*>* backgrounds = [[NSMutableArray alloc] init];
    // TODO: Connect to these labels so we can update the values
    
    CGFloat playerDisplayWidth = (holdingsDisplayView.frame.size.width - (MARGIN_STANDARD * [players count])) / ([players count] + 1);
    CGFloat currentPositionX = 0.0f;
 
    UIImage* deselectedBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_deselected" ofType:@"png"]];
    
    // Display the players (and the pot) ...
    if (players && [players count] > 0) {
        for (int i = 0; i <= [players count]; i++) {
            // Background
            CGFloat backgroundHeight = CGRectGetHeight(holdingsDisplayView.frame);
            CGFloat backgroundWidth = backgroundHeight * 1.5f;   // Image is 290 x 233
            CGFloat backgroundX = currentPositionX + ((playerDisplayWidth - backgroundWidth) / 2);
            
            UIImageView* holdingsBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(backgroundX, 0.0f, backgroundWidth, backgroundHeight)];
            holdingsBackgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
            [holdingsBackgroundImageView setImage:deselectedBackground];
            [holdingsDisplayView addSubview:holdingsBackgroundImageView];
            
            [backgrounds addObject:holdingsBackgroundImageView];
            
            // Name label
            UILabel* displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(backgroundX + MARGIN_THIN, backgroundHeight * 0.1f, backgroundWidth - (MARGIN_THIN * 2.0f), LABEL_HEIGHT * 2.0f)];
            [displayLabel setNumberOfLines:2];
            [displayLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [displayLabel setText:[NSString stringWithFormat:@"%@", i < [players count] ? [players[i] name] : @"POT"]];
            [displayLabel setTextAlignment:NSTextAlignmentCenter];
            [displayLabel setFont:[UIFont fontForBody]];
            [displayLabel setAdjustsFontSizeToFitWidth:YES];
            [displayLabels addObject:displayLabel];
            
            // Holdings label
            UILabel* holdingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(currentPositionX, CGRectGetMaxY(displayLabel.frame), playerDisplayWidth, LABEL_HEIGHT)];
            [holdingsLabel setNumberOfLines:0];
            [holdingsLabel setText:[NSString stringWithFormat:@"$%d", i < [players count] ? [players[i] holdings] : pot]];
            [holdingsLabel setTextAlignment:NSTextAlignmentCenter];
            [holdingsLabel setFont:[UIFont fontForBody]];
            [labels addObject:holdingsLabel];
 
            [holdingsDisplayView addSubview:displayLabel];
            [holdingsDisplayView addSubview:holdingsLabel];
            currentPositionX += playerDisplayWidth + MARGIN_STANDARD;
        }
    }
    
    playerHoldingsLabels = labels;
    playerHoldingsDisplayLabels = displayLabels;
    playerHoldingsBackgrounds = backgrounds;
}

// Update the holdings labels to the current values
-(void)updateHoldings {
    for (int i = 0; i < [playerHoldingsLabels count] - 1; i++) {
        [playerHoldingsLabels[i] setText:[NSString stringWithFormat:@"$%d", [players[i] holdings]]];
    }
    
    [[playerHoldingsLabels lastObject] setText:[NSString stringWithFormat:@"$%d", pot]];
    
    // Update the backgrounds to show the selected state
    CATransition *transition = [CATransition animation];
    transition.duration = .25f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    UIImage* deselectedBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_deselected" ofType:@"png"]];
    UIImage* selectedBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"char_indicator_selected" ofType:@"png"]];
    
    for (int i = 0; i < [playerHoldingsBackgrounds count] - 1; i++) {
        [playerHoldingsBackgrounds[i] setImage:playerIndex == i ? selectedBackground : deselectedBackground];

        [playerHoldingsBackgrounds[i].layer addAnimation:transition forKey:nil];
    }
}

// Display all of the cards into the view we set up in viewDidLoad. For now, there are three cards, but this could be expanded for different displays
- (void)initializeCardImages {
    CGFloat cardWidth = cardDisplayView.frame.size.height * WIDTH_IS_PERCENTAGE_OF_HEIGHT;
    CGFloat cardHeight = cardDisplayView.frame.size.height;
    
    NSMutableArray* cards = [[NSMutableArray alloc] init];
    
    CGFloat currentPositionX = 0.0f;
    for (int i = 0; i < 3; i++) {
        UIImageView* cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(currentPositionX, 0.0f, cardWidth, cardHeight)];
        
        [cardDisplayView addSubview:cardImage];
        [cards addObject:cardImage];
        
        currentPositionX += cardWidth + MARGIN_BETWEEN_CARDS;
    }
    
    cardImageViews = cards;
}

// Update the card images to the latest cards
-(void)updateCards {
    if (cardsInPlay && [cardsInPlay count] > 0) {
        for (int i = 0; i < [cardsInPlay count]; i++) {
            UIImageView* cardImage = [cardImageViews objectAtIndex:i];
            
            // If this is the middle card, show it face down
            if (i == 1) {
                [cardImage setImage:[Card getCardBackImage]];
            }
            else {
                [cardImage setImage:[cardsInPlay[i] getImage]];
            }
        }
    }
}

// Display the cards to show our progress
- (void)updateProgressView {
    // Remove the previous cards
    [[progressView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Now populate the current ones
    CGFloat progressViewExposedCardWidth = CGRectGetWidth(progressView.frame) / SIZE_OF_DECK;
    CGFloat progressViewCardWidth = progressViewExposedCardWidth * 1.7575f;
    CGFloat progressViewCardHeight = progressViewCardWidth * HEIGHT_IS_PERCENTAGE_OF_WIDTH;
    // TODO: Those calculations seem like the long way around to figuring this out, but, they work ...
    
    int progressThroughDeck = deckIndex + 3; // The 3 represents how many cards were just dealt
    
    UIImage *cardBack = [Card getCardBackSmallImage];
    
    for (int i = 0; i < SIZE_OF_DECK; i++) {
        CGFloat cardY = i >= progressThroughDeck ? 0.0f : progressViewCardHeight / 5;
        CGFloat cardX = i * progressViewExposedCardWidth;
        UIImageView* card = [[UIImageView alloc] initWithFrame:CGRectMake(cardX, cardY, progressViewCardWidth, progressViewCardHeight)];
        [card setImage:cardBack];
        [progressView addSubview:card];
    }
}

-(void)displayBetButtons {
    if (bets && [bets count] > 0) {        
        CGFloat buttonAvailableSpaceWidth = betButtonDisplayView.frame.size.width * 0.8;
        
        int buttonCount = (int)[bets count] + 2;
        
        CGFloat buttonBackgroundWidth = CGRectGetHeight(betButtonDisplayView.frame) * 1.44f; // The height-to-width ratio observed on the actual image asset
        
        CGFloat currentPositionX = buttonBackgroundWidth / 2;
        
        CGFloat spaceBetweenButtons = (buttonAvailableSpaceWidth - (currentPositionX * 2.0f) - (buttonBackgroundWidth * buttonCount)) / buttonCount - 1;
        
        NSMutableArray* buttons = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < buttonCount; i++) {
            UIButton* betButton = [[UIButton alloc] initWithFrame:CGRectMake(currentPositionX, 0.0f, buttonBackgroundWidth, CGRectGetHeight(betButtonDisplayView.frame))];
            
            UILabel* customTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(betButton.frame) *0.4f, CGRectGetWidth(betButton.frame), 20.0f)];
            
            // In Acey Deucey, the last button (which sits outside the bets array) is "POT"
            NSString* buttonText;
            SEL buttonAction;
            
            if (i < [bets count]) {
                buttonText = [NSString stringWithFormat:@"$%@", bets[i]];
                buttonAction = @selector(placeBet:);
            }
            else if ([bets count] == i) {
                buttonText = @"POT";
                buttonAction = @selector(placeBet:);
                indexPotButton = i;
            }
            else {
                buttonText = @"FOLD";
                buttonAction = @selector(fold);
                indexFoldButton = i;
            }
            
            [customTitleLabel setText:buttonText];
            [customTitleLabel setFont:[UIFont fontForButton]];
            [customTitleLabel setTextColor:[UIColor blackColor]];
            [customTitleLabel setTextAlignment:NSTextAlignmentCenter];
            [betButton addSubview:customTitleLabel];
            
            [betButton addTarget:self action:buttonAction forControlEvents: UIControlEventTouchUpInside];
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
    [nextButton addTarget:self action:@selector(nextBet) forControlEvents: UIControlEventTouchUpInside];
    
    // Set up the "high" and "low" buttons for when the player is stuck in the Gulch
    CGFloat twinButtonWidth = (betButtonDisplayView.frame.size.width - MARGIN_STANDARD) / 2;
    gulchLowBetButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, twinButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:gulchLowBetButton];
    [gulchLowBetButton setTitle:@"Lower Than Gulch" forState:UIControlStateNormal];
    [gulchLowBetButton addTarget:self action:@selector(placeBet:) forControlEvents:UIControlEventTouchUpInside];
    [gulchLowBetButton setTag:ActionButtonTypeGulchLow];
    [betButtonDisplayView addSubview:gulchLowBetButton];
    
    gulchHighBetButton = [[UIButton alloc] initWithFrame:CGRectMake(twinButtonWidth + MARGIN_STANDARD, 0.0f, twinButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:gulchHighBetButton];
    [gulchHighBetButton setTitle:@"Higher Than Gulch" forState:UIControlStateNormal];
    [gulchHighBetButton addTarget:self action:@selector(placeBet:) forControlEvents:UIControlEventTouchUpInside];
    [gulchHighBetButton setTag:ActionButtonTypeGulchHigh];
    
    [betButtonDisplayView addSubview:gulchHighBetButton];
    [betButtonDisplayView addSubview:nextButton];
    
    // Finally, set up the Quit button that we'll see at the end of the game
    quitButton = [[UIButton alloc] initWithFrame:betButtonDisplayView.frame];
    [quitButton setTitle:@"That's the Game" forState:UIControlStateNormal];
    [self styleButton:quitButton];
    [quitButton addTarget:self action:@selector(endGame) forControlEvents: UIControlEventTouchUpInside];
    [quitButton setHidden:YES];
    
    [self.view addSubview:quitButton];
    
    // If the player folds, we give them the option to watch the game play out, or skip to the end
    // Set up the "high" and "low" buttons for when the player is stuck in the Gulch
    watchTheGameButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, twinButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:watchTheGameButton];
    [watchTheGameButton setTitle:@"Watch the Game Play Out" forState:UIControlStateNormal];
    [watchTheGameButton addTarget:self action:@selector(nextBet) forControlEvents:UIControlEventTouchUpInside];
    [watchTheGameButton setTag:0];
    [betButtonDisplayView addSubview:watchTheGameButton];
    
    skipToTheEndButton = [[UIButton alloc] initWithFrame:CGRectMake(twinButtonWidth + MARGIN_STANDARD, 0.0f, twinButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:skipToTheEndButton];
    [skipToTheEndButton setTitle:@"Leave the Table" forState:UIControlStateNormal];
    [skipToTheEndButton addTarget:self action:@selector(skipToEnd) forControlEvents:UIControlEventTouchUpInside];
    [skipToTheEndButton setTag:ActionButtonTypeGulchHigh];

    [betButtonDisplayView addSubview:watchTheGameButton];
    [betButtonDisplayView addSubview:skipToTheEndButton];
    
    [self updateActionButtons:ActionButtonStatePlayerBets];
}

#pragma mark Game logic methods

-(void)resetGame {
    if (replayModal) [replayModal removeFromSuperview];
    [self updateActionButtons:ActionButtonStatePlayerBets];
    
    // Clear out the old cards
    [cardImageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Make sure all of the players are back in the game
    for (Player* p in players) {
        [p setIsStillInGame:YES];
    }
    
    [self initializeGame];
}

-(void)initializeGame {
    // Set up cards
    deck = [self shuffleDeck:[self createDeck:YES]];
    deckIndex = -3; // Leave room for the count to increment
    
    // Update the progress view
    [self updateProgressView];
    
    // Call this to ensure that it hides any bet buttons that the player can't afford (e.g. Pot)
    [self updateActionButtons:ActionButtonStatePlayerBets];
    
    // Set the index to -1 so that when the round starts, it pushes us to 0
    playerIndex = -1;
    
    // Draw the cards
    [self initializeCardImages];
    
    // Other settings
    PlayerRecord* playerRecord = [PlayerRecordProvider fetchPlayerRecord];
    isCheatingEnabled = [playerRecord cheatCardUnlocked];
    
    // Each player antes up at the start of the game, starting the pot
    int ante = [bets[0] intValue];
    for (Player* p in players) {
        p.holdings -= ante;
        pot += ante;
    }
    
    [self updateHoldings];
    
    //////////////////////////////////////////////////////////////////////////////////////
    // Okay, special game situation: If the player is playing the Mayor for the first time, we deal out three 6's and unlock the Beast
    if (self.currentRoom == RoomMayorsDen && playerRecord.highestRoomUnlocked < 4) {
        NSMutableArray* riggedDeck = [[NSMutableArray alloc] initWithArray:deck];
        
        // Find 6's and move them into the first three places in the deck
        for (int i = 0; i < 3; i++) {
            for (int j = i; j < [riggedDeck count]; j++) {
                if ([riggedDeck[j] rank] == 6) {
                    // Swap the 6 into the slot marked by i
                    [riggedDeck exchangeObjectAtIndex:(NSUInteger)i withObjectAtIndex:(NSUInteger)j];
                    j = (int)[riggedDeck count];
                }
            }
        }
        
        deck = [riggedDeck copy];
        
        isRevealingTheBeast = true;
    }
    else {
        isRevealingTheBeast = false;
    }

    // Kick off the first round
    [self initializeRound];
}

-(void)initializeRound {
    // Advance the players
    [self moveToNextPlayer];
    
    // Update the holdings, which also updates the backgrounds' selected state
    [self updateHoldings];
    
    // Clear out older game status updates
    [bettingStatusLabel setText:@""];
    [gameStatusLabel setText:@""];
    
    // Advance through the deck
    deckIndex = deckIndex + 3;
    if (deckIndex + 2 > deck.count) {
        deck = [self shuffleDeck:deck];
        [bettingStatusLabel setText:@"\"It's deck shufflin' time.\""];
        deckIndex = 0;
    }
    
    [self updateProgressView];

    // Set up this set of cards
    Card* lowCard = ([deck[deckIndex] rank] < [deck[deckIndex + 2] rank] ?
                     deck[deckIndex] :
                     deck[deckIndex + 2]);
    
    Card* highCard = ([deck[deckIndex] rank] >= [deck[deckIndex + 2] rank] ?
                      deck[deckIndex] :
                      deck[deckIndex + 2]);
    
    Card* facedownCard = deck[deckIndex + 1];
    
    cardsInPlay = @[lowCard, facedownCard, highCard];
    [self updateCards];
    
    // Determine the bet type
    betTypeThisRound = BetTypeAceyDeucey;   // The default

    int distanceBetweenCards = [self getDistanceBetweenTwoCards:lowCard.rank secondRank:highCard.rank];
    if (1 == distanceBetweenCards) {
        betTypeThisRound = BetTypeTheGulch; // Faceup cards are sequential and no win is possible
    }
    else if (0 == distanceBetweenCards) {
        betTypeThisRound = BetTypeThreeOfAKind; // Player can get five times their bet - if they win
    }
    
    bool isPlayerUp = ([players[playerIndex] playerType] == PlayerTypeHuman);
    
    // If the player is up, prompt them to go
    if (isPlayerUp) {
        NSString* bettingPrompt;
        ActionButtonState buttonState;
        switch (betTypeThisRound) {
            case BetTypeTheGulch: {
                bettingPrompt = @"You’re stuck in the gulch! Bet your ante on whether yer higher or lower.";
                buttonState = ActionButtonStateHighLowBet;
                break;
            }
            case BetTypeThreeOfAKind: {
                bettingPrompt = @"If you land three of a kind, the house’ll pay five times your bet!";
                buttonState = ActionButtonStatePlayerBets;
                
                /*
                // Hook in here to present a warning or encouragement to the player on their odds of winning this
                NSString* characterPortrait = @"char_bum";
                NSString* modalText = nil;
                CGFloat oddsOfThreeOfAKind = [self calculateOddsOfThreeOfAKind];
            
                if (oddsOfThreeOfAKind > 0.5) {
                    modalText = @"Pssst ... based on what we've seen from the deck, you've got better'n even odds at a win!";
                }
                else if (oddsOfThreeOfAKind == 0.0) {
                    modalText = @"That's a risky bet ... I would stick to the ante there.";
                }
                
                if (modalText) {
                    [self showModal:characterPortrait text:modalText];
                }
                 */
                
                break;
            }
            default: {
                bettingPrompt = @"It’s your bet.";
                buttonState = ActionButtonStatePlayerBets;
                break;
            }
        }
        
        [bettingStatusLabel setText:bettingPrompt];
        [self updateActionButtons:buttonState];
   
    }
    // ... otherwise, the AI bets when the user hits the "Next" button
    else {
        // The status label will be set from the aiPlaceBet method, once the bet is calculated
        [self updateActionButtons:ActionButtonStateNextButton];
        [self aiPlaceBet:lowCard highCard:highCard];
    }
}

// End the round - and possibly the game
-(void)concludeRound {
    [self updateHoldings];
    
    NSString *gameStatusText;
    
    // Is the current player out? If so, announce it
    if ([players[playerIndex] holdings] < [self smallestPossibleBet]) {
        [players[playerIndex] setIsStillInGame:NO];
        
        // If the beast is beaten, leave
        if ([self checkIfBeastIsBeaten:players[playerIndex]]) return;
        
        if ([players[playerIndex] playerType] == PlayerTypeHuman) {
            gameStatusText = @"Sorry to say, you’re out of the game.";
        }
        else {
            gameStatusText = [NSString stringWithFormat:@"%@ is out of the game.", [players[playerIndex] name]];
        }
    }
    
    // Check for the end of the game
    bool isGameOver = false;
    
    // The pot could be empty ...
    if (pot <= 0) {
        isGameOver = true;
        gameStatusText = @"The pot’s gone. Game over!";
    }
    
    if ([super getCountOfPlayersLeft] < 2) {
        isGameOver = true;
        
        // Get the survivor's name
        Player* lastPlayerStanding = nil;
        for (Player* p in players) {
            if ([p isStillInGame]) {
                lastPlayerStanding = p;
                break;
            }
        }
        
        NSString* gameResult;
        if ([lastPlayerStanding playerType] == PlayerTypeHuman) gameResult = [NSString stringWithFormat:@"That's it! You're the last player standing!"];
        else gameResult = [NSString stringWithFormat:@"That’s it! %@ is the last player standing!", [lastPlayerStanding name]];
        
        lastPlayerStanding.holdings += pot;
        pot = 0;
    }
    
    if (isGameOver) {
        [gameStatusLabel setText:gameStatusText];
        [self updateActionButtons:ActionButtonStateGameOver];
        
        // Save the player's winnings. Even if they lost, the game might have ended when the pot ran out, which would leave the player with some money.  (This will take some thinking ... )
        Player* humanPlayer = [super getHumanPlayer];
        if (humanPlayer)    // Just making sure we found one ...
        {
            PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
            player.holdings = [humanPlayer holdings];
            player.winningsToDate += [humanPlayer holdings];
            
            [PlayerRecordProvider updatePlayerRecord:player];
        }
    }
    else {
        // The game's not over - keep playing
        [self updateActionButtons:ActionButtonStateNextButton];
    }
}

-(void)endGame {
    // How much did we win/lose?
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    int currentPlayerHoldings = [[super getHumanPlayer] holdings];
    int winnings = currentPlayerHoldings - [player holdings];
    
    [PlayerRecordProvider addWinnings:winnings];
    [player setHoldings:currentPlayerHoldings];
    [PlayerRecordProvider updatePlayerRecord:player];
    
    // Show the replay modal, which lets users try again or quit
    bool everyoneIsStillIn = true;
    for (Player* p in players) {
        if (p.playerType != PlayerTypeNPC_Beast && [p holdings] < [bets[0] intValue] * 3) {
            everyoneIsStillIn = false;
            break;
        }
    }
    
    [super showReplayModal:everyoneIsStillIn];
}

# pragma mark UI interactions

- (void)nextBet {
    [self initializeRound];
}

// The player folds. End the game (rather than make them sit through the rest of it)
-(void)fold {
    [[self getHumanPlayer] setIsStillInGame:NO];
    [bettingStatusLabel setText:@"\"Guess we’ll just play on without you ... \""];
    
    // Save the player's current money
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    int currentPlayerHoldings = [[super getHumanPlayer] holdings];
    [player setHoldings:currentPlayerHoldings];
    [PlayerRecordProvider updatePlayerRecord:player];
    
    [self updateActionButtons:ActionButtonStateWatchOrSkipToEnd];
}

// FIXME: Eventually this can run through the game and figure out who won and how much money everyone has left, but not now
-(void)skipToEnd {
    [self.delegate gameHasEnded];
    [self removeFromParentViewController];
}

- (void)placeBet:(id)sender
{
    // Check the status of the game
    NSString* result;
    
    switch(betTypeThisRound) {
            // The two faceupcards were next to each other; the player bets the ante on whether the facedown card is higher or lower than the two of them. (If it matches either of them, the player loses)
        case BetTypeTheGulch: {
            UIButton* betButton = (UIButton*)sender;
            int bet = [self smallestPossibleBet];
            
            GulchComparison comparison = [self compareToGulchCards:deck[deckIndex + 1]
                                             firstCard:deck[deckIndex]
                                            secondCard:deck[deckIndex + 2]];
            if ((comparison == GulchComparisonLowerThanGulch && betButton.tag == ActionButtonTypeGulchLow) || (comparison == GulchComparisonHigherThanGulch && betButton.tag == ActionButtonTypeGulchHigh)) {
                pot -= bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] + bet)];
                result = @"You win!";
            }
            else {
                pot += bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] - bet)];
                 result = @"Shucks. You lost.";
            }
            
            break;
        }
        case BetTypeThreeOfAKind: {
            UIButton* betButton = (UIButton*)sender;
            int bet = betButton.tag < [bets count] ? [bets[betButton.tag] intValue] : pot;
            
            // If we're revealing the Beast, do that here
            if (isRevealingTheBeast) {
                // We'll still pay the player ...
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] + (bet * kMultiplierForThreeOfAKindWin))];
                [self updateHoldings];
                
                // Keep the user from fidgeting past our awesome animation
                [nextButton setEnabled:NO];
                
                // Hide the betting status label so that the next turn text won't start running
                [bettingStatusLabel setHidden:YES];
                
                [self revealTheBeast];
            }
            else {
                // Otherwise, nothing to see here ... carry on
                bool win = ([deck[deckIndex + 1] rank] == [deck[deckIndex] rank]) &&
                ([deck[deckIndex + 1] rank] == [deck[deckIndex + 2] rank ]);
                
                if (win) {
                    pot -= bet;
                    [players[playerIndex] setHoldings:([players[playerIndex] holdings] + (bet * kMultiplierForThreeOfAKindWin))];
                    result = [NSString stringWithFormat:@"Three of a kind! House pays you %d times your bet!", kMultiplierForThreeOfAKindWin];
                }
                else {
                    pot += bet;
                    [players[playerIndex] setHoldings:([players[playerIndex] holdings] - bet)];
                    result = @"Shucks. You lost.";
                }
            }
            break;
        }
        case BetTypeAceyDeucey:
        default: {
            UIButton* betButton = (UIButton*)sender;
            int bet = betButton.tag < [bets count] ? [bets[betButton.tag] intValue] : pot;
            
            bool win = [self isAceyDeucey:deck[deckIndex + 1]
                                firstCard:deck[deckIndex]
                               secondCard:deck[deckIndex + 2]];
            
            if (win) {
                pot -= bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] + bet)];
                result = @"You win!";
            }
            else {
                pot += bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] - bet)];
                result = @"Shucks. You lost.";
            }
            break;
        }
    }
  
    // ... and reveal the results
    [NSTimer scheduledTimerWithTimeInterval:([players[playerIndex] playerType] == PlayerTypeHuman ? 0.0 : 1.0) target:self selector:@selector(revealDrawCard) userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:([players[playerIndex] playerType] == PlayerTypeHuman ? 1.0 : 2.0) target:self selector:@selector(completeResultsDisplay:) userInfo:result repeats:NO];
    
    // Show the "Next" button so we can advance to next round
    [self updateActionButtons:ActionButtonStateNextButton];
    
    [self concludeRound];
}

- (void)aiPlaceBet:(Card*)lowCard highCard:(Card*)highCard {
    // Disable the Next button until the AI has gone
    
    // TODO: It would be better to let the player use this button to skip ahead, but right now that causes a bug
    [nextButton setUserInteractionEnabled:NO];
    
    NSString* result;
  
    switch(betTypeThisRound) {
        case BetTypeTheGulch: {
            [gameStatusLabel setText:[BarkProvider getBarkForTrigger:AceyDeuceyGulch andPlayer:players[playerIndex]]];
            
            bool betHigh = false;
            if (self.currentRoom < 2) {
                // At this point, the AI will simply bet low on the Gulch if the Gulch cards are 6/7 or lower, and high if they're higher. Later on we can add more card counting so they can make a smarter bet
                if ([lowCard rank] < 7) betHigh = true;
            }
            else {
                // Otherwise we try to count cards - which could hopefully lead to some surprising results?
                double chanceOfLowCard = [self countChanceOfCardBetweenLowCardRank:1 highCardRank:[deck[deckIndex] rank]];
                double chanceOfHighCard = [self countChanceOfCardBetweenLowCardRank:[deck[deckIndex + 2] rank]  highCardRank:13];
                
                betHigh = (chanceOfHighCard > chanceOfLowCard);
            }
            
            [bettingStatusLabel setText:[NSString stringWithFormat:@"Shucks, the Gulch! %@ bets the ante that the card is %@.", [players[playerIndex] name], betHigh ? @"higher" : @"lower"]];
            
            int bet = [self smallestPossibleBet];
            
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(revealDrawCard) userInfo:nil repeats:NO];
            
            GulchComparison comparison = [self compareToGulchCards:deck[deckIndex + 1]
                                                         firstCard:deck[deckIndex]
                                                        secondCard:deck[deckIndex + 2]];
            if ((comparison == GulchComparisonLowerThanGulch && !betHigh) || (comparison == GulchComparisonHigherThanGulch && betHigh)) {
                pot -= bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] + bet)];
                result = [NSString stringWithFormat:@"%@ called it.", [players[playerIndex] name]];
            }
            else {
                pot += bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] - bet)];
                result = [NSString stringWithFormat:@"%@ loses.", [players[playerIndex] name]];
            }
            
            break;
        }
        case BetTypeThreeOfAKind: {
            [gameStatusLabel setText:[BarkProvider getBarkForTrigger:AceyDeuceyPossibleTrips andPlayer:players[playerIndex]]];
            // TODO: Right now they'll just bet the minimum but get the full reward if they win. Later they should learn to count cards
            int bet = [self smallestPossibleBet];
            
            [bettingStatusLabel setText:[NSString stringWithFormat:@"Could that be a three of a kind? %@ is up, and bets $%d.", [players[playerIndex] name], bet]];
            
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(revealDrawCard) userInfo:nil repeats:NO];

            bool win = ([deck[deckIndex + 1] rank] == [deck[deckIndex] rank]) &&
            ([deck[deckIndex + 1] rank] == [deck[deckIndex + 2] rank ]);
            
            if (win) {
                pot -= bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] + bet * kMultiplierForThreeOfAKindWin)];
                result = [NSString stringWithFormat:@"%@ called it and wins big!", [players[playerIndex] name]];
            }
            else {
                pot += bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] - bet)];
                result = [NSString stringWithFormat:@"%@ lost.", [players[playerIndex] name]];
            }
            break;
        }
        case BetTypeAceyDeucey:
        default: {
            int bet = 0;
            int holdings = [players[playerIndex] holdings];
            
            // In the early rooms, players just react to the gap between the cards
            if (self.currentRoom < 2) {
                int distanceBetweenCards = [self getDistanceBetweenTwoCards:[lowCard rank] secondRank:[highCard rank]];
                
                // First determine what they would like to bet ...
                if (distanceBetweenCards > 10) {
                    bet = pot;
                    [gameStatusLabel setText:[BarkProvider getBarkForTrigger:AceyDeuceyWideSpread andPlayer:players[playerIndex]]];
                }
                else if (distanceBetweenCards > 7) bet = [bets[2] intValue];
                else if (distanceBetweenCards > 5) bet = [bets[1] intValue];
                else bet = [bets[0] intValue];
            }
            // ... in later rooms, the AIs count cards
            else {
                float probability = [self countChanceOfCardBetweenLowCardRank:[lowCard rank] highCardRank:[highCard rank]];
                if (probability > 0.4f) bet = [bets[2] intValue];
                else if (probability > 0.2f) bet = [bets[1] intValue];
                else bet = [bets[0] intValue];
            }
            
            // Either way, we have the bet - determine what they can afford
            if (bet > [players[playerIndex] holdings])
            {
                if ([bets[2] intValue] <= holdings) bet = [bets[2] intValue];
                else if ([bets[1] intValue] <= holdings) bet = [bets[1] intValue];
                else if ([bets[0] intValue] <= holdings) bet = [bets[0] intValue];
                else bet = 0; // TODO: If bet = 0 they should've been kicked out of the game; throw an error
            }
            
            // Finally, if the bet is bigger than the pot, make it the pot
            if (bet > pot) bet = pot;
            
            [bettingStatusLabel setText:[NSString stringWithFormat:@"%@ is up, and bets $%d.", [players[playerIndex] name], bet]];
            
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(revealDrawCard) userInfo:nil repeats:NO];
            
            // TODO: Refactor all this "win" stuff into a separate method, it duplicates placeBet
            bool win = [self isAceyDeucey:deck[deckIndex + 1]
                                firstCard:deck[deckIndex]
                               secondCard:deck[deckIndex + 2]];
            
            if (win) {
                pot -= bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] + bet)];
                result = [NSString stringWithFormat:@"%@ called it.", [players[playerIndex] name]];
            }
            else {
                pot += bet;
                [players[playerIndex] setHoldings:([players[playerIndex] holdings] - bet)];
                result = [NSString stringWithFormat:@"%@ lost.", [players[playerIndex] name]];
            }
            break;
        }
    }
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(completeResultsDisplay:) userInfo:result repeats:NO];
}

-(void)moveToNextPlayer {
    int startingPlayer = playerIndex;
    
    playerIndex++;
    while (startingPlayer != playerIndex) {
        if (playerIndex == [players count]) playerIndex = 0;
        if ([players[playerIndex] isStillInGame]) return;
        else playerIndex++;
    }
    
    // TODO If we made it here, we screwed up - there are no valid players. Throw an error
    [gameStatusLabel setText:@"ERROR: There are no valid players"];
}

#pragma mark Calculate information about the deck or player status

// Try to remove "bullshit" deals, where the two cards are either identical or right next to each other, making a win impossible
-(void)removeBullshitDeals: (NSMutableArray*) sortedDeck {
    int bsDealCount = 0;
    for(int i = 0; i < 48; i += 3) {
        if ([self getDistanceBetweenTwoCards:[sortedDeck[i] rank] secondRank:[sortedDeck[i + 1] rank]] < 2)
        {
            Card *card = sortedDeck[i + 1];
            sortedDeck[i + 1] = sortedDeck[i + 3];
            sortedDeck[i + 3] = card;
            
            bsDealCount++;
        }
    }
}

// Check if the card is a winner
- (bool)isAceyDeucey: (Card*)facedownCard firstCard:(Card*)card1 secondCard:(Card*)card2 {
    int lowRank = ([card1 rank] > [card2 rank] ? [card2 rank] : [card1 rank]);
    int highRank = ([card1 rank] <= [card2 rank] ? [card2 rank] : [card1 rank]);
    int drawCardRank = [facedownCard rank];
    
    if (lowRank < drawCardRank && highRank > drawCardRank) return true;
    return false;
}

- (CGFloat)calculateOddsOfThreeOfAKind {
    int remainingCards = (int)[deck count] - (deckIndex + 2);
    int cardRankToMatch = [deck[deckIndex] rank];
    int winningCardsAvailable = 0;
    
    // Count the facedown card, if it's a match
    if ([deck[deckIndex + 1] rank] == cardRankToMatch) winningCardsAvailable++;
    for (int i = deckIndex + 3; i < (int)deck.count; i++)
    {
        if ([deck[deckIndex] rank] == cardRankToMatch) winningCardsAvailable++;
    }
    
    double percentage = (double)winningCardsAvailable/(double)remainingCards;
    
    NSLog(@"%@", [NSString stringWithFormat:@"Remaining cards %d, winning cards %d, percentage %f", remainingCards, winningCardsAvailable, percentage]);
    
    return percentage;
}

// Get the actual probability of a win given the cards that have been revealed
-(double)countChanceOfCardBetweenLowCardRank:(int)lowCardRank highCardRank:(int)highCardRank {
    int remainingCards = (int)[deck count] - deckIndex + 2; // (int)_arrayDeck.count - (_deckIndex + 2);
    int possibleWinningCards = 0;
    for (int i = deckIndex + 2; i < (int)[deck count]; i++)
    {
        Card* card = deck[i];
        if (card.rank > lowCardRank && card.rank < highCardRank)
            possibleWinningCards++;
    }
    
    double percentage = (double)possibleWinningCards/(double)remainingCards;
    
    NSLog(@"Counting cards: with %d remaining, odds of a win between %d and %d are %f", remainingCards, lowCardRank, highCardRank, percentage);
    
    return percentage;
}

// Check how the facedown card compares to the faceup cards - is it lower than both, higher than both, or equal to one of them. Assumes the two faceup cards are consecutive and there is no room between them
- (GulchComparison)compareToGulchCards:(Card*)facedownCard firstCard:(Card*)card1 secondCard:(Card*)card2 {
    int lowRank = ([card1 rank] > [card2 rank] ? [card2 rank] : [card1 rank]);
    int highRank = ([card1 rank] <= [card2 rank] ? [card2 rank] : [card1 rank]);
    int drawCardRank = [facedownCard rank];
    
    if (drawCardRank < lowRank && drawCardRank < highRank) return GulchComparisonLowerThanGulch;
    if (drawCardRank > lowRank && drawCardRank > highRank) return GulchComparisonHigherThanGulch;
    else return GulchComparisonStuckInGulch;
}

-(void)revealDrawCard {
    UIImageView* drawCard = cardImageViews[1];
    drawCard.image = [deck[deckIndex + 1] getImage];

    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [drawCard.layer addAnimation:transition forKey:nil];
}

#pragma mark UI Updates

// Finish the display of the results, and also end the round
-(void)completeResultsDisplay:(NSTimer*)timer {
    // Text results
    NSString* result = (NSString*)[timer userInfo];
    [bettingStatusLabel setText:result];
    
    [nextButton setUserInteractionEnabled:YES]; // TODO This is in place because for now, we're disabling Next while the AI is taking its turn
    [self updateActionButtons:ActionButtonStateNextButton];
    
    [self concludeRound];
}

-(void)updateActionButtons:(ActionButtonState)state {
    // Hide all the buttons ...
    for (int i = 0; i < [betButtons count] ; i++) {
        [betButtons[i] setHidden:YES];
    }
    
    [gulchLowBetButton setHidden:YES];
    [gulchHighBetButton setHidden:YES];
    [nextButton setHidden:YES];
    [quitButton setHidden:YES];
    [watchTheGameButton setHidden:YES];
    [skipToTheEndButton setHidden:YES];
    [slidingMenuView setHidden:YES];
    [slidingMenuHitTargetAreaView setHidden:YES];
    
    // ... and then reveal the ones we need
    switch(state) {
        case ActionButtonStatePlayerBets: {
            for (int i = 0; i < [betButtons count] - 2; i++) {
                // Only show buttons with bets the player and the pot can afford
                if ([bets[i] intValue] <= [players[playerIndex] holdings] && [bets[i] intValue] <= pot) {
                    [betButtons[i] setHidden:NO];
                }
            }
            // Can the player afford the pot?
            if ([players[playerIndex] holdings] >= pot) {
                [betButtons[indexPotButton] setHidden:NO];
            }

            // The fold button is always available
            [betButtons[indexFoldButton] setHidden:NO];
            
            // And we lump the sliding menu view in with these as well
            [slidingMenuView setHidden:NO];
            [slidingMenuHitTargetAreaView setHidden:NO];
            
            break;
        }
        case ActionButtonStateHighLowBet: {
            [gulchLowBetButton setHidden:NO];
            [gulchHighBetButton setHidden:NO];
            
            break;
        }
        case ActionButtonStateGameOver: {
            [quitButton setHidden:NO];
            break;
        }
        case ActionButtonStateWatchOrSkipToEnd: {
            [watchTheGameButton setHidden:NO];
            [skipToTheEndButton setHidden:NO];
            break;
        }
        default:
        case ActionButtonStateNextButton: {
            if ([[super getHumanPlayer] isStillInGame]) {
                [nextButton setHidden:NO];
            }
            // We're going to do an override here - if the player is done, always give them the option to bail
            else {
                [watchTheGameButton setHidden:NO];
                [skipToTheEndButton setHidden:NO];
            }
            break;
        }
    }
}

// The special case where the player draws three 6's and discovers ... the Beast 
-(void)revealTheBeast {
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    
    UIImageView* beastPokerTableImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [beastPokerTableImageView setImage:[Room getPokerTableBackgroundImageForRoom:RoomDevilsLair]];
    [beastPokerTableImageView setAlpha:0.0f];
    beastPokerTableImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    beastPokerTableImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:beastPokerTableImageView belowSubview:cardDisplayView];
    
    // Change the background
    [UIView animateWithDuration:3.0
                          delay:1.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Bring in the flaming table background
                         [beastPokerTableImageView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){
                         CGFloat heightOfModal = (CGRectGetMaxY(betButtonDisplayView.frame) - bettingStatusLabel.frame.origin.y) * 0.66f;
                         CGFloat widthOfModal = bettingStatusLabel.frame.size.width;
                         
                         HGPModal* exitToMenuModal = [[HGPModal alloc] initWithFrame:CGRectMake(bettingStatusLabel.frame.origin.x, bettingStatusLabel.frame.origin.y + (heightOfModal / 6), widthOfModal, heightOfModal)];

                         UIButton* exitButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_WIDE, MARGIN_THIN, widthOfModal - (MARGIN_WIDE * 2), heightOfModal - (MARGIN_THIN * 2.0f))];
                         [exitButton setTitle:@"The whole room wobbles and fades ..." forState:UIControlStateNormal];
                         [exitButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"talk_card_btn_background" ofType:@"png"]] forState:UIControlStateNormal];
                         
                         exitButton.titleLabel.font = [UIFont fontForBody];
                         [exitButton.titleLabel setNumberOfLines:0];
                         [exitButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
                         [exitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                         [exitButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                         [exitButton addTarget:self action:@selector(exitToMenuAndRevealBeast) forControlEvents:UIControlEventTouchUpInside];
                         
                         [exitToMenuModal addSubview:exitButton];
                         
                         [self.view addSubview:exitToMenuModal];
                         
                         
                         id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                         [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"
                                                                               action:@"Reveal the Beast"
                                                                                label:@"Unlock"
                                                                                value:@1] build]];
                     }];
}

// Called from the modal opened in the revealTheBeast method
-(void)exitToMenuAndRevealBeast {
    // Save the player's winnings
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    int currentPlayerHoldings = [[super getHumanPlayer] holdings];
    [player setHoldings:currentPlayerHoldings];
    [PlayerRecordProvider updatePlayerRecord:player];
    
    [self.delegate unlockTheBeast];
}

@end
