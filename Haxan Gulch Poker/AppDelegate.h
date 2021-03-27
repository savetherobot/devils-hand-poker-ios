//
//  AppDelegate.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Google/Analytics.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <StoreKit/StoreKit.h>
#import "PlayerRecord.h"
#import "IAPProvider.h"
#import "Card.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * _Nullable window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (nonnull, nonatomic, strong) IAPProvider *iapProvider;
@property (nonatomic, strong) NSDictionary<NSString*, UIImage*>* _Nullable cardImages;

- (void)saveContext;


@end

