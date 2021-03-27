//
//  HGPGameIntroViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/6/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"
#import "HGPGameSelectionViewController.h"

@interface HGPGameIntroViewController : UIViewController <GameDelegate> {
    NSString *backgroundImageName;
    NSString *titleTextImageName;
    NSString *portraitImageName;
    NSString *introText;
}

@property (nonatomic) RoomIdentifier currentRoom;
@property (nonatomic, strong) UIImageView* _Nullable overlay;

@property (nullable, nonatomic, weak) id<GameDelegate> delegate;

- (void)gameHasEnded;

@end
