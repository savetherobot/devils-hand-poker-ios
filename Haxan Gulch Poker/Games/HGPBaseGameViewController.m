//
//  HGPBaseGameViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPBaseGameViewController.h"
#import "HandEvaluator.h"
#import "HandEvaluation.h"

@interface HGPBaseGameViewController ()

@end

@implementation HGPBaseGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    
    UIImage* pokerTable = [Room getPokerTableBackgroundImageForRoom:self.currentRoom];
    
    [pokerTable drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    ///////////////////////////////////////////////////////////////////////
    // Set up the game elements
    
    // Place your bets
    CGFloat yPositionTopOfBettingArea = self.view.frame.size.height - MARGIN_THIN - LABEL_HEIGHT * 3.5 - MARGIN_STANDARD;
    
    // The betting status label handles the current round
    bettingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_STANDARD * 2, yPositionTopOfBettingArea, self.view.frame.size.width - MARGIN_STANDARD * 4, LABEL_HEIGHT)];
    
    [bettingStatusLabel setFont:[UIFont fontForBody]];
    [bettingStatusLabel setTextColor:[UIColor colorWithRed:209/255.0 green:193/255.0 blue:80/255.0 alpha:1.0f]];
    [bettingStatusLabel setTextAlignment:NSTextAlignmentCenter];
    [bettingStatusLabel setText:@"It's your bet"];
    [self.view addSubview:bettingStatusLabel];
 
    // Initialize the bet button display view
    CGFloat buttonBarHeight = CGRectGetWidth(self.view.frame) * 0.075f;
    UIImageView* buttonBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - buttonBarHeight, CGRectGetWidth(self.view.frame), buttonBarHeight)];
    [buttonBackground setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BetBar" ofType:@"png"]]];
    [self.view addSubview:buttonBackground];
    
    CGFloat buttonBarTopMargin = buttonBarHeight * 0.0972f;
    betButtonDisplayView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, CGRectGetMinY(buttonBackground.frame) + buttonBarTopMargin, self.view.frame.size.width - MARGIN_STANDARD * 2, buttonBarHeight  - buttonBarTopMargin)];
    [self.view addSubview:betButtonDisplayView];

    //////////////////////////////////////////////////////////////
    // The progress view
    CGFloat widthOfProgressView = (CGRectGetWidth(self.view.frame) - MARGIN_STANDARD * 2) * 0.95f;   // Work out the correct width and then tuck it in by another 20% to ensure it fits well within the bar
    CGFloat progressViewCardWidth = (widthOfProgressView / SIZE_OF_DECK) * 0.5689f; // The 0.5689f represents the fact that each card overlaps the previous one
    CGFloat progressViewMaxCardHeight = progressViewCardWidth * HEIGHT_IS_PERCENTAGE_OF_WIDTH; //  cardWidth * 0.60345;
    
    // While most of the cards overlap each other, the last one on the end will not. Adjust the x cordinate of the progress view to account for that, so we can properly center the whole thing
    CGFloat progressViewX = ((CGRectGetWidth(self.view.frame) - widthOfProgressView) / 2) - ((widthOfProgressView / SIZE_OF_DECK) - progressViewCardWidth);
    
    progressView = [[UIView alloc] initWithFrame:CGRectMake(progressViewX, CGRectGetMinY(buttonBackground.frame) - progressViewMaxCardHeight, widthOfProgressView, progressViewMaxCardHeight)];
    
    [self.view insertSubview:progressView belowSubview:buttonBackground];
    
    ////////////////////////////////////////////////////
    // Data
    
    // Set up players
    players = [[NSMutableArray alloc] init];
    
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    int holdings = player.holdings;
    
    // Each room is different ...
    switch(self.currentRoom) {
        case RoomDarkAlley: {
            [players addObject:[[Player alloc] init:@"YOU" holdings:holdings playerType:PlayerTypeHuman]];
            [players addObject:[[Player alloc] init:@"Doc Goggly" holdings:27 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"The Mute" holdings:24 playerType:PlayerTypeNPC_Simple]];
            
            // Set up the bets
            bets = @[[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:5]];
            pot = 0;
            break;
        }
        case RoomWidowPrecious: {
            [players addObject:[[Player alloc] init:@"YOU" holdings:holdings playerType:PlayerTypeHuman]];
            [players addObject:[[Player alloc] init:@"Miss Sarah" holdings:105 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"Ms Violet" holdings:110 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"Widow Precious" holdings:150 playerType:PlayerTypeNPC_Simple]];
            
            // Set up the bets
            bets = @[[NSNumber numberWithInt:5], [NSNumber numberWithInt:10], [NSNumber numberWithInt:15]];
            pot = 0;
            break;
        }
        case RoomBootHillSaloon:{
            [players addObject:[[Player alloc] init:@"YOU" holdings:holdings playerType:PlayerTypeHuman]];
            [players addObject:[[Player alloc] init:@"Ginny Ivories" holdings:350 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"Freddy Byline" holdings:325 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"Doc Fixins" holdings:425 playerType:PlayerTypeNPC_Simple]];
            
            // Set up the bets
            bets = @[[NSNumber numberWithInt:10], [NSNumber numberWithInt:25], [NSNumber numberWithInt:50]];
            pot = 0;
            break;
        }
        case RoomMayorsDen: {
            [players addObject:[[Player alloc] init:@"YOU" holdings:holdings playerType:PlayerTypeHuman]];
            [players addObject:[[Player alloc] init:@"The Mayor" holdings:3000 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"Judge Hangum" holdings:3500 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"John Digger" holdings:3500 playerType:PlayerTypeNPC_Simple]];
            
            // Set up the bets
            bets = @[[NSNumber numberWithInt:100], [NSNumber numberWithInt:150], [NSNumber numberWithInt:200]];
            pot = 0;
            break;
        }
        case RoomDevilsLair: default: {
            [players addObject:[[Player alloc] init:@"YOU" holdings:holdings playerType:PlayerTypeHuman]];
            [players addObject:[[Player alloc] init:@"Doc Goggly" holdings:30000 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"Widow Precious" holdings:30000 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"The Bartender" holdings:30000 playerType:PlayerTypeNPC_Simple]];
            [players addObject:[[Player alloc] init:@"The Devil" holdings:40000 playerType:PlayerTypeNPC_Beast]];
            
            // Set up the bets
            bets = @[[NSNumber numberWithInt:500], [NSNumber numberWithInt:1000], [NSNumber numberWithInt:1500]];
            pot = 0;
            break;
        }
    }
}

