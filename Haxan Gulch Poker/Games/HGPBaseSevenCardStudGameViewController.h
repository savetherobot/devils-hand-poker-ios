//
//  HGPBaseSevenCardStudGameViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/21/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPBaseGameViewController.h"
#import "HandEvaluation.h"
#import "HandEvaluator.h"
#import "PlayerRecordProvider.h"

static const int SEVEN_CARD_STUD_HAND_SIZE = 7;

@interface HGPBaseSevenCardStudGameViewController : HGPBaseGameViewController {
    UIButton* matchBetButton;
    UIButton* foldButton;
    UIButton* quitButton;
    
    NSArray<UIButton*>* betButtons;
    
    HGPModal* resultsModal;
    
    NSArray<UIImageView*>* playerHoldingsBackgrounds;
    NSArray<UILabel*>* playerHoldingsLabels;    // TOOD: This should be relabeled for NPCs or combined with the separate label for the human player
    
    int currentRound;
    int currentBet;
    int deckIndex;
    
    int currentRaiseAmount;
    
    // Card displays
    NSArray<UIView*>* playerCardDisplayViews;
    
    // The UIViews of each card that each player's holding
    NSMutableArray<NSMutableArray<UIImageView*>*>* playerCardViews;
}

-(void)displayHoldings;
-(void)displayBetButtons;
-(void)updateHoldings;
-(void)createCardDisplay;
-(void)updatePlayerCards:(int)index;
-(bool)isCardDealtFaceUpThisRound;
-(NSArray<Card*>*)getUnknownCards;
-(bool)playerFolds:(int)index;
-(void)playerPlacesBet:(int)index bet:(int)bet;
-(bool)moveToNextPlayerAndCheckForNextRound;
-(void)updateActionButtons:(ActionButtonState)state;
-(Player*)getPlayerForHandEvaluation:(HandEvaluation*)ranking;
-(NSArray<HandEvaluation*>*)evaluatePlayerHand:(NSArray<Card*>*)hand;
-(int)calculateAiBet:(Player*)aiPlayer;
-(void)displayReplayModal;
-(void)endGame;

@end
