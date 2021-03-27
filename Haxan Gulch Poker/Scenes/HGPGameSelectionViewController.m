//
//  HCPGameSelectionViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 9/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPGameSelectionViewController.h"

@interface HGPGameSelectionViewController ()

@end

@implementation HGPGameSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PlayerRecord* player = [PlayerRecordProvider fetchPlayerRecord];
    bool showTutorialPromptModal = (player.highestRoomUnlocked < 1);
    
    // Set the background
    UIImage* backgroundImage = [Room getPokerTableBackgroundImageForRoom:self.currentRoom];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    // Get the dimensions
    int numberOfGames = 3;
    bool showHighLowGame = (self.currentRoom > 0);
    if (showHighLowGame) numberOfGames++;
    
    bool showFollowTheQueenGame = (self.currentRoom > 0);
    if (showFollowTheQueenGame) numberOfGames++;
    
    CGFloat gameButtonWidth = CGRectGetWidth(self.view.frame) * 0.40;
    CGFloat gameButtonHeight = 40.0f;
    CGFloat tutorialButtonHeight = gameButtonHeight - (MARGIN_SUPER_THIN * 2.0f);
    CGFloat tutorialButtonWidth = tutorialButtonHeight * 1.119f;
    CGFloat totalWidthOfButtons = gameButtonWidth + MARGIN_THIN + tutorialButtonWidth;
    CGFloat gameButtonX = (CGRectGetWidth(self.view.frame) - totalWidthOfButtons) / 2.0f;
    CGFloat tutorialButtonX = gameButtonX + gameButtonWidth + MARGIN_THIN;
    CGFloat tutorialButtonYOffset = 3.0f; // This is a magic number but it looks right; the button design is a little off-center vertically because of the shading at the bottom

    CGFloat titleHeight = totalWidthOfButtons * 0.1219f;
    CGFloat titleY = numberOfGames > 4 ? MARGIN_STANDARD : MARGIN_STANDARD * 2.0f;
    CGFloat buttonsVerticalSeparator = (CGRectGetHeight(self.view.frame) - titleHeight - titleY - (gameButtonHeight * numberOfGames) - MARGIN_STANDARD) / (numberOfGames + 1);
    
    // If we're showing the tutorial prompt, tuck up all the other buttons to make room for it
    if (showTutorialPromptModal) buttonsVerticalSeparator -= 15;
    
    // ... and add the elements
    UIImageView* chooseAGameTitleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(gameButtonX, titleY, totalWidthOfButtons, titleHeight - 4.0f)];
    NSString* chooseAGameImagePath = [[NSBundle mainBundle]
                                             pathForResource:@"ChooseAGame"
                                             ofType:@"png"];
    [chooseAGameTitleImageView setImage:[UIImage imageWithContentsOfFile:chooseAGameImagePath]];
    
    UIButton* aceyDeuceyButton = [[UIButton alloc] initWithFrame:CGRectMake(gameButtonX, CGRectGetMaxY(chooseAGameTitleImageView.frame) + buttonsVerticalSeparator, gameButtonWidth, gameButtonHeight)];
    [self setUpGameButton:aceyDeuceyButton title:@"Acey Deucey" tag:GameAceyDeucey];
    
    UIButton* aceyDeuceyTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(tutorialButtonX, CGRectGetMinY(aceyDeuceyButton.frame) + tutorialButtonYOffset, tutorialButtonWidth, tutorialButtonHeight)];
    [self setUpTutorialButton:aceyDeuceyTutorialButton tag:GameAceyDeucey];

    UIButton* anacondaButton = [[UIButton alloc] initWithFrame:CGRectMake(gameButtonX, CGRectGetMaxY(aceyDeuceyButton.frame) + buttonsVerticalSeparator, gameButtonWidth, gameButtonHeight)];
    [self setUpGameButton:anacondaButton title:@"Anaconda" tag:GameAnaconda];
    
    UIButton* anacondaTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(tutorialButtonX, CGRectGetMinY(anacondaButton.frame) + tutorialButtonYOffset, tutorialButtonWidth, tutorialButtonHeight)];
    anacondaTutorialButton.tag = GameAnaconda;
    [self setUpTutorialButton:anacondaTutorialButton tag:GameAnaconda];
    
    UIButton* dayBaseballButton = [[UIButton alloc] initWithFrame:CGRectMake(gameButtonX, CGRectGetMaxY(anacondaButton.frame) + buttonsVerticalSeparator, gameButtonWidth, gameButtonHeight)];
    [self setUpGameButton:dayBaseballButton title:@"Day Baseball" tag:GameDayBaseball];
    
    UIButton* dayBaseballTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(tutorialButtonX, CGRectGetMinY(dayBaseballButton.frame) + tutorialButtonYOffset, tutorialButtonWidth, tutorialButtonHeight)];
    [self setUpTutorialButton:dayBaseballTutorialButton tag:GameDayBaseball];
    
    [self.view addSubview:chooseAGameTitleImageView];
    [self.view addSubview:aceyDeuceyButton];
    [self.view addSubview:anacondaButton];
    [self.view addSubview:dayBaseballButton];
    
    [self.view addSubview:aceyDeuceyTutorialButton];
    [self.view addSubview:anacondaTutorialButton];
    [self.view addSubview:dayBaseballTutorialButton];
    
    ////////////////////////////////////////////////////////////////
    // Optional games
    CGFloat buttonY = CGRectGetMaxY(dayBaseballButton.frame) + buttonsVerticalSeparator;
    
    if (showHighLowGame) {
        UIButton* highLowGameButton = [[UIButton alloc] initWithFrame:CGRectMake(gameButtonX, buttonY, gameButtonWidth, gameButtonHeight)];
        [self setUpGameButton:highLowGameButton title:@"High-Low Game" tag:GameHighLow];
        
        UIButton* highLowTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(tutorialButtonX, CGRectGetMinY(highLowGameButton.frame) + tutorialButtonYOffset, tutorialButtonWidth, tutorialButtonHeight)];
        [self setUpTutorialButton:highLowTutorialButton tag:GameHighLow];
        [self.view addSubview:highLowGameButton];
        [self.view addSubview:highLowTutorialButton];
        
        buttonY = CGRectGetMaxY(highLowGameButton.frame) + buttonsVerticalSeparator;
    }
    
    if (showFollowTheQueenGame) {
        UIButton* followTheQueenGameButton = [[UIButton alloc] initWithFrame:CGRectMake(gameButtonX, buttonY, gameButtonWidth, gameButtonHeight)];
        [self setUpGameButton:followTheQueenGameButton title:@"Follow the Queen" tag:GameFollowTheQueen];
        
        UIButton* followTheQueenTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(tutorialButtonX, CGRectGetMinY(followTheQueenGameButton.frame) + tutorialButtonYOffset, tutorialButtonWidth, tutorialButtonHeight)];
        [self setUpTutorialButton:followTheQueenTutorialButton tag:GameFollowTheQueen];
        [self.view addSubview:followTheQueenGameButton];
        [self.view addSubview:followTheQueenTutorialButton];
        
        buttonY = CGRectGetMaxY(followTheQueenGameButton.frame) + buttonsVerticalSeparator;
    }
    
    // Add the sliding menu
    [self displaySlidingMenu];
    
    // If the player is new, remind them how to find the tutorial
    if (showTutorialPromptModal)
    {
        CGFloat modalHeight = 90.0f;
        HGPModal* tutorialPrompt = [[HGPModal alloc] initWithFrame:CGRectMake(MARGIN_WIDE, CGRectGetHeight(self.view.frame) - modalHeight - MARGIN_THIN, CGRectGetWidth(self.view.frame) - (MARGIN_WIDE * 2), modalHeight)  imageName:@"char_bum" text:@"Not sure how to play a game? Tap that little “?” button for a free lesson!"];
        [self.view addSubview:tutorialPrompt];
    }
}