#pragma mark Game logic methods - shared across all games

// This is meant to be subclassed
-(void)initializeGame {
    
}

-(void)resetGame {
    
}

-(void)leaveGame {
    // FIXME: Present a confirmation dialog?
    
    // Track with GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"
                                                          action:@"Leave Game"
                                                           label:NSStringFromClass([self class])
                                                           value:@1] build]];
    
    // Update with what the player is holding ...
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    int currentPlayerHoldings = [[self getHumanPlayer] holdings];
    [player setHoldings:currentPlayerHoldings];
    [PlayerRecordProvider updatePlayerRecord:player];
    
    // Leave
    [self.delegate gameHasEnded];
    [self removeFromParentViewController];
}

-(int)getDistanceBetweenTwoCards:(int)firstRank secondRank: (int)secondRank {
    if (firstRank > secondRank) return firstRank - secondRank;
    return secondRank - firstRank;
}

-(NSMutableArray*)createDeck:(bool)acesLow {
    NSMutableArray* d = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= 4; i++)
    {
        for (int j = (acesLow ? 1 : 2); j <= (acesLow ? 13 : 14); j++)
        {
            Card *card = [Card alloc];
            [card setSuit:i];
            [card setRank:j];
            [d addObject:card];
        }
    }
    
    return d;
}

// Shuffle the specified deck
- (NSMutableArray*)shuffleDeck: (NSMutableArray*) unshuffledDeck {
    NSMutableArray* shuffledDeck = [NSMutableArray array];
    for (int i = SIZE_OF_DECK; i > 0; i--)
    {
        int index = arc4random_uniform(i);
        [shuffledDeck addObject: unshuffledDeck[index]];
        [unshuffledDeck removeObjectAtIndex: index];
    }
    
    return shuffledDeck;
}

