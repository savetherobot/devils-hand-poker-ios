//
//  Constants.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/6/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

FOUNDATION_EXPORT int const kMultiplierForThreeOfAKindWin;
FOUNDATION_EXPORT double const kOverlayCardMargin;
FOUNDATION_EXPORT CGFloat const MARGIN_WIDE;
FOUNDATION_EXPORT CGFloat const MARGIN_STANDARD;
FOUNDATION_EXPORT CGFloat const MARGIN_THIN;
FOUNDATION_EXPORT CGFloat const MARGIN_SUPER_THIN;
FOUNDATION_EXPORT CGFloat const MARGIN_BETWEEN_CARDS;
FOUNDATION_EXPORT CGFloat const WIDTH_IS_PERCENTAGE_OF_HEIGHT;
FOUNDATION_EXPORT CGFloat const HEIGHT_IS_PERCENTAGE_OF_WIDTH;
FOUNDATION_EXPORT CGFloat const LABEL_HEIGHT;
FOUNDATION_EXPORT NSString* const kUnlockGameProductID;
FOUNDATION_EXPORT CGFloat const CHOICE_BUTTON_HEIGHT;

FOUNDATION_EXPORT NSString *const kHGPErrorDomain;
FOUNDATION_EXPORT int const kHGPErrorCodeProgrammingError;
FOUNDATION_EXPORT NSString *const kHGPGameUnlocked;

// Keys for a Results dictionary from BetEvaluator
FOUNDATION_EXPORT NSString *const kHGPIndexOfPlayerWithWinningHighHand;
FOUNDATION_EXPORT NSString *const kHGPIndexOfPlayerWithWinningLowHand;
FOUNDATION_EXPORT NSString *const kHGPIndexOfPlayerWithWinningHighAndLowHand;
FOUNDATION_EXPORT NSString *const kHGPWinningHighHandDescription;
FOUNDATION_EXPORT NSString *const kHGPPlayersBettingHighAndLow;

@end
