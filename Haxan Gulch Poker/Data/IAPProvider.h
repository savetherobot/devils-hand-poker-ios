//
//  IAPProvider.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 9/9/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "PlayerRecordProvider.h"

// https://www1.in.tum.de/lehrstuhl_1/teaching/tutorials/511-sgd-ws13-tutorial-store-kit

@interface IAPProvider : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    // You create an instance variable to store the SKProductsRequest you will issue to retrieve a list of products, while it is active.
    SKProductsRequest *productsRequest;
    SKProduct* unlockGameProduct;
    
    UIActivityIndicatorView *spinnerIndicatorView;
    
    // Maintain a separate spinner for the restore purchases workflow
    UIActivityIndicatorView *restorePurchasesSpinnerIndicatorView;
}

/**
 Trigger the purchase of the game unlock
 */
- (void)purchaseUnlockGame;

/**
 Restore any past purchase of the game unlock and update the player record if it's confirmed
 */
- (void)restorePurchases;


/**
 The user triggers the process of restoring purchases (possibly because they aren't aware that this is already happening in the background / it hasn't completed in time). This will force a spinner to appear and block UI until the restore attempt has been completed
 */
- (void)restorePurchasesOnDemand;

@end