-(void)setUpGameButton:(UIButton*)button title:(NSString*)title tag:(NSInteger)tag {
    NSString* mainButtonBackgroundImagePath = [[NSBundle mainBundle]
                                               pathForResource: @"golden_btn"
                                               ofType:@"png"];
    [button setBackgroundImage:[UIImage imageWithContentsOfFile:mainButtonBackgroundImagePath] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontForButton]];
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = tag;
    
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 4.0f, 0.0f)];
    
    [button addTarget:self action:@selector(startGame:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setUpTutorialButton:(UIButton*)button tag:(NSInteger)tag {
    NSString* tutorialButtonBackgroundImagePath = [[NSBundle mainBundle]
                                                   pathForResource: @"SquareButton"
                                                   ofType:@"png"];
    [button setTitle:@"?" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithContentsOfFile:tutorialButtonBackgroundImagePath] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontForBody]];
    button.tag = tag;
    [button addTarget:self action:@selector(startTutorial:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Game Selection"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)startGame:(id)sender {
    UIButton* gameButton = (UIButton*)sender;
    HGPBaseGameViewController* gameViewController;
    
    switch(gameButton.tag) {
        case GameAnaconda: {
            gameViewController = [[HGPGameAnacondaViewController alloc] init];
            break;
        }
        case GameDayBaseball: {
            gameViewController = [[HGPGameDayBaseBallViewController alloc] init];
            break;
        }
        case GameHighLow: {
            gameViewController = [[HGPGameHighLowViewController alloc] init];
            break;
        }
        case GameFollowTheQueen: {
            gameViewController = [[HGPGameFollowTheQueenViewController alloc] init];
            break;
        }
        case GameAceyDeucey:
        default: {
            gameViewController = [[HGPGameAceyDeuceyViewController alloc] init];
            break;
        }
    }
    
    gameViewController.currentRoom = self.currentRoom;
    gameViewController.delegate = self;
    
    [self addChildViewController:gameViewController];
    [self.view addSubview:gameViewController.view];
    [gameViewController didMoveToParentViewController:self];
}

-(void)startTutorial:(id)sender {
    UIButton* tutorialButton = (UIButton*)sender;
    
    HGPTutorialViewController* tutorialViewController = [[HGPTutorialViewController alloc] init];

    // Initialize the tutorial with the right game
    switch(tutorialButton.tag) {
        case GameAnaconda:
            tutorialViewController.game = GameAnaconda;
            break;
        case GameDayBaseball:
            tutorialViewController.game = GameDayBaseball;
            break;
        case GameHighLow:
            tutorialViewController.game = GameHighLow;
            break;
        case GameFollowTheQueen:
            tutorialViewController.game = GameFollowTheQueen;
            break;
        default:
            tutorialViewController.game = GameAceyDeucey;
            break;
    }

    [self addChildViewController:tutorialViewController];
    [self.view addSubview:tutorialViewController.view];
    [tutorialViewController didMoveToParentViewController:self];
}

#pragma mark Modals

// Handle the sliding menu
-(void)displaySlidingMenu {
    // This reference rect is based on the betButtonDisplayView from the game screen. There's probably a better way to do this ...
    // TODO: Move this into its own view
    CGFloat buttonBarHeight = CGRectGetWidth(self.view.frame) * 0.075f;
    CGFloat buttonBarTopMargin = buttonBarHeight * 0.0972f;
    CGRect menuReferenceArea = CGRectMake(MARGIN_STANDARD, CGRectGetHeight(self.view.frame) - buttonBarHeight + buttonBarTopMargin, self.view.frame.size.width - MARGIN_STANDARD * 2, buttonBarHeight  - buttonBarTopMargin);
    
    CGFloat buttonAreaHeight = CGRectGetHeight(menuReferenceArea);
    CGFloat buttonAreaWidth = CGRectGetHeight(menuReferenceArea) * 1.44f;
    
    int numberOfButtons = 1;
    CGFloat menuSliderAreaWidth = buttonAreaWidth * 4.3077;
    CGFloat menuSliderAreaHeight = (LABEL_HEIGHT * numberOfButtons) + (MARGIN_STANDARD * (numberOfButtons + 1));
    
    // The area to the left of the button is
    slidingMenuView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(menuReferenceArea) - menuSliderAreaWidth - (buttonAreaWidth / 2), CGRectGetHeight(self.view.frame), menuSliderAreaWidth, menuSliderAreaHeight)];
    
    UIImageView* slidingMenuBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, menuSliderAreaWidth, menuSliderAreaHeight)];
    [slidingMenuBackgroundImageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"menu_popup" ofType:@"png"]]];
    
    [slidingMenuView addSubview:slidingMenuBackgroundImageView];
    
    CGFloat buttonY = MARGIN_STANDARD;
    
    UIButton* mainMenuButton = [[UIButton alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, buttonY, menuSliderAreaWidth - (MARGIN_STANDARD * 2), LABEL_HEIGHT)];
    mainMenuButton.titleLabel.font = [UIFont fontForBody];
    [mainMenuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [mainMenuButton setTitle:@"Back to Main Menu" forState:UIControlStateNormal];
    [mainMenuButton addTarget:self action:@selector(gameHasEnded) forControlEvents:UIControlEventTouchUpInside];
    [slidingMenuView addSubview:mainMenuButton];
    
    [slidingMenuView setUserInteractionEnabled:YES];
    
    [self.view addSubview:slidingMenuView];
    
    // ... and then we separately create and add the hit area so that we can still tap the button section
    slidingMenuHitTargetAreaView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(menuReferenceArea) - buttonAreaWidth - (buttonAreaWidth / 2), CGRectGetHeight(self.view.frame) - buttonAreaHeight, buttonAreaWidth, buttonAreaHeight)];
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

#pragma mark Delegate methods

- (void)gameHasEnded {
    [self.delegate gameHasEnded];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)justBeatGame {
    [self.delegate justBeatGame];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)unlockTheBeast {
    [self.delegate unlockTheBeast];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
