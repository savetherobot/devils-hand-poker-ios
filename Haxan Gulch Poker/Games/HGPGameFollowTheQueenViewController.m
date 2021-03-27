//
//  HGPGameFollowTheQueenViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 9/24/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPGameFollowTheQueenViewController.h"

@interface HGPGameFollowTheQueenViewController ()

@end

// FIXME: The results modal can't hold five players' results

// FIXME: What if the last faceup card dealt is a queen?

@implementation HGPGameFollowTheQueenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the first set of action buttons and so, hide all the other ones
    [self updateActionButtons:ActionButtonStatePlayerBets];
    
    // With the view established, initialize the game
    [self initializeGame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Game - Follow the Queen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark Game logic methods

-(void)initializeGame {
    // There is no wild card at first
    wildCardRank = NO_WILD_CARD;
    status = FollowTheQueenWildCardNotSet;
    
    [super initializeGame];
}

-(void)advanceRound {
    // Queue up the next player
    [self moveToNextPlayerAndCheckForNextRound];
    
    // Check to see if the game is over
    if ([super getCountOfPlayersLeft] == 1 || (currentRound > 7)) {
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
            
            // Check if this affects the Follow the Queen wild card and if so, get a result message that we can display
            NSString* wildCardDisplay = [self checkWildCardStatus:dealtCard];

            [humanPlayer addCardToHand:dealtCard];
            [super updatePlayerCards:0];
            
            if (!wildCardDisplay)
            {
                wildCardDisplay = (wildCardRank != NO_WILD_CARD) ?
                [NSString stringWithFormat:@"%@%@s are wild.", [Card getDisplayNameForRank:wildCardRank], wildCardRank < 11 ? @"’" : @""]
                : @"";
            }
            
            [bettingStatusLabel setText:[NSString stringWithFormat:@"%@%@It’s your bet.", wildCardDisplay, (wildCardDisplay && [wildCardDisplay length] > 0) ? @"\n" : @""]];
            
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

    // Check if this affects the Follow the Queen wild card and if so, get a result message that we can display
    NSString* wildCardDisplay = [self checkWildCardStatus:dealtCard];
    
    [currentAi addCardToHand:dealtCard];
    [self updatePlayerCards:playerIndex];
    
    // Call calculateAiBet, which does all the work of figuring out how the AI will bet given what's on the table and in their hand
    int bet = [self calculateAiBet:players[playerIndex]];
    [self playerPlacesBet:playerIndex bet:bet];
    
    // Finish formatting the wild card display. It'll either be an empty string, or a string with a line break
    // TODO: Is there a less kludgey way to do this?
    wildCardDisplay = (nil == wildCardDisplay) ? @"" : [NSString stringWithFormat:@"%@\n", wildCardDisplay];
    
    // Does the AI fold?
    if (-1 == bet) {
        [self playerFolds:playerIndex];
        [bettingStatusLabel setText:[NSString stringWithFormat:@"%@%@ folds.", wildCardDisplay, [currentAi name]]];
        [self updateActionButtons:ActionButtonStateNextButton];
    }
    // Nope, they bet:
    else {
        // If the AI feels good, it'll raise
        if (bet > currentBet) {
            currentRaiseAmount = bet - currentBet;
            
            // The player is the first to match. Once they do, the matchBet method will work through the other AIs' response
            if ([[super getHumanPlayer] isStillInGame]) {
                [bettingStatusLabel setText:[NSString stringWithFormat:@"%@%@ bets $%d. Do you match?", wildCardDisplay, [currentAi name], bet]];
                
                [self updateActionButtons:ActionButtonStateMatchOrFoldButton];
            }
            else {
                // Skip straight to the AI actions
                [bettingStatusLabel setText:[NSString stringWithFormat:@"%@%@ bets $%d", wildCardDisplay, [currentAi name], bet]];
                [self aiMatchesBet];
            }
        }
        // Otherwise, they call
        else {
            [bettingStatusLabel setText:[NSString stringWithFormat:@"%@%@ bets $%d", wildCardDisplay, [currentAi name], bet]];
            [self updateActionButtons:ActionButtonStateNextButton];
        }
    }
}

-(NSString*)checkWildCardStatus:(Card*)dealtCard {
    // Face-down cards don't affect the wild card status
    if (![dealtCard isFaceup]) return nil;
    
    // If it's a queen, then the next card is wild
    if ([dealtCard rank] == 12) {
        status = FollowTheQueenWildNextCardIsWild;
        return @"There’s her highness! Next card up is wild.";
    }
    
    // If we're waiting to set the wild card, then this card is it. (If the card was another Queen, then the last statement would have dealt with it)
    if (status == FollowTheQueenWildNextCardIsWild) {
        wildCardRank = [dealtCard rank];
        status = FollowTheQueenWildCardIsSet;
        return [NSString stringWithFormat:@"A%@ %@ follows the queen! That’s our new wild card.", wildCardRank == 1 || wildCardRank == 14 || wildCardRank == 8 ? @"n" : @"", [Card getDisplayNameForRank:wildCardRank] ];    // Optionally make it say "An " in case the card is an Ace or an 8
    }
    
    // Otherwise, nothing happened
    return nil;
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

// Remove wild cards from a player's hand, for evaluation purposes
-(NSArray<Card*>*)getHandWithoutWildCards:(NSArray<Card*>*)hand {
    if (NO_WILD_CARD == wildCardRank) return hand;
    
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
