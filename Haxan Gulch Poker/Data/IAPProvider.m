//
//  IAPProvider.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 9/9/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "IAPProvider.h"

@implementation IAPProvider

// For reference:
// https://github.com/xswapnull/iOS-In-App-Purchase/blob/master/In%20App%20Purchase/IAPHelper.m

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize the list of products we can buy (well, there's only one ... )
        NSSet* productIdentifiers = [[NSSet alloc] initWithArray:@[kUnlockGameProductID]];
        productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    
    return self;
}

#pragma mark Get the products available for purchase

// Looks up the products available for sale and stores our one product as an SKProduct object
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response  {
    NSArray* skProducts = response.products;
    for (SKProduct* skProduct in skProducts) {
        if ([skProduct.productIdentifier isEqualToString:kUnlockGameProductID]) {
            unlockGameProduct = skProduct;
            break;
        }
    }
    
    // FIXME: Send a notification or something that this has completed? Or hang onto a completion handler ...
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    //FIXME: Alert user to the error
    [CrashlyticsKit recordError:error];
    
    productsRequest = nil;
}

// Make sure that the app is ready to try to handle a purchase - specifically that the product information has been loaded
- (bool)readyToUnlockGame {
    return (nil != unlockGameProduct);
}

#pragma mark Restore purchases

// Called in the background, with no affect on the UI
- (void)restorePurchases {
    // Restore any purchases ...
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

// Called on demand by tapping the "Restore Purchase" button on the unlock screen; shows a spinner and locks UI
- (void)restorePurchasesOnDemand {
    // Restore any purchases ...
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    [self startRestorePurchasesSpinner];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    // Stop the spinner, if it is active
    [self stopRestorePurchasesSpinner];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [CrashlyticsKit recordError:error];
    
    [self displayConfirmationAlertWithTitle:@"Restore Failed" andMessage:@"Looks like we had a problem restoring your purchase. Try again later!"];
    
    // Stop the spinner, if it is active
    [self stopRestorePurchasesSpinner];
}

// FIXME: This is an iOS 11 feature - maybe test then? https://developer.apple.com/documentation/storekit/skpaymenttransactionobserver/2877502-paymentqueue?changes=latest_minor&language=objc
- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product {
    // FIXME: What should this do ... ?
    
    return TRUE;
}

#pragma mark Main method for handling transactions

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    // FIXME: Implement and review
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                NSLog(@"Purchasing");
                
                // Launch the spinner
                [self startSpinner];
                break;
            }
            case SKPaymentTransactionStatePurchased: {
                if ([transaction.payment.productIdentifier
                     isEqualToString:kUnlockGameProductID]) {
                    
                    // Unlock the game (they get their money's worth)
                    [PlayerRecordProvider unlockGameForPlayer];
                    
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"
                                                                          action:@"Unlock Purchased"
                                                                           label:@"Purchase"
                                                                           value:@1] build]];
                    
                    [self displayConfirmationAlertWithTitle:@"Purchase Complete" andMessage:@"You've unlocked the game!"];
                }
                [self stopSpinner];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                // Unlock the game (they get their money's worth)
                [PlayerRecordProvider unlockGameForPlayer];
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"
                                                                      action:@"Unlock Restored"
                                                                       label:@"Purchase"
                                                                       value:@1] build]];
                
                [self displayConfirmationAlertWithTitle:@"Purchase Restored" andMessage:@"Your game is unlocked!"];
                
                [self stopSpinner];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:
                if (transaction.error.code != SKErrorPaymentCancelled)
                {
                    [self displayConfirmationAlertWithTitle:@"Purchase Failed" andMessage:@"Looks like we had a problem completing the sale. Try again later!"];
                    
                    CLS_LOG(@"Transaction error: %@", transaction.error.localizedDescription);
                    [CrashlyticsKit recordError:transaction.error];
                }
                
                [self stopSpinner];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)purchaseUnlockGame {
    if ([SKPaymentQueue canMakePayments]) {
        if (unlockGameProduct) {
            SKPayment *payment = [SKPayment paymentWithProduct:unlockGameProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        else {
            // We haven't been able to load the products - display an error
            [self displayConfirmationAlertWithTitle:@"Unable to Complete Purchase" andMessage:@"Sorry partner - we can't seem to get in touch with the App Store! Try again later."];
        }
    }
    else {
        // Player can't unlock them
        [self displayConfirmationAlertWithTitle:@"Purchase Not Allowed" andMessage:@"Sorry partner - you can't make purchases on your account!"];
    }
}

#pragma mark UI Helpers

-(void)startSpinner {
    UIViewController *rootViewController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    if (nil == spinnerIndicatorView) {
        spinnerIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(rootViewController.view.center.x - 25.0f, rootViewController.view.center.y - 25.0f, 50, 50)];
        [spinnerIndicatorView startAnimating];
        [spinnerIndicatorView setHidesWhenStopped:YES];
        [rootViewController.view addSubview:spinnerIndicatorView];
    }
    else {
        [spinnerIndicatorView startAnimating];
    }
    
    // And finally, block the user
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

-(void)stopSpinner {
    if (spinnerIndicatorView) [spinnerIndicatorView stopAnimating];
    
    // And finally, unblock the user
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

// We'll maintain a separate spinner for restoring purchases on demand. If the user taps the Restore Purchases button, this is the spinner they'll get
-(void)startRestorePurchasesSpinner {
    UIViewController *rootViewController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    if (nil == restorePurchasesSpinnerIndicatorView) {
        restorePurchasesSpinnerIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(rootViewController.view.center.x - 25.0f, rootViewController.view.center.y - 25.0f, 50, 50)];
        [restorePurchasesSpinnerIndicatorView startAnimating];
        [restorePurchasesSpinnerIndicatorView setHidesWhenStopped:YES];
        [rootViewController.view addSubview:restorePurchasesSpinnerIndicatorView];
    }
    else {
        [restorePurchasesSpinnerIndicatorView startAnimating];
    }
    
    // And finally, block the user
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

-(void)stopRestorePurchasesSpinner {
    if (restorePurchasesSpinnerIndicatorView) [restorePurchasesSpinnerIndicatorView stopAnimating];
    
    // And finally, unblock the user
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

-(void)displayConfirmationAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    // Confirm the purchase
    UIAlertController *purchaseAlertCtrl = [UIAlertController
                                            alertControllerWithTitle:title
                                            message:message
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Close"                                          style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [purchaseAlertCtrl addAction:dismissAction];
    
    UIViewController *rootViewController = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    [rootViewController presentViewController:purchaseAlertCtrl animated:YES completion:nil];
}

@end
