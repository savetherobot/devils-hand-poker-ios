//
//  HGPGameAnacondaViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 7/21/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPBaseGameViewController.h"
#import <Google/Analytics.h>
#import <UIKit/UIKit.h>
#import "Card.h"
#import "Player.h"
#import "GameDelegate.h"
#import "Constants.h"
#import "PlayerRecordProvider.h"
#import "HandEvaluation.h"
#import "HandEvaluator.h"

typedef enum {
    RoundThreeLeft = 1,
    RoundTwoRight = 2,
    RoundOneLeft
} AnacondaRound;

static int HAND_SIZE = 7;

@interface HGPGameAnacondaViewController : HGPBaseGameViewController {
    UIButton* passCardsButton;
    NSArray<UIButton*>* betButtons;
    UIButton* matchBetButton;
    UIButton* foldButton;
    UIButton* quitButton;
    
    NSArray<UIImageView*>* playerHoldingsBackgrounds;
    NSArray<UILabel*>* playerHoldingsLabels;
    
    HGPModal* resultsModal;

    AnacondaRound currentRound;
    int cardsToSelectThisRound;
    
    int currentBet;
    int currentRaiseAmount;
    
    // Card displays - human has buttons, NPCs just have views
    NSArray<UIButton*>* playerCardButtons;
    NSMutableArray<NSArray<UIImageView*>*>* npcCardViewCollections;
    NSArray<UIView*>* npcCardViews;
}

@end
