//
//  ViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Google/Analytics.h>
#import "Room.h"
#import "GameDelegate.h"
#import "HGPGameIntroViewController.h"
#import "HGPCharacterSceneViewController.h"
#import "HGPCreditsViewController.h"
#import "PlayerRecordProvider.h"

@interface ViewController : UIViewController <GameDelegate, SceneDelegate> {
    int roomIndex;
    NSArray<Room*>* rooms;
    
    UIButton* leftButton;
    UIButton* rightButton;
    UIButton* btnOddJobs;
    UIButton* btnCredits;
    
    UILabel* roomNameLabel;
    UIImageView* charPortraitImageView;
    UIImageView* roomSelectorBackgroundImageView;
    UIButton* anteButton;
    
    UIView* oddJobsView;
    HGPModal* oddJobsModal;
    
    HGPDialogCard* unlockGameModal;
    
    int playerHoldings;
    
    AVAudioPlayer* audioPlayer;
}

@property (nonatomic, strong) UILabel* holdingsLabel;

- (void)refreshDisplay:(bool)restartMusic;
- (void)unlockTheBeast;

@end

