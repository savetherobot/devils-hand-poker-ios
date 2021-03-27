//
//  HGPGameAceyDeuceyViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "Card.h"
#import "Player.h"
#import "HGPBaseGameViewController.h"
#import "Constants.h"
#import "PlayerRecordProvider.h"
#import "BarkProvider.h"

@interface HGPGameAceyDeuceyViewController : HGPBaseGameViewController {
    NSArray<UIButton*>* betButtons;
    UIButton* gulchHighBetButton;
    UIButton* gulchLowBetButton;
    UIButton* quitButton;
    UIButton* watchTheGameButton;
    UIButton* skipToTheEndButton;
    NSArray<UIImageView*>* cardImageViews;
    NSArray<UIImageView*>* playerHoldingsBackgrounds;
    NSArray<UILabel*>* playerHoldingsLabels;
    NSArray<UILabel*>* playerHoldingsDisplayLabels;
    
    int indexPotButton;
    int indexFoldButton;
    
    // Display cards
    NSArray* cardsInPlay;
    BetType betTypeThisRound;
    
    // Other game settings
    bool isCheatingEnabled;
    
    // If we're going to unlock the fifth room ...
    bool isRevealingTheBeast;
    
    int deckIndex;
}

@end