-(Player*)getHumanPlayer {
    for(Player* p in players) {
        if ([p playerType] == PlayerTypeHuman) return p;
    }
    
    return nil;
}

-(NSArray<Player*>*)getNPCs {
    NSMutableArray* npcPlayers = [[NSMutableArray alloc] init];
    for (Player* p in players) {
        if ([p playerType] != PlayerTypeHuman) [npcPlayers addObject:p];
    }
    
    return [npcPlayers copy];
}

// Helper method, usually used to check if we're down to one player
-(int)getCountOfPlayersLeft {
    int playersRemaining = 0;
    for (Player* p in players) {
        if ([p isStillInGame]) playersRemaining++;
    }
    
    return playersRemaining;
}

#pragma mark Modals

// Handle the sliding menu
-(void)displaySlidingMenu {
    // The sliding menu is 784 × 427
    // The button nub at the top is 182 x 132
    // The space to the left of the button is 599 (you know, give or take)
    CGFloat buttonAreaHeight = CGRectGetHeight(betButtonDisplayView.frame);
    CGFloat buttonAreaWidth = CGRectGetHeight(betButtonDisplayView.frame) * 1.44f;
    
    int numberOfButtons = 3;
    CGFloat menuSliderAreaWidth = buttonAreaWidth * 4.3077;
    CGFloat menuSliderAreaHeight = (LABEL_HEIGHT * numberOfButtons) + (MARGIN_STANDARD * (numberOfButtons + 1));
    
    // The area to the left of the button is
    slidingMenuView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(betButtonDisplayView.frame) - menuSliderAreaWidth - (buttonAreaWidth / 2), CGRectGetHeight(self.view.frame), menuSliderAreaWidth, menuSliderAreaHeight)];
    
    UIImageView* slidingMenuBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, menuSliderAreaWidth, menuSliderAreaHeight)];
    [slidingMenuBackgroundImageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"menu_popup" ofType:@"png"]]];
    
    [slidingMenuView addSubview:slidingMenuBackgroundImageView];
    
    CGFloat buttonY = MARGIN_STANDARD;
    
    UIButton* changeGameButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, buttonY, menuSliderAreaWidth - (MARGIN_STANDARD * 2), LABEL_HEIGHT)];
    changeGameButton.titleLabel.font = [UIFont fontForBody];
    [changeGameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changeGameButton setTitle:@"Try a Different Game" forState:UIControlStateNormal];
    [changeGameButton addTarget:self action:@selector(chooseADifferentGame) forControlEvents:UIControlEventTouchUpInside];
    [slidingMenuView addSubview:changeGameButton];
    
    UIButton* tutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, CGRectGetMaxY(changeGameButton.frame) + MARGIN_STANDARD, menuSliderAreaWidth - (MARGIN_STANDARD * 2), LABEL_HEIGHT)];
    tutorialButton.titleLabel.font = [UIFont fontForBody];
    [tutorialButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tutorialButton setTitle:@"See the Tutorial" forState:UIControlStateNormal];
    [tutorialButton addTarget:self action:@selector(viewTutorial) forControlEvents:UIControlEventTouchUpInside];
    [slidingMenuView addSubview:tutorialButton];
    
    UIButton* leaveGameButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, CGRectGetMaxY(tutorialButton.frame) + MARGIN_STANDARD, menuSliderAreaWidth - (MARGIN_STANDARD * 2), LABEL_HEIGHT)];
    leaveGameButton.titleLabel.font = [UIFont fontForBody];
    [leaveGameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leaveGameButton setTitle:@"Back to Menu" forState:UIControlStateNormal];
    [leaveGameButton addTarget:self action:@selector(leaveTheGameEarly) forControlEvents:UIControlEventTouchUpInside];
    [slidingMenuView addSubview:leaveGameButton];
    
    [slidingMenuView setUserInteractionEnabled:YES];

    [self.view addSubview:slidingMenuView];

    // ... and then we separately create and add the hit area so that we can still tap the button section
    slidingMenuHitTargetAreaView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(betButtonDisplayView.frame) - buttonAreaWidth - (buttonAreaWidth / 2), CGRectGetHeight(self.view.frame) - buttonAreaHeight, buttonAreaWidth, buttonAreaHeight)];
    [slidingMenuHitTargetAreaView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"menu_popup_button" ofType:@"png"]]];
    UITapGestureRecognizer *tapMenu = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(toggleSlidingMenu)];
    [slidingMenuHitTargetAreaView addGestureRecognizer:tapMenu];
    [slidingMenuHitTargetAreaView setUserInteractionEnabled:YES];
    
    [self.view addSubview:slidingMenuHitTargetAreaView];
}

