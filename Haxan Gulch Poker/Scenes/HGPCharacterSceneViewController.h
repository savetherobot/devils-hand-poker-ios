//
//  HGPCharacterSceneViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/15/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "HGPDialogCard.h"
#import "PlayerRecordProvider.h"
#import "GameDelegate.h"

@interface HGPCharacterSceneViewController : UIViewController <SceneDelegate> {
    int sceneIndex;
}

@property (nullable, nonatomic, weak) id<GameDelegate> delegate;

@property (nonatomic) CharacterScene currentScene;
@property (nonatomic, strong) HGPDialogCard* _Nullable dialogCard;

@end
