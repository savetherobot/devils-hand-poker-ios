//
//  HGPGameDayBaseBallViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/12/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPBaseSevenCardStudGameViewController.h"
#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "Card.h"
#import "Player.h"
#import "GameDelegate.h"
#import "PlayerRecordProvider.h"
#import "HandEvaluation.h"
#import "HandEvaluator.h"

@interface HGPGameDayBaseBallViewController : HGPBaseSevenCardStudGameViewController {
    UIButton* buyaCardButton;
    UIButton* passOnBuyingACardButton;
}

@end
