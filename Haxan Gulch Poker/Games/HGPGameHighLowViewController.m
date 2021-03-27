//
//  HGPGameHighLowViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 9/22/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPGameHighLowViewController.h"

@interface HGPGameHighLowViewController ()

@end

@implementation HGPGameHighLowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add High-Low-specific buttons
    CGFloat tripletButtonWidth = (betButtonDisplayView.frame.size.width - (MARGIN_THIN * 2)) / 5; // Divide by 5 so we can use these as separators on the left and right. The buttons are too short otherwise and look ridiculous if they're spread out
    
    // At the end of the game, choose High ...
    highButton = [[UIButton alloc] initWithFrame:CGRectMake(tripletButtonWidth, 0.0f, tripletButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:highButton];
    [highButton setTitle:@"High" forState:UIControlStateNormal];
    [highButton addTarget:self action:@selector(chooseHighLowOrBoth:) forControlEvents:UIControlEventTouchUpInside];
    [highButton setTag:ActionButtonTypeHighHand];
    [betButtonDisplayView addSubview:highButton];
    
    lowButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(highButton.frame) + MARGIN_THIN, 0.0f, tripletButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:lowButton];
    [lowButton setTitle:@"Low" forState:UIControlStateNormal];
    [lowButton addTarget:self action:@selector(chooseHighLowOrBoth:) forControlEvents:UIControlEventTouchUpInside];
    [lowButton setTag:ActionButtonTypeLowHand];
    [betButtonDisplayView addSubview:lowButton];

    highAndLowButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lowButton.frame) + MARGIN_THIN, 0.0f, tripletButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:highAndLowButton];
    [highAndLowButton setTitle:@"High & Low" forState:UIControlStateNormal];
    [highAndLowButton addTarget:self action:@selector(chooseHighLowOrBoth:) forControlEvents:UIControlEventTouchUpInside];
    [highAndLowButton setTag:ActionButtonTypeHighAndLowHand];
    [betButtonDisplayView addSubview:highAndLowButton];
    
    // Initialize the first set of action buttons and so, hide all the other ones
    [self updateActionButtons:ActionButtonStatePlayerBets];
    
    // With the view established, initialize the game
    [self initializeGame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Game - High-Low"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark Game logic methods

-(void)initializeGame {
    // Pick a wild card at random
    wildCardRank = arc4random_uniform(13) + 1;
    
    [super initializeGame];
}

-(void)advanceRound {
    // Queue up the next player
    [self moveToNextPlayerAndCheckForNextRound];
    
    // Check to see if the game is over
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
    else if (currentRound > 7) {
        if ([[self getHumanPlayer] isStillInGame]) {
            bool canPlayerFormALowHand = !(-1 == [[self evaluateFinalPlayerLowHand:[players[0] hand]] intValue]);
            if (canPlayerFormALowHand) {
                [bettingStatusLabel setText:[NSString stringWithFormat:@"%@%@s are wild. The moment of truth: Have you got the High hand, the Low hand ... or can you win ‘em both?", [Card getDisplayNameForRank:wildCardRank], wildCardRank < 11 ? @"’" : @""]];
            }
            else {
                [bettingStatusLabel setText:[NSString stringWithFormat:@"%@%@s are wild. Looks like you can only form a High hand. Let’s see who takes you on!", [Card getDisplayNameForRank:wildCardRank], wildCardRank < 11 ? @"’" : @""]];
            }
            [self updateActionButtons:ActionButtonStateHighLowBoth];
        }
        else {
            [self determineResultsOfGame:HighLowBetNone];
        }
    }
    else {
        // Clear out older game status updates
        [bettingStatusLabel setText:@""];
        
        bool isPlayerUp = ([players[playerIndex] playerType] == PlayerTypeHuman);
        
        // If the player is up, prompt them to go
        if (isPlayerUp) {
            Player* humanPlayer = [super getHumanPlayer];
            Card* dealtCard = deck[deckIndex++];    // Deal the card and then advance the index
            [dealtCard setIsFaceup:[self isCardDealtFaceUpThisRound]];
            [humanPlayer addCardToHand:dealtCard];
            [super updatePlayerCards:0];
            
            [bettingStatusLabel setText:[NSString stringWithFormat:@"%@%@s are wild.\nIt’s your bet.", [Card getDisplayNameForRank:wildCardRank], wildCardRank < 11 ? @"’" : @""]];

            [self updateActionButtons:ActionButtonStatePlayerBets];
        }
        // Otherwise, work through the AI actions
        else {
            // Clear the buttons, so that we have to watch the turn
            [self updateActionButtons:ActionButtonStateNone];
            
            [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(dealToAI) userInfo:nil repeats:NO];
        }
    }
}

-(void)dealToAI {
    Player* currentAi = players[playerIndex];
    Card* dealtCard = deck[deckIndex++];    // Deal the card and then advance the index
    [dealtCard setIsFaceup:[self isCardDealtFaceUpThisRound]];
    
    [currentAi addCardToHand:dealtCard];
    [self updatePlayerCards:playerIndex];
    
    // Call calculateAiBet, which does all the work of figuring out how the AI will bet given what's on the table and in their hand
    int bet = [self calculateAiBet:players[playerIndex]];
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

#pragma mark Action buttons and handlers

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
    
    // Weigh the low hand as well
    HandEvaluation* lowHandEvaluation = [self evaluatePlayerLowHand:[aiPlayer hand]];

    // The hand that the player wants to get
    HandEvaluation* targetedHand = likeliestHand;
    
    int aiBet = [bets[0] intValue];
    
    // The maximum bet drops as the games goes on
    int maximumBetForThisHand = currentRound < 6 ? [bets[1] intValue] : [bets[0] intValue];
    
    for (HandEvaluation* evaluation in evaluations) {
        // For the three best types of hands, it'll accept a 0.1 risk
        if (([evaluation type] < 4 && [evaluation probability] > 0.1f) ||
            [lowHandEvaluation probability] > 0.2f) {
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

// Review all of the AIs who have already gone this turn and see if they will match the current player's raise
-(void)aiMatchesBet {
    // Display this with a timer ...
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    // Work through the AIs
    for (int i = 1; i < playerIndex; i++) {
        if ([players[i] isStillInGame]) {
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
        // TODO: This is a shameless kludge. Basically if the player is still around they can try to match the bet, and you don't need to repeat the bettingStatusLabel text - we already had time to read it. If the player is NOT around and we're racing straight into this, then we DO want to concatenate the text
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
            // The player has folded and nobody else needs to match the bet. We have to say something:
            if (!results || [results count] == 0) {
                [bettingStatusLabel setText:@"The table goes quiet."];
            } else {
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

// Return an evaluation with probability of the player's chance of a low hand
-(HandEvaluation*)evaluatePlayerLowHand:(NSArray<Card*>*)hand {
    NSArray<Card*>* remainingDeck = [self getUnknownCards];
    
    // Pull out (and count) the wild cards
    NSArray<Card*>* handWithoutWildCards = [BetEvaluator getHandWithoutWildCards:hand wildCardRanks:@[[NSNumber numberWithInt:wildCardRank]]];
    int countOfWildCards = (int)([hand count] - [handWithoutWildCards count]);

    HandEvaluation* lowHandEvaluation = [HandEvaluator evaluateLowPokerHand:handWithoutWildCards wildCards:countOfWildCards unknownCards:remainingDeck handSize:SEVEN_CARD_STUD_HAND_SIZE];

    return lowHandEvaluation;
}

// Return the final evaluation of the player's low hand as a number (e.g. 54321 or 87432), taking into account wild cards
-(NSNumber*)evaluateFinalPlayerLowHand:(NSArray<Card*>*)hand {
    // Pull out (and count) the wild cards
    NSArray<Card*>* handWithoutWildCards = [BetEvaluator getHandWithoutWildCards:hand wildCardRanks:@[[NSNumber numberWithInt:wildCardRank]]];
    int countOfWildCards = (int)([hand count] - [handWithoutWildCards count]);
    
    int lowHandValue = [HandEvaluator getFinalLowHandValue:handWithoutWildCards wildCards:countOfWildCards];
    
    return [NSNumber numberWithInt:lowHandValue];
}

// Return the final evaluation of a player's high hand, taking into account wild cards
-(HandEvaluation*)evaluateFinalPlayerHighHand:(NSArray<Card*>*)hand {
    NSArray<Card*>* handWithoutWildCards = [BetEvaluator getHandWithoutWildCards:hand wildCardRanks:@[[NSNumber numberWithInt:wildCardRank]]];
    int countOfWildCards = (int)([hand count] - [handWithoutWildCards count]);
    HandEvaluation* playerHandEvaluation = [HandEvaluator getFinalRankingOfHand:handWithoutWildCards wildCards:countOfWildCards];
    
    return playerHandEvaluation;
}


// Handles the user's button press as they select their bet type
-(void)chooseHighLowOrBoth:(id)sender {
    int buttonTag = (int)((UIButton*)sender).tag;
    HighLowBetType playerBetType;

    switch(buttonTag){
        case ActionButtonTypeHighHand: {
            playerBetType = HighLowBetHigh;
            break;
        }
        case ActionButtonTypeLowHand: {
            playerBetType = HighLowBetLow;
            break;
        }
        case ActionButtonTypeHighAndLowHand:
            playerBetType = HighLowBetBoth;
            break;
        default:
            playerBetType = HighLowBetNone;
            break;
    }
    
    [self determineResultsOfGame:playerBetType];
}

// Takes each player's bet types and determines the outcome
-(void)determineResultsOfGame:(HighLowBetType)playerBetType {
    NSDictionary* resultsDict = [BetEvaluator evaluateHighLowAndBothWinners:players playerBetType:playerBetType wildCardRanks:@[[NSNumber numberWithInt:wildCardRank]]];

    int indexOfPlayerWithBestHighHand = [[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningHighHand] intValue];
    int indexOfPlayerWithBestLowHand = [[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningLowHand] intValue];
    int indexOfPlayerWithBestHighAndLowHand = [[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningHighAndLowHand] intValue];
  
    [bettingStatusLabel setText:@""];
    
    // Reveal the NPCs hands
    for (int i = 1; i < [players count]; i++) {
        for (Card* c in [players[i] hand]) {
            [c setIsFaceup:YES];
        }
        
        [self updatePlayerCards:i];
    }
    
    ////////////////////////////////////////////////////////////
    // Display and store the results
    
    NSLog(@"Best high hand:%d \nBest low hand:%d\nBest both hands:%d", indexOfPlayerWithBestHighHand, indexOfPlayerWithBestLowHand, indexOfPlayerWithBestHighAndLowHand);
    
    NSString* results;
    
    // First, catch if we have a winner for both high and low hand
    if (indexOfPlayerWithBestHighAndLowHand > -1) {
        // Stash the result in highHandResults, and that'll be the only populated string in the results modal
        results = [NSString stringWithFormat:@"%@ bets on the high AND low hand - and wins!", [players[indexOfPlayerWithBestHighAndLowHand] name]];
        
        // TODO: Add the players who just bet low or high, and also, the other players who bet high/low but lost
        
        players[indexOfPlayerWithBestHighAndLowHand].holdings += pot;
    }
    else {
        NSString* highHandResults = indexOfPlayerWithBestHighHand == -1 ?
        @"Nobody bet on a high hand!" : [NSString stringWithFormat:@"%@ win%@ the high hand with %@!", [players[indexOfPlayerWithBestHighHand] name], 0 == indexOfPlayerWithBestHighHand ? @"" : @"s", [resultsDict valueForKey:kHGPWinningHighHandDescription]];
        
        NSString* lowHandResults = indexOfPlayerWithBestLowHand == -1 ?
        @"Nobody bet on a low hand!" : [NSString stringWithFormat:@"%@ win%@ the low hand!", [players[indexOfPlayerWithBestLowHand] name], 0 == indexOfPlayerWithBestLowHand ? @"" : @"s"];
        // TODO: Add a description of the winning low hand - 6-5, 8-4, The Wheel
        
        // Get the names of people who bet high and low, even though they lost - it's just cool that they tried
        NSString* highAndLowHandResults = @"";
        if ([[resultsDict valueForKey:kHGPPlayersBettingHighAndLow] length] > 0) {
            highAndLowHandResults = [NSString stringWithFormat:@"%@ tried for the high and low hands, and lost.", [resultsDict valueForKey:kHGPPlayersBettingHighAndLow]];
        }
    
        results = [NSString stringWithFormat:@"%@\n%@\n%@", highHandResults, lowHandResults, highAndLowHandResults];
    
        int highHandWinnings = 0;
        int lowHandWinnings = 0;
        if (indexOfPlayerWithBestHighHand == -1)  {
            lowHandWinnings = pot;
            players[indexOfPlayerWithBestLowHand].holdings += lowHandWinnings;
        }
        else if (indexOfPlayerWithBestLowHand == -1) {
            highHandWinnings = pot;
            players[indexOfPlayerWithBestHighHand].holdings += highHandWinnings;
        }
        else {
            highHandWinnings = pot / 2 + pot % 2;   // The high hand gets the remainder
            lowHandWinnings = pot / 2;
            
            players[indexOfPlayerWithBestHighHand].holdings += highHandWinnings;
            players[indexOfPlayerWithBestLowHand].holdings += lowHandWinnings;
        }
    }

    // Oh yeah, that cleaned out the pot
    pot = 0;
    
    // Save the human player's holdings
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    [player setHoldings:[[super getHumanPlayer] holdings]];
    [PlayerRecordProvider updatePlayerRecord:player];
    
    [self updateHoldings];
    
    resultsModal = [super showModal:results];
    [resultsModal.closeButton addTarget:self action:@selector(displayReplayModal) forControlEvents:UIControlEventTouchUpInside];
    
    // Trigger the "Step Away From the Table" button
    [self updateActionButtons:ActionButtonStateGameOver];
}

-(void)updateActionButtons:(ActionButtonState)state {
    for (UIButton* b in betButtons) {
        [b setHidden:YES];
    }
    [matchBetButton setHidden:YES];
    [foldButton setHidden:YES];
    [nextButton setHidden:YES];
    [quitButton setHidden:YES];
    [highButton setHidden:YES];
    [lowButton setHidden:YES];
    [highAndLowButton setHidden:YES];
    
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
            
            // Update the holdings, which also makes sure that the YOU background goes to its selected state
            [self updateHoldings];
            
            // The last button, FOLD, is always available ... if yer a quitter
            [[betButtons lastObject] setHidden:NO];
            
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
        case ActionButtonStateHighLowBoth: {
            [highButton setHidden:NO];
            [lowButton setHidden:NO];
            [highAndLowButton setHidden:NO];
            
            // If the player can't form a low hand, disable those buttons; otherwise, make sure they're reenabled
            bool canFormLowHand = -1 != [[self evaluateFinalPlayerLowHand:[players[0] hand]] intValue];
            [lowButton setEnabled:canFormLowHand];
            [highAndLowButton setEnabled:canFormLowHand];
            
            break;
        }
        case ActionButtonStateNone:
        default:
            break;
    }
}

// Remove wild cards from a player's hand, for evaluation purposes
-(NSArray<Card*>*)getHandWithoutWildCards:(NSArray<Card*>*)hand {
    NSMutableArray<Card*>* handWithoutWildCards = [[NSMutableArray alloc] init];
    for (Card* c in hand) {
        if (wildCardRank != [c rank]) {
            [handWithoutWildCards addObject:c];
        }
    }
    
    return handWithoutWildCards;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
