//
//  GameIntroViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/6/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPGameIntroViewController.h"

@interface HGPGameIntroViewController ()

@end

@implementation HGPGameIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    switch(self.currentRoom) {
        case RoomDarkAlley:
        {
            backgroundImageName = @"A-D-K_DarkAlley_Background";
            titleTextImageName = @"Title_DarkAlley";
            portraitImageName = @"char_bum";
            introText = @"Hey there! Wakey wakey! Looks like you got a little lost. Ain’t no place here for decent folks. I can get you out, but ... how about a friendly game of cards, first?";
            break;
        }
        case RoomWidowPrecious: {
            backgroundImageName = @"A-D-K_DarkAlley_Background";
            titleTextImageName = @"Title_Widow";
            portraitImageName = @"char_widow";
            introText = @"Oh, here’s some rough trade! Girls, I do declare this one will take our every last dollar. But first, can you share a little news? We haven’t had company to entertain in oh so, so long ...";
            break;
        }
        case RoomBootHillSaloon: {
            backgroundImageName = @"A-D-K_DarkAlley_Background";
            titleTextImageName = @"Title_BootHeel";
            portraitImageName = @"char_barkeep";
            introText = @"We like a nice clean game here. Everyone knows the stakes, and none of us has anywhere we’re rushin’ off to. So save your pity, ante up and keep yer yapping to a minimum.";
            break;
        }
        case RoomMayorsDen: {
            backgroundImageName = @"A-D-K_DarkAlley_Background";
            titleTextImageName = @"Title_Mayor";
            portraitImageName = @"char_mayor";
            introText = @"They say you should never play cards with the devil. But I challenged him to a game of Acey Deucey ... and I won! Now, thanks to me, we all have life everlasting ... so long as we never get up from these chairs ... ";
            break;
        }
        case RoomDevilsLair: {
            backgroundImageName = @"A-D-K_FireTableBG";
            titleTextImageName = @"Title_DevilsTable";
            portraitImageName = @"char_devil";
            introText = @"Greatest haul I ever took was this town, and every last soul in it. ... What’s it worth to ya?";
            break;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Start the animation
    NSString* backgroundImagePath = [[NSBundle mainBundle]
                                           pathForResource:backgroundImageName
                                           ofType:@"png"];
    UIImage* backgroundImage = [UIImage imageWithContentsOfFile:backgroundImagePath];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UIImage* titleTextImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:titleTextImageName
                                                               ofType:@"png"]];
    self.overlay = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.05f, self.view.frame.size.height * 0.05f, self.view.frame.size.width * 0.9f, self.view.frame.size.height * 0.9f)];
    self.overlay.image = titleTextImage;
    [self.view addSubview:self.overlay];
    
    // Fade from the title to the dialog
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(revealTalkCard) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(revealDialog) userInfo:nil repeats:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* roomName;
    switch(self.currentRoom) {
        case RoomDarkAlley:
            roomName = @"Dark Alley";
            break;
        case RoomWidowPrecious:
            roomName = @"The Widow Precious";
            break;
        case RoomMayorsDen:
            roomName = @"The Mayor’s Parlor";
            break;
        case RoomBootHillSaloon:
            roomName = @"Boot Heel Saloon";
            break;
        case RoomDevilsLair:
            roomName = @"The Devil’s Table";
            break;
    }
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"Game Intro - %@", roomName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)revealTalkCard {
    NSString* talkCardImagePath = [[NSBundle mainBundle]
                                     pathForResource:@"dialog_background"
                                     ofType:@"png"];
    UIImage* talkCardImage = [UIImage imageWithContentsOfFile:talkCardImagePath];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;

    self.overlay.image = talkCardImage;
    [self.overlay.layer addAnimation:transition forKey:nil];
}

-(void)revealDialog {
    NSString* portraitImagePath = [[NSBundle mainBundle]
                                   pathForResource:portraitImageName
                                   ofType:@"png"];
    
    UIImage* portraitImage = [UIImage imageWithContentsOfFile:portraitImagePath];
    CGFloat portraitWidth = (CGRectGetWidth(self.overlay.frame) / 2) - 40.0f;
    CGFloat portraitHeight = portraitWidth; // Right now the images are squares
    UIImageView* portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 20.0, portraitWidth, portraitHeight)];
    portraitImageView.image = portraitImage;
    [self.overlay addSubview:portraitImageView];
    
    UILabel* introTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, (CGRectGetWidth(self.overlay.frame) / 2) - 20.0f, CGRectGetHeight(self.overlay.frame) - 90.0f)];
    [introTextLabel setNumberOfLines:0];
    [introTextLabel setFont: [UIFont fontForBody]];
    [introTextLabel setText:introText];
    [introTextLabel sizeToFit];
    
    UIButton* startButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(introTextLabel.frame) + 20.0f, (CGRectGetWidth(self.overlay.frame) / 2) - 25.0f, CHOICE_BUTTON_HEIGHT)]; // Button is slightly narrower than the text box, because the text box's ragged edge makes it seem less wide
    [startButton setTitle:@"DEAL ME IN, PARTNER" forState:UIControlStateNormal];
    
    NSString* talkCardBackgroundImagePath = [[NSBundle mainBundle]
                                   pathForResource:@"talk_card_btn_background"
                                   ofType:@"png"];
    [startButton setBackgroundImage:[UIImage imageWithContentsOfFile:talkCardBackgroundImagePath] forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startButton.titleLabel setFont:[UIFont fontForBody]];
    [startButton addTarget:self action:@selector(selectGame) forControlEvents:UIControlEventTouchUpInside];

    // Create a container for the text and the button, and center it on the overlay
    CGFloat textAreaHeight = CGRectGetMaxY(startButton.frame);
    CGFloat textAreaY = (CGRectGetHeight(self.overlay.frame) - textAreaHeight) * 0.4;
    UIView* textBox = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.overlay.frame) * 0.47, textAreaY, (CGRectGetWidth(self.overlay.frame) / 2) - 20.0f, textAreaHeight)];
    
    [textBox addSubview:introTextLabel];
    [textBox addSubview:startButton];
    [self.overlay addSubview:textBox];
    
    [self.overlay setUserInteractionEnabled:YES];
}

-(void)selectGame {
    HGPGameSelectionViewController* gameSelectionViewController = [[HGPGameSelectionViewController alloc] init];
    gameSelectionViewController.currentRoom = self.currentRoom;
    gameSelectionViewController.delegate = self;
    [self addChildViewController:gameSelectionViewController];
    [self.view addSubview:gameSelectionViewController.view];
    [gameSelectionViewController didMoveToParentViewController:self];
    
    [self.delegate endMusic];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark GameDelegate methods

- (void)gameHasEnded {
    [self.delegate refreshDisplay:YES];
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

@end
