//
//  GameDelegate.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/7/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol GameDelegate <NSObject>

@optional
- (void)gameHasEnded;
- (void)refreshDisplay:(bool)restartMusic;
- (void)endMusic;
- (void)unlockTheBeast;
- (void)justBeatGame;
@end

