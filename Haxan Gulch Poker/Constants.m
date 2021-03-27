//
//  Constants.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/6/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "Constants.h"

@implementation Constants

int const kMultiplierForThreeOfAKindWin = 5;
double const kOverlayCardMargin = 20.0f;
CGFloat const MARGIN_WIDE = 50.0f;
CGFloat const MARGIN_STANDARD = 20.0f;
CGFloat const MARGIN_THIN = 10.0f;
CGFloat const MARGIN_SUPER_THIN = 4.0f;
CGFloat const MARGIN_BETWEEN_CARDS = 10.0f;
CGFloat const WIDTH_IS_PERCENTAGE_OF_HEIGHT = 0.7598f;
CGFloat const HEIGHT_IS_PERCENTAGE_OF_WIDTH = 1.3135f;
CGFloat const LABEL_HEIGHT = 18.0f;
NSString* const kUnlockGameProductID = @"1001";
CGFloat const CHOICE_BUTTON_HEIGHT = 35.0f;

// Errors
NSString *const kHGPErrorDomain = @"com.gatheraroundthefire.devilshandpoker.error";
int const kHGPErrorCodeProgrammingError = 0;
NSString *const kHGPGameUnlocked = @"com.gatheraroundthefire.devilshandpoker.gameunlocked";

// Bet Evaluator dictionary keys
NSString *const kHGPIndexOfPlayerWithWinningHighHand = @"com.gatheraroundthefire.devilshandpoker.winninghighhand.playerindex";
NSString *const kHGPIndexOfPlayerWithWinningLowHand = @"com.gatheraroundthefire.devilshandpoker.winninglowhand.playerindex";
NSString *const kHGPIndexOfPlayerWithWinningHighAndLowHand = @"com.gatheraroundthefire.devilshandpoker.winninghighandlowhand.playerindex";
NSString *const kHGPWinningHighHandDescription = @"com.gatheraroundthefire.devilshandpoker.winninghighhand.description";
NSString *const kHGPPlayersBettingHighAndLow = @"com.gatheraroundthefire.devilshandpoker.playersbettinghighandlow.names";

@end
