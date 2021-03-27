//
//  HGPGameDayBaseBallViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/12/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPGameDayBaseBallViewController.h"

@interface HGPGameDayBaseBallViewController ()

@end

@implementation HGPGameDayBaseBallViewController

#pragma mark Presentation logic

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add Day Baseball-specific buttons
    CGFloat twinButtonWidth = (betButtonDisplayView.frame.size.width - MARGIN_STANDARD) / 2;
    
    // Buy a card on a 4
    buyaCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, twinButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:buyaCardButton];
    [buyaCardButton setTitle:@"Buy Another Card" forState:UIControlStateNormal];
    [buyaCardButton addTarget:self action:@selector(buyaCard) forControlEvents:UIControlEventTouchUpInside];
    [buyaCardButton setTag:ActionButtonTypeMatchBet];
    [betButtonDisplayView addSubview:buyaCardButton];
    
    passOnBuyingACardButton = [[UIButton alloc] initWithFrame:CGRectMake(twinButtonWidth + MARGIN_STANDARD, 0.0f, twinButtonWidth, CGRectGetHeight(betButtonDisplayView.frame))];
    [super styleButton:passOnBuyingACardButton];
    [passOnBuyingACardButton setTitle:@"No Thanks" forState:UIControlStateNormal];
    [passOnBuyingACardButton addTarget:self action:@selector(doNotBuyaCard) forControlEvents:UIControlEventTouchUpInside];
    [passOnBuyingACardButton setTag:ActionButtonTypeFold];
    [betButtonDisplayView addSubview:passOnBuyingACardButton];

    // Initialize the first set of action buttons and so, hide all the other ones
     [self updateActionButtons:ActionButtonStatePlayerBets];
    
    // With the view established, initialize the game
    [self initializeGame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Game - Day Baseball"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark Game logic methods

-(void)advanceRound {
    // Queue up the next player
    [self moveToNextPlayerAndCheckForNextRound];
    
    // Check to see if the game is over
    if (currentRound > 7 || ([super getCountOfPlayersLeft] == 1)) {
        [self endGame];
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
            
            // If the card is a 4 and it's faceup, and the player can afford it, invite them to buy a card
            if (dealtCard.rank == 4  && dealtCard.isFaceup && [humanPlayer holdings] > [self costOfBuyingACard]) {
                [bettingStatusLabel setText:[NSString stringWithFormat:@"You drew a 4! Care to buy another card for $%d?", [self costOfBuyingACard]]];
                [self updateActionButtons:ActionButtonStateBuyACard];
            }
            else {
                if (currentRound == 3) {
                    // TODO: Have a better way of introducing instructions/barks at the start of the game
                    [bettingStatusLabel setText:@"Day baseball, batter up. 3’s and 9’s are wild.\nIt’s your bet."];
                } else {
                    [bettingStatusLabel setText:@"3’s and 9’s are wild.\nIt’s your bet."];
                }
                [self updateActionButtons:ActionButtonStatePlayerBets];
            }
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
    
    // If the AI can buy another card, it will
    // TODO: ... unless their hand is a total stinker?
    // TODO: If they don't/can't buy the card, should we point that out?
    if (dealtCard.rank == 4 && [dealtCard isFaceup] && [currentAi holdings] > ([self costOfBuyingACard] + [self smallestPossibleBet])) {
        [self playerPlacesBet:playerIndex bet:[self costOfBuyingACard]];
        [bettingStatusLabel setText:[NSString stringWithFormat:@"%@ draws a 4, and buys another card!", [currentAi name]]];
        
        // Deal the next card
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dealToAI) userInfo:nil repeats:NO];
    }
    else {
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
}

#pragma mark Action buttons and handlers

-(void)updateActionButtons:(ActionButtonState)state {
    for (UIButton* b in betButtons) {
        [b setHidden:YES];
    }
    [matchBetButton setHidden:YES];
    [foldButton setHidden:YES];
    [nextButton setHidden:YES];
    [buyaCardButton setHidden:YES];
    [passOnBuyingACardButton setHidden:YES];
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

            // Update the holdings, which also makes sure that the YOU background goes to its selected state
            [self updateHoldings];
            
            // Finally, reveal the menu, which always goes with the bet buttons
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
        case ActionButtonStateBuyACard: {
            [buyaCardButton setHidden:NO];
            [passOnBuyingACardButton setHidden:NO];
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

// The player drew a 4 and has decided to buy another card
-(void)buyaCard {
    // TODO: Is it worth breaking out a "dealToPlayer" method to capture basically all the logic in here?
    Player* humanPlayer = [super getHumanPlayer];
    
    // Pay for the card
    [self playerPlacesBet:0 bet:[self costOfBuyingACard]];
    
    // Deal the next card
    Card* dealtCard = deck[deckIndex++];    // Deal the card and then advance the index
    [dealtCard setIsFaceup:YES];
    [humanPlayer addCardToHand:dealtCard];
    [self updatePlayerCards:0];
    
    // If it's another 4, let them buy another card
    if (dealtCard.rank == 4 && [humanPlayer holdings] > [self costOfBuyingACard]) {
        [bettingStatusLabel setText:[NSString stringWithFormat:@"You drew a 4! Care to buy another card for $%d?", [bets[0] intValue]]];
        [self updateActionButtons:ActionButtonStateBuyACard];
    }
    // ... Otherwise, it's time to bet
    else {
        [bettingStatusLabel setText:@"It’s your bet."];
        [self updateActionButtons:ActionButtonStatePlayerBets];
    }
}

// The player drew a 4 but declines to buy a card
-(void)doNotBuyaCard {
    [bettingStatusLabel setText:@"It’s your bet."];
    [self updateActionButtons:ActionButtonStatePlayerBets];
}

// Helper method to record the cost of buying a card in the current game. This stays the same trhoughout the game and is usually the minimum bet amount (but can be set to something different)
-(int)costOfBuyingACard {
    return [bets[0] intValue];
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

// Remove wild cards from a player's hand, for evaluation purposes
-(NSArray<Card*>*)getHandWithoutWildCards:(NSArray<Card*>*)hand {
    NSMutableArray<Card*>* handWithoutWildCards = [[NSMutableArray alloc] init];
    for (Card* c in hand) {
        // 3's and 9's are wild
        if (3 != [c rank] && 9 != [c rank]) {
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
