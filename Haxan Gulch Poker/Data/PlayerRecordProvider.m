//
//  PlayerRecordProvider.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/15/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "PlayerRecordProvider.h"

@implementation PlayerRecordProvider

+(int)getWinningsToDate {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    if (player) {
        return player.winningsToDate;
    }
    
    return 0;
}

+(void)setWinningsToDate:(int)winningsToDate {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    if (player) {
        player.winningsToDate = winningsToDate;
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
    }
}

+(void)addWinnings:(int)winnings {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    if (player) {
        player.winningsToDate = player.winningsToDate + winnings;
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
    }
}

+(void)updateHighestRoomUnlocked:(int)highestRoom {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    if (player && player.highestRoomUnlocked < highestRoom) {
        player.highestRoomUnlocked = highestRoom;
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
    }
}

+(bool)isGameUnlocked {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    if (player) {
        return player.gameUnlocked;
    }
    
    // TODO: Error if there's no player
    return false;
}

+(void)unlockGameForPlayer {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    if (player) {
        player.gameUnlocked = true;
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
    }
    
    // Send a notification to hide the Unlock Game modal
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGPGameUnlocked object:nil userInfo:nil];
}

+(PlayerRecord*)fetchPlayerRecord {
    NSPersistentContainer* container = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) persistentContainer];
    
    NSManagedObjectContext *moc = container.viewContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PlayerRecord"];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    if (error) {
        [CrashlyticsKit recordError:error];
    }
    
    // If none has been created, create it now
    if (!results || [results count] == 0) {
        PlayerRecord* playerRecord = [NSEntityDescription insertNewObjectForEntityForName:@"PlayerRecord" inManagedObjectContext:moc];
        playerRecord.winningsToDate = 20;
        playerRecord.holdings = 20;
        playerRecord.cheatCardUnlocked = false;
        playerRecord.highestRoomUnlocked = 0;
        playerRecord.isBeastBeaten = false;
        playerRecord.gameUnlocked = false;
 
        // Check if the player has unlocked the game and if so, we'll udpate the player record
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]).iapProvider restorePurchases];

        // TODO: Initialize other values?
        
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
        
        return playerRecord;
    }
    
    else return [results firstObject];
}

// TODO: Is this a stupid way to do this? Probably ... 
+(void)updatePlayerRecord:(PlayerRecord*)playerRecord {
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
}

@end
