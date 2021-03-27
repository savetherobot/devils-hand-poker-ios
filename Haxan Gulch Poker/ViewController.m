//
//  ViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

/**
 The opening ViewController will act as our title screen and menu 
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    
    // TEST CODE
//    player.holdings = 7000;
//    player.isBeastBeaten = false;
//    player.highestRoomUnlocked = 4;
//    [PlayerRecordProvider updatePlayerRecord:player];

    // Refresh the holdings
    playerHoldings = player.holdings;
    
    NSString* backgroundImagePath = [[NSBundle mainBundle]
                                     pathForResource:@"A-D-K_DarkAlley_Background"
                                     ofType:@"png"];
    UIImage* backgroundImage = [UIImage imageWithContentsOfFile:backgroundImagePath];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    CGFloat centerX = CGRectGetWidth(self.view.frame) / 2;
    CGFloat centerY = CGRectGetHeight(self.view.frame) / 2;
    CGFloat frameY = centerY * 0.4;
    CGFloat frameWidth = CGRectGetWidth(self.view.frame) * 0.4;
    CGFloat imageSize = frameWidth * 0.646;
    CGFloat frameHeight = frameWidth * .814;
    CGFloat labelHeight = LABEL_HEIGHT * 1.5;
    CGFloat labelWidth = frameWidth;
    CGFloat labelY = frameY + (frameHeight * 0.823);
    
    // Put the betting bar on top as a frame
    UIImageView* buttonBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 0.075f)];
    
    NSString* buttonBackgroundImagePath = [[NSBundle mainBundle]
                                           pathForResource:@"BetBar"
                                           ofType:@"png"];
    UIImage* buttonBackgroundImage = [UIImage imageWithContentsOfFile:buttonBackgroundImagePath];
    UIImage* flippedButtonBackgroundImage = [UIImage imageWithCGImage:buttonBackgroundImage.CGImage
                                                                scale:buttonBackgroundImage.scale
                                                          orientation:UIImageOrientationDownMirrored];
    
    [buttonBackground setImage:flippedButtonBackgroundImage];
    [self.view addSubview:buttonBackground];
    
    // Label for holdings
    self.holdingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, MARGIN_SUPER_THIN, CGRectGetWidth(self.view.frame), LABEL_HEIGHT * 1.5f)];
    [self.holdingsLabel setFont:[UIFont fontForLargeLabel]];
    [self.holdingsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.holdingsLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.holdingsLabel];
    
    // Set up center room selection control
    UIImageView* roomSelectorFrame = [[UIImageView alloc] initWithFrame:CGRectMake(centerX - (frameWidth / 2), frameY, frameWidth, frameHeight)];
    [roomSelectorFrame setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"game_selection_frame" ofType:@"png"]]];
    
    roomSelectorBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(centerX - (frameWidth / 2), frameY, frameWidth - MARGIN_SUPER_THIN, frameHeight - MARGIN_SUPER_THIN)];  // Trim the height and width so there's so spillover past the frame of the selector
    
    charPortraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(centerX - (imageSize / 2), frameY, imageSize, imageSize)];
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(startGame)];
    [charPortraitImageView addGestureRecognizer:tapImage];
    [charPortraitImageView setUserInteractionEnabled:YES];
    
    roomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(centerX - (labelWidth / 2), labelY, labelWidth, labelHeight)];
    [roomNameLabel setTextAlignment:NSTextAlignmentCenter];
    roomNameLabel.font = [UIFont fontForLargeLabel];
    UITapGestureRecognizer *tapLabel = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(startGame)];
    [roomNameLabel addGestureRecognizer:tapLabel];
    [roomNameLabel setUserInteractionEnabled:YES];
    
    anteButton = [[UIButton alloc] initWithFrame:CGRectMake(centerX - (labelWidth / 3), CGRectGetMaxY(roomNameLabel.frame) + MARGIN_STANDARD, labelWidth / 1.5f, labelHeight)];
    [anteButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ante_label_background" ofType:@"png"]] forState:UIControlStateNormal];
    
    [anteButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ante_label_disabled_background" ofType:@"png"]] forState:UIControlStateDisabled];
    anteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [anteButton.titleLabel setFont:[UIFont fontForLargeLabel]];
    [anteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [anteButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [anteButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    
    // Set up the selector in the middle
    leftButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(roomSelectorFrame.frame) - 45.0f, self.view.frame.size.height / 2 - 25.0f, 30.0f, 67.89f)];    //  95 x 215
    [leftButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"swipe_left" ofType:@"png"]] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(prevRoom) forControlEvents:UIControlEventTouchUpInside];
    
    rightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(roomSelectorFrame.frame) + 15.0f, self.view.frame.size.height / 2 - 25.0f, 30.0f, 67.89f)];
    [rightButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                            pathForResource:@"swipe_right"
                                                            ofType:@"png"]] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(nextRoom) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:roomSelectorBackgroundImageView];
    [self.view addSubview:charPortraitImageView];
    [self.view addSubview:roomSelectorFrame];
    [self.view addSubview:roomNameLabel];
    [self.view addSubview:anteButton];
    [self.view addSubview:leftButton];
    [self.view addSubview:rightButton];
    
    // Create the rooms
    NSMutableArray* roomArray = [[NSMutableArray alloc] init];
    [roomArray addObjectsFromArray:@[[[Room alloc] init:@"The Dark Alley" charPortrait:@"char_bum" minimumHoldings:10 roomIdentifier:RoomDarkAlley],
                                     [[Room alloc] init:@"The Widow Precious" charPortrait:@"char_widow" minimumHoldings:50 roomIdentifier:RoomWidowPrecious],
                                     [[Room alloc] init:@"The Boot Heel Saloon" charPortrait:@"char_barkeep" minimumHoldings:300 roomIdentifier:RoomBootHillSaloon],
                                     [[Room alloc] init:@"The Mayor’s Parlor" charPortrait:@"char_mayor" minimumHoldings:750 roomIdentifier:RoomMayorsDen]]];
    
    // If the player has unlocked the Beast room, add that to the selector
    if (player.highestRoomUnlocked == 4) {
        [roomArray addObject:[[Room alloc] init:@"The Devil’s Table" charPortrait:@"char_devil" minimumHoldings:5000 roomIdentifier:RoomDevilsLair]];
    }
    
    rooms = [roomArray copy];
    
    // Set up the room selector and display the highest room the player has unlocked
    roomIndex = player.isBeastBeaten ? 0 : player.highestRoomUnlocked;
    
    // Add the job indicator
    oddJobsView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, CGRectGetHeight(self.view.frame) - 90.0f, 80.0f, 90.0f)];
    btnOddJobs = [[UIButton alloc] initWithFrame:CGRectMake(7.0f, 0.0f, 66.0f, 67.2f)];
     [btnOddJobs setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"odd_jobs" ofType:@"png"]] forState:UIControlStateNormal];
    [btnOddJobs addTarget:self action:@selector(startCharacterScene:) forControlEvents:UIControlEventTouchUpInside];
    [oddJobsView addSubview:btnOddJobs];

    UILabel* oddJobsCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(btnOddJobs.frame), CGRectGetWidth(oddJobsView.frame), 18.0f)];
    [oddJobsCaptionLabel setFont:[UIFont fontForBody]];
    [oddJobsCaptionLabel setTextAlignment:NSTextAlignmentCenter];
    [oddJobsCaptionLabel setTextColor:[UIColor whiteColor]];
    [oddJobsCaptionLabel setText:@"ODD JOBS"];
    [oddJobsView addSubview:oddJobsCaptionLabel];
    
    [self.view addSubview:oddJobsView];
    [self updateOddJobsButtonStateAndDestination];

    btnCredits = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 60.0f, CGRectGetHeight(self.view.frame) - 40.0f, 56.0f, 40.0f)];
     [btnCredits setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"BetBarButton" ofType:@"png"]] forState:UIControlStateNormal];
    [btnCredits addTarget:self action:@selector(showCredits) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCredits];
    
    CGFloat creditsImageHeight = CGRectGetHeight(btnCredits.frame) * 0.65;
    CGFloat creditsImageWidth = creditsImageHeight * 0.83;
    CGFloat creditsImageY = (CGRectGetHeight(btnCredits.frame) * 0.22f);
    
    UIImageView* creditsImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(btnCredits.frame) - creditsImageWidth) / 2, creditsImageY, creditsImageWidth, creditsImageHeight)];
     [creditsImageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                                  pathForResource:@"Spade"
                                                                  ofType:@"png"]]];
    [btnCredits addSubview:creditsImageView];

    // Add an observer to hide the Unlock Game modal if a purchase is made or restored
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameUnlocked) name:kHGPGameUnlocked object:nil];
    
    // Refresh the display to populate the holdings
    [self refreshDisplay:YES];
    
    // ... and finally, load the logo screen over all of it
    [self loadLogoScreen];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Menu"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark Logo screen

// Display a branding screen immediately after the launch storyboard, and then segue to the main menu
-(void)loadLogoScreen {
    UIView* companyLaunchScreen = [[UIView alloc] initWithFrame:self.view.frame];
    [companyLaunchScreen setBackgroundColor:[UIColor colorWithRed:33 / 255.0f
                                                            green:21 / 255.0f
                                                             blue:45 / 255.0f
                                                            alpha:1.0]];
    
    CGFloat logoImageHeight = CGRectGetHeight(self.view.frame) - (MARGIN_WIDE * 2);
    CGFloat logoImageWidth = logoImageHeight * 0.407f;
    UIImageView* logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - (logoImageWidth / 2), MARGIN_WIDE, logoImageWidth, logoImageHeight)];
    [logoImageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                              pathForResource:@"RTF_Logo_transparent"
                                                              ofType:@"png"]]];
    [companyLaunchScreen addSubview:logoImageView];
    
    [self.view addSubview:companyLaunchScreen];
    
    // Hide the company launch screen
    [UIView animateWithDuration:1.0
                          delay:3.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [companyLaunchScreen setAlpha:0.0f];
                     }
                     completion:^(BOOL finished){
                         [companyLaunchScreen removeFromSuperview];
                     }];
}

#pragma mark Room Selector control

-(void)populateRoomDisplay {
    // Set the correct disabled state for the buttons
    [leftButton setHidden:roomIndex <= 0];
    [rightButton setHidden:roomIndex >= ([rooms count] - 1)];
    
    Room* r = rooms[roomIndex];
    bool isRoomEnabled = r.minimumHoldings <= playerHoldings;
    
    // Populate the room description and image
    [roomSelectorBackgroundImageView setImage:[r getPokerTableBackgroundImage]];
    
    NSString* characterPortraitName = [r charPortraitImageName];
    if (!isRoomEnabled) characterPortraitName = [NSString stringWithFormat:@"%@_locked", characterPortraitName];
    
    NSString* characterPortraitImagePath = [[NSBundle mainBundle]
                                            pathForResource:characterPortraitName
                                            ofType:@"png"];
    [charPortraitImageView setImage:[UIImage imageWithContentsOfFile:characterPortraitImagePath]];
    [roomNameLabel setText:[r name]];
    [anteButton setTitle:[NSString stringWithFormat:@"Buy In $%d", [r minimumHoldings]] forState:UIControlStateNormal];
    
    // Disable the ante label background if the user can't get in
    [anteButton setEnabled:isRoomEnabled];
}

-(void)prevRoom {
    roomIndex--;
    [self populateRoomDisplay];
}

-(void)nextRoom {
    // The player can't go to the next room unless they unlocked the game! Only 99 cents! Such a bargain!
    if (![PlayerRecordProvider isGameUnlocked]) {
        unlockGameModal = [[HGPDialogCard alloc] initWithFrame:CGRectMake(0.0f, MARGIN_SUPER_THIN, self.view.frame.size.width, self.view.frame.size.height - (MARGIN_SUPER_THIN * 2)) portraitImageName:@"char_bum" text:@"Hold on there! I’m itchin’ to show you the rest of town, but first, you have unlock the game! For just 99 pennies, you get more rooms, higher stakes, and a fourth card game!" choices:@[@"Unlock The Game! ($0.99)", @"Restore Your Purchase", @"Nope, I’m Fine Out Here"]];
        unlockGameModal.delegate = self;
        
        [self.view addSubview:unlockGameModal];
        [self.holdingsLabel setHidden:YES];
    }
    else {
        roomIndex++;
        [self populateRoomDisplay];
    }
}

// A delegate method from SceneDelegate that hooks up to our HGPDialogCard
-(void)choiceSelected:(int)choiceIndex {
    [self.holdingsLabel setHidden:NO];
    
    // Start the process of unlocking the game
    if (choiceIndex == 0) {
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]).iapProvider purchaseUnlockGame];
        [unlockGameModal removeFromSuperview];
    }
    // Or, force it to restore purchases (this happens in the background already but, if it hasn't been completed, the user may not realize it)
    else if (choiceIndex == 1) {
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]).iapProvider restorePurchasesOnDemand];
        [unlockGameModal removeFromSuperview];
    }
    else {
        [unlockGameModal removeFromSuperview];
    }
}

// Method that is called when we detect that the game has been unlocked, to get rid of the unlock game modal and restore the holdings (if necessary)
-(void)gameUnlocked {
    [self.holdingsLabel setHidden:NO];
    if (unlockGameModal) [unlockGameModal removeFromSuperview];
}

#pragma mark Navigation

- (void)startGame {
    Room* r = rooms[roomIndex];
    if (r.minimumHoldings > playerHoldings) {
        return;
    }
    
    // If the user has never been in this room before, update their player record
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    
    if (player) {
        if (player.highestRoomUnlocked < roomIndex) {
            [PlayerRecordProvider updateHighestRoomUnlocked:roomIndex];
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Game"
                                                                  action:[NSString stringWithFormat:@"Unlocked %@", r.name]
                                                                   label:@"Unlock"
                                                                   value:@1] build]];
        }
    }
    
    // Send the user to the intro screen, and pass along the identifier of the room they selected
    HGPGameIntroViewController* introVc = [[HGPGameIntroViewController alloc] init];
    introVc.currentRoom = roomIndex;
    introVc.delegate = self;
    [self addChildViewController:introVc];
    [self.view addSubview:introVc.view];
    [introVc didMoveToParentViewController:self];
}

- (void)startCharacterScene:(UIButton*)button {
    HGPCharacterSceneViewController* charVc = [[HGPCharacterSceneViewController alloc] init];
    charVc.currentScene = button.tag;
    charVc.delegate = self;
    [self addChildViewController:charVc];
    [self.view addSubview:charVc.view];
    [charVc didMoveToParentViewController:self];
}

- (void)showCredits {
    HGPCreditsViewController* creditsVc = [[HGPCreditsViewController alloc] init];
    [self addChildViewController:creditsVc];
    [self.view addSubview:creditsVc.view];
    [creditsVc didMoveToParentViewController:self];
}

- (void)refreshDisplay:(bool)restartMusic {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    
    // Refresh the holdings label
    playerHoldings = player.holdings;
    self.holdingsLabel.text = [NSString stringWithFormat:@"You’re Holding $%d", playerHoldings];
    
    [self updateOddJobsButtonStateAndDestination];
    
    if (!oddJobsView.isHidden) {
        oddJobsModal = [[HGPModal alloc] initWithFrame:CGRectMake(CGRectGetMaxX(oddJobsView.frame) + MARGIN_STANDARD, CGRectGetMinY(oddJobsView.frame), CGRectGetMaxX(btnCredits.frame) - CGRectGetMaxX(oddJobsView.frame) - (MARGIN_STANDARD * 2), CGRectGetHeight(oddJobsView.frame)) imageName:@"char_bum" text:@"Need money? I bet someone in town can put ya to work. Tap ‘Odd Jobs’ and cross yer fingers."];
        [self.view addSubview:oddJobsModal];
    }
    else {
        // Make sure the modal is gone
        if (oddJobsModal) {
            [oddJobsModal removeFromSuperview];
        }
    }
    
    //////////////////////////////////////////////////////////////////////
    // Play some music
    if (restartMusic) {
        NSError* error;
        NSString* mp3Name;
        switch(player.highestRoomUnlocked) {
            case 1:
                mp3Name = @"La_Paloma";
                break;
            case 2:
                mp3Name = @"North_Wind";
                break;
            case 3:
                mp3Name = @"Spanish_Dance";
                break;
            case 4:
                mp3Name = @"Arabesque";
                break;
            default:
                mp3Name = @"Moonlight_Memories";
                break;
        }
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:mp3Name
                                             ofType:@"mp3"]];
        audioPlayer = [[AVAudioPlayer alloc]
                       initWithContentsOfURL:url
                       error:&error];
        
        if (error) {
            [CrashlyticsKit recordError:error];
        } else {
            [audioPlayer setVolume:1];
            [audioPlayer prepareToPlay];
            [audioPlayer play];
        }
    }
    
    // Update the room display (its disabled state may have updated)
    [self populateRoomDisplay];
}

// The player just beat the game; kick them back to the first room
-(void)justBeatGame {
    roomIndex = 0;
    [self refreshDisplay:YES];
}

// A delegate method called when it's time to unlock the Beast's room
-(void)unlockTheBeast {
    // Add the room
    if ([rooms count] == 4) {
        NSMutableArray* updatedRooms = [[NSMutableArray alloc] initWithArray:rooms];
        [updatedRooms addObject:[[Room alloc] init:@"The Devil’s Table" charPortrait:@"char_devil" minimumHoldings:5000 roomIdentifier:RoomDevilsLair]];
         rooms = [updatedRooms copy];
    }
    
    roomIndex = 4;
    
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    player.highestRoomUnlocked = 4;
    [PlayerRecordProvider updatePlayerRecord:player];
    
    [self refreshDisplay:YES];
}

-(void)updateOddJobsButtonStateAndDestination {
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];

    // Only show the odd jobs view if the player is broke. They should always be able to afford the first three, and they should get a leg up of $250 for the fourth room
    if (player.highestRoomUnlocked < 3) {
        [oddJobsView setHidden:(playerHoldings >= rooms[player.highestRoomUnlocked].minimumHoldings)];
    }
    else {
        [oddJobsView setHidden:(playerHoldings >= 250)];
    }
    
    // The odd job they get depends on how far up in the rooms they've reached; that way, they don't have to work their way all the way up from the bottom
    CharacterScene scene;
    
    switch(player.highestRoomUnlocked)
    {
        case 0:
            scene = CharacterSceneHorseStables;
            break;
        case 1:
            scene = CharacterSceneHotel;
            break;
        case 2:
            scene = CharacterSceneFishingHole;
            break;
        default:
            scene = CharacterSceneChurch;
            break;
    }
    
    
    // Uncomment this to test a scene
    //[oddJobsView setHidden:NO];
    //scene = CharacterSceneChurch;
 
    btnOddJobs.tag = scene;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)endMusic {
    if (audioPlayer) {
        [audioPlayer setVolume:0 fadeDuration:3.0f];
    }
}


@end
