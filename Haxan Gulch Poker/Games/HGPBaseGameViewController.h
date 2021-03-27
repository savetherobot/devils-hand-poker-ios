//
//  HGPBaseGameViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Card.h"
#import "Player.h"
#import "Room.h"
#import "HGPModal.h"
#import "GameDelegate.h"
#import "PlayerRecordProvider.h"
#import "HGPTutorialViewController.h"
#import "HGPCharacterSceneViewController.h"

@interface HGPBaseGameViewController : UIViewController {
    // The deck
    NSMutableArray<Card*>* deck;
    
    // Players
    NSMutableArray<Player*>* players;
    
    // UI Elements
    UIView* holdingsDisplayView;
    UIView* cardDisplayView;
    UIView* betButtonDisplayView;
    UIView* progressView;
    
    UIButton* nextButton;
    
    UILabel* barkLabel;
    UILabel* bettingStatusLabel;
    UILabel* gameStatusLabel;
        
    UIView* slidingMenuView;
    UIImageView* slidingMenuHitTargetAreaView;
    
    HGPModal* replayModal;
    
    UILabel* playerHoldingsHeaderLabel;
    UILabel* playerHoldingsLabel;
    UIImageView* playerHoldingsBackgroundImageView;
    UILabel* potHoldingsHeaderLabel;
    UILabel* potHoldingsLabel;
    UIImageView* potHoldingsBackgroundImageView;
    
    // Bet values. (This doesn't include variable things like POT)
    NSArray* bets;
    
    int pot;
    
    // The player who is up
    int playerIndex;
}

@property (nonatomic) RoomIdentifier currentRoom;

-(int)getDistanceBetweenTwoCards:(int)firstRank secondRank: (int)secondRank;
-(NSMutableArray* _Nonnull)createDeck:(bool)acesLow;
-(NSMutableArray* _Nonnull)shuffleDeck: (NSMutableArray* _Nonnull) deck;
-(int)getCountOfPlayersLeft;
-(Player* _Nonnull)getHumanPlayer;
-(NSArray<Player*>* _Nonnull)getNPCs;

-(void)resetGame;
-(void)initializeGame;
-(HGPModal* _Nonnull)showModal:(NSString* _Nonnull)text;
-(HGPModal* _Nonnull)showModal:(NSString* _Nonnull)characterPortraitImageName text:(NSString* _Nonnull)text;
-(void)showReplayModal:(bool)allowReplay;
-(void)displaySlidingMenu;
-(void)styleButton:(UIButton* _Nonnull)button;
-(int)smallestPossibleBet;

-(bool)atLeastOneOtherPlayerCanAffordToKeepBetting:(int)moneyRequired;

/**
 This is called when a player folds to see if the player is the Beast, and this is the human player's first time beating them

 @param p The player who folded
 @return Did the player just beat the Beast for the first time
 */
-(bool)checkIfBeastIsBeaten:(Player* _Nonnull)p;

@property (nullable, nonatomic, weak) id<GameDelegate> delegate;

@end
