//
//  HGPGameFollowTheQueenViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 9/24/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPBaseSevenCardStudGameViewController.h"

static int const NO_WILD_CARD = -1;

@interface HGPGameFollowTheQueenViewController : HGPBaseSevenCardStudGameViewController {
    int wildCardRank;
    FollowTheQueenStatus status;
}

@end
