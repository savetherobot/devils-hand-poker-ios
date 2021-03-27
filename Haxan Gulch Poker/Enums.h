//
//  Enums.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/6/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#ifndef Enums_h
#define Enums_h

// Keys for the tab bar icons/tabs
typedef NS_ENUM(NSInteger, ActionButtonState) {
    ActionButtonStatePlayerBets = 0,
    ActionButtonStateHighLowBet,
    ActionButtonStateNextButton,
    ActionButtonStateGameOver,
    ActionButtonStateMatchOrFoldButton,
    ActionButtonStateBuyACard,
    ActionButtonStatePassCards,
    ActionButtonStateWatchOrSkipToEnd,
    ActionButtonStateHighLowBoth,
    ActionButtonStateNone
};

// The rooms
typedef NS_ENUM(NSInteger, RoomIdentifier) {
    RoomDarkAlley = 0,
    RoomWidowPrecious,
    RoomBootHillSaloon,
    RoomMayorsDen,
    RoomDevilsLair
};

// The games
typedef NS_ENUM(NSInteger, Game) {
    GameAceyDeucey = 0,
    GameAnaconda,
    GameDayBaseball,
    GameFollowTheQueen,
    GameHighLow
};

// Character scenes
typedef NS_ENUM(NSInteger, CharacterScene) {
    CharacterSceneHorseStables = 0,
    CharacterSceneHotel,
    CharacterSceneChurch,
    CharacterSceneFishingHole,
    CharacterSceneEnding
};

// Bet types
typedef NS_ENUM(NSInteger, BetType) {
    BetTypeAceyDeucey = 0, // The face-down card must be between the face-up cards
    BetTypeTheGulch,       // The face-up cards are next to each other; bet that the third is higher or lower than them (and of course, it could just be equal to one of them)
    BetTypeThreeOfAKind    // The face-up cards are the same; bet that the third one will be as well
};

// Button types
typedef NS_ENUM(NSInteger, ActionButtonType) {
    ActionButtonTypeGulchLow = 0,
    ActionButtonTypeGulchHigh,
    ActionButtonTypeMatchBet,
    ActionButtonTypeFold,
    ActionButtonBuyACard,
    ActionButtonTypeHighHand,
    ActionButtonTypeLowHand,
    ActionButtonTypeHighAndLowHand,
    ActionButtonNoThanks
};

// Gulch comparison - used to communicate whether the facedown card is higher than, lower than, or stuck in the Gulch of two consecutive faceup cards
typedef NS_ENUM(NSInteger, GulchComparison) {
    GulchComparisonLowerThanGulch = 0,
    GulchComparisonStuckInGulch,
    GulchComparisonHigherThanGulch
};

// Follow the Queen status
typedef NS_ENUM(NSInteger, FollowTheQueenStatus) {
    FollowTheQueenWildCardNotSet = 0,
    FollowTheQueenWildNextCardIsWild,
    FollowTheQueenWildCardIsSet
};

// High-Low bets
typedef NS_ENUM(NSInteger, HighLowBetType) {
    HighLowBetHigh = 0,
    HighLowBetLow,
    HighLowBetBoth,
    HighLowBetNone
};

// Poker hands, in order from highest to lowest
typedef NS_ENUM(NSInteger, HandType) {
    RoyalFlush = 1,
    StraightFlush,
    FourOfAKind,
    FullHouse,
    Flush,
    Straight,
    ThreeOfAKind,
    TwoPair,
    Pair,
    NoRank
};

#endif
