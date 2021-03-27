//
//  PlayerRecord.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/15/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PlayerRecord : NSManagedObject

@property (nonatomic) int winningsToDate;
@property (nonatomic) bool cheatCardUnlocked;
@property (nonatomic) int holdings;
@property (nonatomic) int highestRoomUnlocked;
@property (nonatomic) bool gameUnlocked;
@property (nonatomic) bool isBeastBeaten;

@end