// Handle opening or closing the sliding menu
-(void)toggleSlidingMenu {
    CGFloat expandedMenuY = CGRectGetHeight(self.view.frame) - CGRectGetHeight(slidingMenuView.frame);
    CGFloat collapsedMenuY = CGRectGetHeight(self.view.frame);
    
    bool isCollapsed = CGRectGetMinY(slidingMenuView.frame) == CGRectGetHeight(self.view.frame);
    
    CGFloat slidingDistanceY = collapsedMenuY - expandedMenuY;
    if (isCollapsed) slidingDistanceY = 0 - slidingDistanceY;
    
    // Slide the whole menu ...
    CGRect slidingMenuViewUpdatedFrame = slidingMenuView.frame;
    slidingMenuViewUpdatedFrame.origin.y += slidingDistanceY;
    
    // ... and the hit area on the button
    CGRect slidingMenuHitTargetAreaViewUpdatedFrame = slidingMenuHitTargetAreaView.frame;
    slidingMenuHitTargetAreaViewUpdatedFrame.origin.y += slidingDistanceY;

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             slidingMenuView.frame = slidingMenuViewUpdatedFrame;
                             slidingMenuHitTargetAreaView.frame = slidingMenuHitTargetAreaViewUpdatedFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}

// Pop a modal with only text
-(HGPModal*)showModal:(NSString*)text {
    HGPModal* modal = [[HGPModal alloc] initWithFrame:CGRectMake(bettingStatusLabel.frame.origin.x - MARGIN_STANDARD, bettingStatusLabel.frame.origin.y, bettingStatusLabel.frame.size.width + (MARGIN_STANDARD * 2), CGRectGetMaxY(betButtonDisplayView.frame) - bettingStatusLabel.frame.origin.y)
                                                 text:text];
    
    [self.view addSubview:modal];
    
    return modal;
}

// Pop a modal with text and a portrait
-(HGPModal*)showModal:(NSString*)characterPortraitImageName text:(NSString*)text {
    HGPModal* modal = [[HGPModal alloc] initWithFrame:CGRectMake(bettingStatusLabel.frame.origin.x, bettingStatusLabel.frame.origin.y, bettingStatusLabel.frame.size.width, CGRectGetMaxY(betButtonDisplayView.frame) - bettingStatusLabel.frame.origin.y)
                                            imageName:characterPortraitImageName
                                                 text:text];
    
    [self.view addSubview:modal];
    
    return modal;
}

