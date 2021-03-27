//
//  HGPCharacterSceneViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/15/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPCharacterSceneViewController.h"

@interface HGPCharacterSceneViewController ()

@end

@implementation HGPCharacterSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    sceneIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Character Scene"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set up the background
    UIImage* backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                                 pathForResource:@"A-D-K_DarkAlley_Background"
                                                                 ofType:@"png"]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    // ... and then the dialog card
    [self loadScene:sceneIndex];
}

- (void)choiceSelected:(int)choiceIndex {
    switch(self.currentScene) {
        case CharacterSceneHorseStables: {
            [self returnToMenu];
            break;
        }
        case CharacterSceneHotel: {
            [self returnToMenu];
            break;
        }
        case CharacterSceneFishingHole: {
            switch(sceneIndex) {
                    // Opening screen
                case 0:
                    switch(choiceIndex) {
                        case 0:
                            // Load the next scene
                            [self loadScene:++sceneIndex];
                            break;
                        case 1:
                            [self returnToMenu];
                            break;
                    }
                    break;
                    // "You tried fishing" screen
                case 1:
                    [self returnToMenu];
                    break;
            }
            break;
        }
        case CharacterSceneChurch: {
            switch(sceneIndex) {
                    // Opening screen
                case 0:
                    switch(choiceIndex) {
                        case 0:
                            sceneIndex = 1;
                            // Load the next scene
                            [self loadScene:sceneIndex];
                            break;
                        case 1:
                            sceneIndex = 2;
                            [self loadScene:sceneIndex];
                            break;
                    }
                    break;
                case 1:
                    [self returnToMenu];
                    break;
                case 2:
                    [self returnToMenu];
                    break;
            }
            break;
        }
        case CharacterSceneEnding: {
            switch(sceneIndex) {
                case 0:
                    sceneIndex = 1;
                    [self loadScene:sceneIndex];
                    break;
                case 1:
                    sceneIndex = 2;
                    [self loadScene:sceneIndex];
                    break;
                case 2:
                    sceneIndex = 3;
                    [self loadScene:sceneIndex];
                    break;
                case 3:
                    [self returnToMenu];
                    break;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadScene:(int)index {
    if (self.dialogCard) [self.dialogCard removeFromSuperview];
    CGRect dialogCardFrame = CGRectMake(self.view.frame.size.width * 0.05f, self.view.frame.size.height * 0.05f, self.view.frame.size.width * 0.9f, self.view.frame.size.height * 0.9f);
    
    NSString* scenePortraitImageName;
    NSString* sceneText;
    NSArray<NSString*>* sceneChoices;
    
    // TODO: Too many magic numbers with the amounts you can win ...
    
    switch(self.currentScene) {
        case CharacterSceneHorseStables: {
            scenePortraitImageName = @"char_barkeep";
            sceneText = @"The barkeep pays you $10 to muck out the stables. Looking around, you can’t see the horses, but they left plenty to clean up.\n\nThe job takes all day. It’s dirty work, but honest.";
            sceneChoices = @[@"BACK TO THE TABLES"];
            
            // Player makes $10
            PlayerRecord* playerRecord = [PlayerRecordProvider fetchPlayerRecord];
            [playerRecord setHoldings:[playerRecord holdings] + 10];
            [PlayerRecordProvider updatePlayerRecord:playerRecord];
            break;
        }
        case CharacterSceneHotel: {
            scenePortraitImageName = @"char_widow";
            sceneText = @"Widow Precious sets you to cleaning every room in the hotel. You can’t help but notice that none of the beds looks slept in, and cobwebs fill every dresser.\n\nIn one empty room, you find $50 sitting neatly on the dresser.";
            sceneChoices = @[@"BACK TO THE TABLES"];
            
            // Player makes $50
            PlayerRecord* playerRecord = [PlayerRecordProvider fetchPlayerRecord];
            [playerRecord setHoldings:[playerRecord holdings] + 50];
            [PlayerRecordProvider updatePlayerRecord:playerRecord];
            break;
        }
        case CharacterSceneFishingHole: {
            switch(index) {
                case 0:
                    scenePortraitImageName = @"char_bum";
                    sceneText = @"The town derelict leads you to a spot just outside of town. Sheltered by trees is a fishing hole, marked by cigar butts, empty bottles and the leftover carcasses of a few unlucky fish.";
                    sceneChoices = @[@"SEE HOW THEY'RE BITING", @"HEAD BACK TO TOWN"];
                    break;
                case 1:
                    scenePortraitImageName = @"char_bum";
                    sceneText = @"You fish for a while and get nothing to eat. But you do land something interesting: a wallet holding $300 in the local scrip ... soggy, but good enough for betting.";
                    sceneChoices = @[@"HEAD BACK TO TOWN"];
                    
                    PlayerRecord* playerRecord = [PlayerRecordProvider fetchPlayerRecord];
                    [playerRecord setHoldings:[playerRecord holdings] + 300];
                    [PlayerRecordProvider updatePlayerRecord:playerRecord];
                    break;
            }
            break;
        }
        case CharacterSceneChurch: {
            PlayerRecord* playerRecord = [PlayerRecordProvider fetchPlayerRecord];
            switch(index) {
                case 0:
                    scenePortraitImageName = @"char_mayor";
                    sceneText = @"The ramshackle church that faces the square needs some attention. You unboard the front door and get to work.";
                    sceneChoices = @[@"CLIMB THE STEEPLE", @"CLEAN THE BASEMENT"];
                    break;
                case 1: {
                    int reward = 720 + arc4random_uniform(43);
                    scenePortraitImageName = @"char_mayor";
                     sceneText = [NSString stringWithFormat:@"High up in the steeple, you get to work on the bell. The hours pass as you polish it to a shine. The view takes your breath away, the mountains spreading out far below you. You cling to the railing on your way down.\n\nAn envelope waits for you on the steps, with $%d inside.", reward];
                    sceneChoices = @[@"BACK TO THE TABLES"];
                    
                    [playerRecord setHoldings:[playerRecord holdings] + reward];
                    [PlayerRecordProvider updatePlayerRecord:playerRecord];
                    break;
                }
                case 2: {
                    int reward = 720 + arc4random_uniform(74);
                    scenePortraitImageName = @"char_mayor";
                    sceneText = [NSString stringWithFormat:@"You do your best to clean up the basement. The light is poor, and the shadows have minds of their own. And those skeletons in the corner look a little too familiar.\n\nWhen you’re done, you find $%d waiting for you on the collection plate.", reward];
                    sceneChoices = @[@"BACK TO THE TABLES"];
                    
                    [playerRecord setHoldings:[playerRecord holdings] + reward];
                    [PlayerRecordProvider updatePlayerRecord:playerRecord];
                    break;
                }
            }
            break;
        }
        case CharacterSceneEnding: {
            switch(index) {
                case 0:
                    scenePortraitImageName = @"";
                    sceneText = @"As the Devil gives up the last of his money, he bellows in anger, a roar so loud it threatens to knock down the walls.";
                    sceneChoices = @[@"GRAB THE MONEY AND GO"];
                    break;
                case 1:
                    scenePortraitImageName = @"";
                    sceneText = @"The hall’s a blur as you stumble out of the room and down the steps. Minutes later you break from a daze and find yourself standing at the edge of town. You want to look back, but your eyes hurt at the notion.";
                    sceneChoices = @[@"LOOK BACK"];
                    break;
                case 2:
                    scenePortraitImageName = @"";
                    sceneText = @"The main drag is winding down; the lights in the windows flicker and dim, and the shadows are going still. And the people of town ... whatever the cause, whatever the curse - they had someone to save ‘em from the infinite, and from the judgment on their souls.";
                    sceneChoices = @[@"AIN’T BROKE YET ..."];
                    break;
                case 3:
                    scenePortraitImageName = @"";
                    sceneText = @"Walk away now, and what’ll become of them?\n\nWho’s gonna look after them ... if it ain't you?";
                    sceneChoices = @[@"... ONE MORE GAME?"];
                    break;
            }
            break;
        }
    }
    
    if (scenePortraitImageName && [scenePortraitImageName length] > 0) {
        self.dialogCard = [[HGPDialogCard alloc] initWithFrame:dialogCardFrame portraitImageName:scenePortraitImageName text:sceneText choices:sceneChoices];
    }
    else {
        self.dialogCard = [[HGPDialogCard alloc] initWithFrame:dialogCardFrame text:sceneText choices:sceneChoices];
    }
    self.dialogCard.delegate = self;
    [self.view addSubview:self.dialogCard];
}

- (void)returnToMenu {
    if (self.currentScene == CharacterSceneEnding) {
        // Go all the way back to the main menu
        [self.delegate justBeatGame];
    }
    else {
        [self.delegate refreshDisplay:NO];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

@end
