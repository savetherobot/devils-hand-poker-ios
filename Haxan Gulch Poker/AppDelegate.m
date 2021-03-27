//
//  AppDelegate.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Keep the loading screen up for another second
  //  [NSThread sleepForTimeInterval:1.0];
    
    // Initialize GA
    GAI *gai = [GAI sharedInstance];
    [gai trackerWithTrackingId:@"UA-106080624-1"];
    
    // Crashlytics
    [Fabric with:@[[Crashlytics class]]];
    
    // Set up the observor for transactions / provider for in-app purchases
    self.iapProvider = [[IAPProvider alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self.iapProvider];

    // Populate the card images
    NSMutableDictionary<NSString*, UIImage*>* cardImgs = [[NSMutableDictionary alloc] init];
    
    for (int i = 1; i <= 4; i++)
    {
        for (int j = 1; j <= 13; j++)
        {
            Card *card = [Card alloc];
            [card setSuit:i];
            [card setRank:j];
            NSString* cardImageFilename = [card getImageFilename];
            NSString* cardImageFilePath = [card getImageFilepath];
            UIImage* cardImage = [UIImage imageWithContentsOfFile:cardImageFilePath];
            [cardImgs setObject:cardImage forKey:cardImageFilename];
        }
    }
    
    // Add the card back ...
    [cardImgs setObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"card_back" ofType:@"png"]] forKey:@"card_back.png"];
    
    // ... the small one ...
    [cardImgs setObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"card_back_small" ofType:@"png"]] forKey:@"card_back_small.png"];
    
    // ... and the reveal
    [cardImgs setObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"card_back_reveal_to_player" ofType:@"png"]] forKey:@"card_back_reveal_to_player.png"];
    
    self.cardImages = [cardImgs copy];

    // Override point for customization after application launch.
    return YES;    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Haxan_Gulch_Poker"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    CLS_LOG(@"Unresolved error %@, %@", error, error.userInfo);
                    [CrashlyticsKit recordError:error];
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        if (error) {
            CLS_LOG(@"Unresolved error %@, %@", error, error.userInfo);
            [CrashlyticsKit recordError:error];
        }
        abort();
    }
}

@end