-(void)showReplayModal:(bool)allowReplay {
    CGFloat heightOfModal = CGRectGetMaxY(betButtonDisplayView.frame) - bettingStatusLabel.frame.origin.y;
    CGFloat widthOfModal = bettingStatusLabel.frame.size.width;
    
    replayModal = [[HGPModal alloc] initWithFrame:CGRectMake(bettingStatusLabel.frame.origin.x, bettingStatusLabel.frame.origin.y, widthOfModal, heightOfModal)];
    
    if (allowReplay) {
        CGFloat widthOfButton = (widthOfModal - (MARGIN_STANDARD * 3)) / 2;
        
        UIButton* tryAgainButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, (heightOfModal - CHOICE_BUTTON_HEIGHT) / 2, widthOfButton, CHOICE_BUTTON_HEIGHT)];
        [tryAgainButton setTitle:@"Play Another Round" forState:UIControlStateNormal];
        tryAgainButton.titleLabel.font = [UIFont fontForBody];
        [tryAgainButton.titleLabel setNumberOfLines:0];
        [tryAgainButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tryAgainButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [tryAgainButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"talk_card_btn_background" ofType:@"png"]] forState:UIControlStateNormal];
        [tryAgainButton addTarget:self action:@selector(playAnotherRound) forControlEvents:UIControlEventTouchUpInside];
        
        [tryAgainButton setEnabled:allowReplay];
        
        UIButton* quitButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tryAgainButton.frame) + MARGIN_STANDARD, (heightOfModal - CHOICE_BUTTON_HEIGHT) / 2, widthOfButton, CHOICE_BUTTON_HEIGHT)];
        [quitButton setTitle:@"Know When To Quit" forState:UIControlStateNormal];
        [quitButton.titleLabel setNumberOfLines:0];
        quitButton.titleLabel.font = [UIFont fontForBody];
        [quitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [quitButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"talk_card_btn_background" ofType:@"png"]] forState:UIControlStateNormal];
        [quitButton addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
        
        [replayModal addSubview:tryAgainButton];
        [replayModal addSubview:quitButton];
    }
    else {
        CGFloat widthOfButton = (widthOfModal - (MARGIN_STANDARD * 2));
        UIButton* quitButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, (heightOfModal - CHOICE_BUTTON_HEIGHT) / 2, widthOfButton, CHOICE_BUTTON_HEIGHT)];
        [quitButton setTitle:@"This Table’s Dead ... Take a Breather" forState:UIControlStateNormal];
        [quitButton.titleLabel setNumberOfLines:0];
        quitButton.titleLabel.font = [UIFont fontForBody];
        [quitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [quitButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"talk_card_btn_background" ofType:@"png"]] forState:UIControlStateNormal];
        [quitButton addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
        
        [replayModal addSubview:quitButton];
    }
    [self.view addSubview:replayModal];
}

-(void)playAnotherRound {
    [replayModal removeFromSuperview];
    [self resetGame];
}

-(void)quit {
    [replayModal removeFromSuperview];
    [self.delegate gameHasEnded];
    [self removeFromParentViewController];
}

// End the game, keep the player's money, and bounce back to the Main Menu
-(void)leaveTheGameEarly {
    // The player still has to take the hit ...
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    int currentPlayerHoldings = [[self getHumanPlayer] holdings];
    [player setHoldings:currentPlayerHoldings];
    
    // Now end the game
    [self.delegate gameHasEnded];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

// The player is leaving but only wants to bounce back to the Selection screen
-(void)chooseADifferentGame {
    // The player still has to take the hit ...
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    int currentPlayerHoldings = [[self getHumanPlayer] holdings];
    [player setHoldings:currentPlayerHoldings];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(bool)atLeastOneOtherPlayerCanAffordToKeepBetting:(int)moneyRequired {
    for (int i = 1; i < [players count]; i++) {
        if ([players[i] holdings] >= moneyRequired) {
            return true;
        }
    }
    
    return false;
}

-(bool)checkIfBeastIsBeaten:(Player* _Nonnull)p {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    if (!player.isBeastBeaten && p.playerType == PlayerTypeNPC_Beast) {
        // Is the Beast wiped out?
        if (p.holdings <= 0 || p.holdings < [self smallestPossibleBet]) {
            // Welp, the human player just beat the beast. (They still get their money)
            player.isBeastBeaten = true;
            int currentPlayerHoldings = [[self getHumanPlayer] holdings];
            [player setHoldings:currentPlayerHoldings];
            
            [PlayerRecordProvider updatePlayerRecord:player];
            
            // Hide the betting status label and disable the Next button so that the next turn text won't start running
            [bettingStatusLabel setHidden:YES];
            [nextButton setEnabled:NO];
            
            // Trigger an animation
            UIGraphicsBeginImageContext(self.view.frame.size);
            
            UIImageView* regularTableImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
            [regularTableImageView setImage:[Room getPokerTableBackgroundImageForRoom:RoomBootHillSaloon]];
            [regularTableImageView setAlpha:0.0f];
            regularTableImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            regularTableImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.view insertSubview:regularTableImageView belowSubview:cardDisplayView];
            
            // Change the background
            [UIView animateWithDuration:3.0
                                  delay:1.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 // Bring back a regular table background
                                 [regularTableImageView setAlpha:1.0f];
                                 
                                 // Oh yeah, hide all this other random crap
                                 [slidingMenuView setAlpha:0.0f];
                                 [slidingMenuHitTargetAreaView setAlpha:0.0f];
                                 
                                 [playerHoldingsHeaderLabel setAlpha:0.0f];
                                 [playerHoldingsLabel setAlpha:0.0f];
                                 [playerHoldingsBackgroundImageView setAlpha:0.0f];
                                 [potHoldingsHeaderLabel setAlpha:0.0f];
                                 [potHoldingsLabel setAlpha:0.0f];
                                 [potHoldingsBackgroundImageView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished){
                                 CGFloat heightOfModal = (CGRectGetMaxY(betButtonDisplayView.frame) - bettingStatusLabel.frame.origin.y) * 0.66f;
                                 CGFloat widthOfModal = bettingStatusLabel.frame.size.width;
                                 
                                 HGPModal* exitToMenuModal = [[HGPModal alloc] initWithFrame:CGRectMake(bettingStatusLabel.frame.origin.x, bettingStatusLabel.frame.origin.y + (heightOfModal / 6), widthOfModal, heightOfModal)];
                                 
                                 UIButton* exitButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_WIDE * 2, MARGIN_THIN, (widthOfModal - (MARGIN_WIDE * 4)), heightOfModal - (MARGIN_THIN * 2.0f))];
                                 [exitButton setTitle:@"... where’d everybody go?" forState:UIControlStateNormal];
                                 [exitButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"talk_card_btn_background" ofType:@"png"]] forState:UIControlStateNormal];
                                 exitButton.titleLabel.font = [UIFont fontForBody];
                                 [exitButton.titleLabel setNumberOfLines:0];
                                 [exitButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
                                 [exitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                                 [exitButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                                 [exitButton addTarget:self action:@selector(deliverEnding) forControlEvents:UIControlEventTouchUpInside];
                                 
                                 [exitToMenuModal addSubview:exitButton];
                                 
                                 [self.view addSubview:exitToMenuModal];
                                 
                                 
                                 id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                 [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"
                                                                                       action:@"Defeat the Beast"
                                                                                        label:@"Unlock"
                                                                                        value:@1] build]];
                             }];
            
            return true;
        }
    }
    
    return false;
}

