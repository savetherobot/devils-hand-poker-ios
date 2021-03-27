//
//  HCPGameSelectionViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 9/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "GameDelegate.h"
#import "HGPGameAceyDeuceyViewController.h"
#import "HGPGameAnacondaViewController.h"
#import "HGPGameDayBaseBallViewController.h"
#import "HGPGameHighLowViewController.h"
#import "HGPGameFollowTheQueenViewController.h"
#import "HGPTutorialViewController.h"

@interface HGPGameSelectionViewController : UIViewController <GameDelegate> {
    UIView* slidingMenuView;
    UIImageView* slidingMenuHitTargetAreaView;
}

@property (nonatomic) RoomIdentifier currentRoom;

@property (nullable, nonatomic, weak) id<GameDelegate> delegate;

@end
