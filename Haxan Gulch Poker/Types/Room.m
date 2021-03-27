//
//  Room.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/25/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "Room.h"

@implementation Room

- (instancetype)init:(NSString*)roomName charPortrait:(NSString*)portrait minimumHoldings:(int)minimum roomIdentifier:(RoomIdentifier)identifier {
    self = [super init];
    if (self) {
        self->name = roomName;
        self->charPortraitImageName = portrait;
        self->minimumHoldings = minimum;
        self->identifier = identifier;
    }
    
    return self;
}

// Getters for the properties (we don't need setters after we initialize it)

- (NSString*)name {
    return name;
}

- (NSString*)charPortraitImageName {
    return charPortraitImageName;
}

- (int)minimumHoldings {
    return minimumHoldings;
}

- (RoomIdentifier)identifier {
    return identifier;
}

- (UIImage*)getPokerTableBackgroundImage {
    return [Room getPokerTableBackgroundImageForRoom:identifier];
}

+ (UIImage*)getPokerTableBackgroundImageForRoom:(RoomIdentifier)room {
    NSString* imageName;
    switch(room) {
        case RoomDarkAlley:
            imageName = @"A-D-K_WoodBG";
            break;
        case RoomWidowPrecious:
            imageName = @"A-D-K_FineTableBG";
            break;
        case RoomMayorsDen:
            imageName = @"A-D-K_IlluminatiTableBG";
            break;
        case RoomDevilsLair:
            imageName = @"A-D-K_FireTableBG";
            break;
        case RoomBootHillSaloon:
        default: {
            imageName = @"A-D-K_PokerTableBG";
            break;
        }
    }
    
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                             pathForResource:imageName
                                             ofType:@"png"]];
}

@end
    