// The player beat the Beast - load up the "Ending Scene" character scene
-(void)deliverEnding {
    HGPCharacterSceneViewController* charVc = [[HGPCharacterSceneViewController alloc] init];
    charVc.currentScene = CharacterSceneEnding;
    charVc.delegate = self.delegate;
    [self addChildViewController:charVc];
    [self.view addSubview:charVc.view];
    [charVc didMoveToParentViewController:self];
}

// View the tutorial for the current game
-(void)viewTutorial {
    HGPTutorialViewController* tutorialViewController = [[HGPTutorialViewController alloc] init];
    NSString* gameClass = NSStringFromClass([self class]);
    
    if ([gameClass isEqualToString:@"HGPGameAceyDeuceyViewController"]) tutorialViewController.game = GameAceyDeucey;
    else if ([gameClass isEqualToString:@"HGPGameAnacondaViewController"]) tutorialViewController.game = GameAnaconda;
    else if ([gameClass isEqualToString:@"HGPGameDayBaseBallViewController"]) tutorialViewController.game = GameDayBaseball;
    else if ([gameClass isEqualToString:@"HGPGameFollowTheQueenViewController"]) tutorialViewController.game = GameFollowTheQueen;
    else if ([gameClass isEqualToString:@""]) tutorialViewController.game = GameHighLow;
    

    [self addChildViewController:tutorialViewController];
    [self.view addSubview:tutorialViewController.view];
    [tutorialViewController didMoveToParentViewController:self];
    
    // Close the menu so that it's gone when we get back
    [self toggleSlidingMenu];
}

// Calculates the smallest bet a player could make. If a player can't afford any of these bets, they're out
-(int)smallestPossibleBet {
    int minimumBet = [bets[0] intValue];
    for (int i = 0; i < [bets count]; i++) {
        if (minimumBet > [bets[i] intValue]) minimumBet = [bets[i] intValue];
    }
    
    if (minimumBet > pot) minimumBet = pot;
    
    return minimumBet;
}

#pragma mark UI Helper methods

// Apply our standard styling to a button

-(void)styleButton:(UIButton*)button {
    button.titleLabel.font = [UIFont fontForBody];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    button.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
