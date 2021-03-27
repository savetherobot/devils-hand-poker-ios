//
//  Room.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/25/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Room : NSObject {
    NSString *name;
    NSString *charPortraitImageName;
    NSString *pokerTableBackgroundImageName;
    int minimumHoldings;
    RoomIdentifier identifier;
}

- (instancetype)init:(NSString*)roomName charPortrait:(NSString*)portrait minimumHoldings:(int)minimum roomIdentifier:(RoomIdentifier)identifier;

- (NSString*)name;

- (NSString*)charPortraitImageName;

- (RoomIdentifier)identifier;

- (int)minimumHoldings;

- (UIImage*)getPokerTableBackgroundImage;

/**
 A helper method to retrieve the poker table for the specified enum
 */
+ (UIImage*)getPokerTableBackgroundImageForRoom:(RoomIdentifier)room;

@end
