//
//  HGPGameHighLowViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 9/22/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPBaseSevenCardStudGameViewController.h"
#import "Card.h"
#import "HandEvaluator.h"
#import "BetEvaluator.h"

@interface HGPGameHighLowViewController : HGPBaseSevenCardStudGameViewController {
    int wildCardRank;
    
    UIButton* highButton;
    UIButton* lowButton;
    UIButton* highAndLowButton;
}

@end
