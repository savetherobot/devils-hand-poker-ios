//
//  HGPTutorialViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/14/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPTutorialViewController.h"

@interface HGPTutorialViewController ()

@end

@implementation HGPTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the background
    UIImage* backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                                 pathForResource:@"A-D-K_PokerTableBG"
                                                                 ofType:@"png"]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    //////////////////////////////////////////////////////////////
    // Instructional text
    talkCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, MARGIN_STANDARD, CGRectGetWidth(self.view.frame) - MARGIN_STANDARD * 2.0f, 110.0f)];
    
    NSString* talkCardImagePath = [[NSBundle mainBundle]
                                   pathForResource:@"dialog_background"
                                   ofType:@"png"];
    UIImage* talkCardImage = [UIImage imageWithContentsOfFile:talkCardImagePath];
    talkCardImageView.image = talkCardImage;
    [self.view addSubview:talkCardImageView];
    
    // Add a portrait thumbnail
    CGFloat marginInModal = 5.0f;
    CGFloat portraitEdge = CGRectGetHeight(talkCardImageView.frame) - marginInModal * 2.0f;
    UIImageView* portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(marginInModal, marginInModal, portraitEdge, portraitEdge)];
    UIImage* portraitImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:@"char_bum"
                                                               ofType:@"png"]];
    portraitImageView.image = portraitImage;
    [talkCardImageView addSubview:portraitImageView];
    
    // Add the label for the text
    CGFloat labelWidth = CGRectGetWidth(talkCardImageView.frame) - CGRectGetMaxX(portraitImageView.frame) - marginInModal * 4;
    instructionalText = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(portraitImageView.frame) + marginInModal, marginInModal, labelWidth, CGRectGetHeight(talkCardImageView.frame) - (marginInModal * 3.0f))]; // Reduce the height a little more than expected, or else it'll look low against this irregular background
    [instructionalText setNumberOfLines:0];
    [instructionalText setFont: [UIFont fontForBody]];
    [talkCardImageView addSubview:instructionalText];

    //////////////////////////////////////////////////////////////
    // Betting/action bar
    
    // Set up the bar button
    CGFloat buttonBarHeight = CGRectGetWidth(self.view.frame) * 0.075f;
    buttonBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - buttonBarHeight, CGRectGetWidth(self.view.frame), buttonBarHeight)];
    [buttonBackground setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BetBar" ofType:@"png"]]];
    [self.view addSubview:buttonBackground];
    
    // Establish the next button that the player taps when the AI is playing
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(buttonBackground.frame), buttonBackground.frame.size.width, buttonBackground.frame.size.height)];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self styleButton:nextButton];
    [nextButton addTarget:self action:@selector(nextPage) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    // ... and the quit button that will show at the end
    quitButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(buttonBackground.frame), buttonBackground.frame.size.width, buttonBackground.frame.size.height)];
    [quitButton setTitle:@"Okay, I Got it!" forState:UIControlStateNormal];
    [self styleButton:quitButton];
    [quitButton addTarget:self action:@selector(quitTutorial) forControlEvents: UIControlEventTouchUpInside];
    [quitButton setHidden:YES];
    [self.view addSubview:quitButton];
    
    if (GameAceyDeucey == self.game) {
        //////////////////////////////////////////////////////////////
        // The progress view
        // TODO: Not every game will need this
        CGFloat widthOfProgressView = (CGRectGetWidth(self.view.frame) - MARGIN_STANDARD * 2) * 0.95f;   // Work out the correct width and then tuck it in by another 20% to ensure it fits well within the bar
        CGFloat progressViewCardWidth = (widthOfProgressView / SIZE_OF_DECK) * 0.5689f; // The 0.5689f represents the fact that each card overlaps the previous one
        CGFloat progressViewMaxCardHeight = progressViewCardWidth * HEIGHT_IS_PERCENTAGE_OF_WIDTH; //  cardWidth * 0.60345;
        
        // While most of the cards overlap each other, the last one on the end will not. Adjust the x cordinate of the progress view to account for that, so we can properly center the whole thing
        CGFloat progressViewX = ((CGRectGetWidth(self.view.frame) - widthOfProgressView) / 2) - ((widthOfProgressView / SIZE_OF_DECK) - progressViewCardWidth);
        
        UIView* progressView = [[UIView alloc] initWithFrame:CGRectMake(progressViewX, CGRectGetMinY(buttonBackground.frame) - progressViewMaxCardHeight, widthOfProgressView, progressViewMaxCardHeight)];
        
        CGFloat progressViewExposedCardWidth = CGRectGetWidth(progressView.frame) / SIZE_OF_DECK;
        progressViewCardWidth = progressViewExposedCardWidth * 1.7575f;
        CGFloat progressViewCardHeight = progressViewCardWidth * HEIGHT_IS_PERCENTAGE_OF_WIDTH;
        
        int progressThroughDeck = 12; // Arbitrary
        
        UIImage *cardBack = [Card getCardBackSmallImage];
        
        for (int i = 0; i < SIZE_OF_DECK; i++) {
            CGFloat cardY = i >= progressThroughDeck ? 0.0f : progressViewCardHeight / 5;
            CGFloat cardX = i * progressViewExposedCardWidth;
            UIImageView* card = [[UIImageView alloc] initWithFrame:CGRectMake(cardX, cardY, progressViewCardWidth, progressViewCardHeight)];
            [card setImage:cardBack];
            [progressView addSubview:card];
        }
        
        [self.view insertSubview:progressView belowSubview:buttonBackground];
    }
    
    //////////////////////////////////////////////////////////////
    // Start the tutorial
    
    // Start on page one ...
    page = 0;

    // ... and off we go
    [self advanceTutorial];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* gameName;
    switch(self.game) {
        case GameDayBaseball:
            gameName = @"Day Baseball";
            break;
        case GameAnaconda:
            gameName = @"Anaconda";
            break;
        case GameAceyDeucey:
            gameName = @"Acey Deucey";
            break;
        case GameHighLow:
            gameName = @"High-Low";
            break;
        case GameFollowTheQueen:
            gameName = @"Follow the Queen";
    }
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"Tutorial - %@", gameName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)advanceTutorial {
    switch(self.game) {
        case GameAnaconda:
            [self advanceAnacondaTutorial];
            break;
        case GameDayBaseball:
            [self advanceDayBaseballTutorial];
            break;
        case GameAceyDeucey:
            [self advanceAceyDeuceyTutorial];
            break;
        case GameHighLow:
            [self advanceHighLowTutorial];
            break;
        case GameFollowTheQueen:
            [self advanceFollowTheQueenTutorial];
            break;
    }
}

// TODO: This is super bespoke. We'll refactor it and move the content to JSON once we see what these tutorials have in common
-(void)advanceAceyDeuceyTutorial {
    NSString* tutorialText;
    NSArray<Card*>* demoHand;
    switch(page) {
        case 0: {
            tutorialText = @"In Acey Deucey, the dealer lays down two cards face up and then a third one face down. You have to bet if that middle card falls between the other two.";
            Card* c1 = [[Card alloc] initWithRank:2 suit:Hearts isFaceup:YES];
            Card* c2 = [[Card alloc] initWithRank:7 suit:Spades isFaceup:NO];
            Card* c3 = [[Card alloc] initWithRank:12 suit:Diamonds isFaceup:YES];
            demoHand = @[c1, c2, c3];
            break;
        }
        case 1: {
            tutorialText = @"If you see a 2 and a Q, that’s a mighty wide spread - and that means good odds! If it’s a 4 and a 6, things are a little tighter.";
            Card* c1 = [[Card alloc] initWithRank:2 suit:Hearts isFaceup:YES];
            Card* c2 = [[Card alloc] initWithRank:7 suit:Spades isFaceup:NO];
            Card* c3 = [[Card alloc] initWithRank:12 suit:Diamonds isFaceup:YES];
            demoHand = @[c1, c2, c3];
            break;
        }
        case 2: {
            tutorialText = @"Now, what if a deal ain’t quite fair? Let’s say the first two cards are right next to each other, with no room in-between. We call that The Gulch. You bet the ante on whether the next card is higher or lower than both of ‘em!";
            Card* c1 = [[Card alloc] initWithRank:6 suit:Hearts isFaceup:YES];
            Card* c2 = [[Card alloc] initWithRank:11 suit:Spades isFaceup:NO];
            Card* c3 = [[Card alloc] initWithRank:7 suit:Diamonds isFaceup:YES];
            demoHand = @[c1, c2, c3];
            break;
        }
        case 3: {
            tutorialText = @"You might also get a chance at three of a kind. That pays five times your bet!";
            Card* c1 = [[Card alloc] initWithRank:7 suit:Hearts isFaceup:YES];
            Card* c2 = [[Card alloc] initWithRank:7 suit:Spades isFaceup:NO];
            Card* c3 = [[Card alloc] initWithRank:7 suit:Diamonds isFaceup:YES];
            demoHand = @[c1, c2, c3];
            break;
        }
        case 4: {
            tutorialText = @"Down at the bottom of the screen, you’ll see how many cards are left in the deck. If you've got a head for counting cards, you might be able to suss out your odds based on what’s left ... ";
            Card* c1 = [[Card alloc] initWithRank:1 suit:Hearts isFaceup:YES];
            Card* c2 = [[Card alloc] initWithRank:7 suit:Spades isFaceup:NO];
            Card* c3 = [[Card alloc] initWithRank:12 suit:Diamonds isFaceup:YES];
            demoHand = @[c1, c2, c3];
            break;
        }
        case 5: {
            tutorialText = @"And that’s acey deucey! It’s real popular in this town, so if you want to be hospitable, play a hand with everyone you meet!";
            Card* c1 = [[Card alloc] initWithRank:6 suit:Hearts isFaceup:YES];
            Card* c2 = [[Card alloc] initWithRank:6 suit:Spades isFaceup:NO];
            Card* c3 = [[Card alloc] initWithRank:6 suit:Diamonds isFaceup:YES];
            demoHand = @[c1, c2, c3];
            
            [self endTutorial];
            break;
        }
    }
    
    [self updateTutorialText:tutorialText];
    
    CGFloat cardDisplayHeight = CGRectGetHeight(self.view.frame) - CGRectGetHeight(talkCardImageView.frame) - CGRectGetHeight(buttonBackground.frame) - MARGIN_STANDARD * 4;
    
    cardDisplay = [[HGPCardDisplay alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, CGRectGetMaxY(talkCardImageView.frame) + MARGIN_STANDARD, CGRectGetWidth(self.view.frame) - MARGIN_STANDARD * 2.0, cardDisplayHeight) cards:demoHand isHuman:YES allowPeekOnFaceDownCards:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(revealMiddleCard) userInfo:nil repeats:NO];
    middleCardImageToDisplay = [demoHand[1] getImage];

    [self.view addSubview:cardDisplay];
}

-(void)advanceAnacondaTutorial {
    NSString* tutorialText;
    NSArray<Card*>* demoHand;
    NSArray<Card*>* trashHand;
    
    // TODO: Figure out what the cards will do
    
    switch(page) {
        case 0: {
            tutorialText = @"The game is called Anaconda, but we call it ‘pass the trash’ - because that’s what you do. You pass another player the cards you don’t want, and then you get stuck with cards they don’t want. How good a hand can you make?";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:4 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:6 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:5 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:3 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:12 suit:Hearts isFaceup:YES],
                         [[Card alloc] initWithRank:10 suit:Spades isFaceup:YES]];
            trashHand = @[[[Card alloc] initWithRank:4 suit:Clubs isFaceup:YES],
                         [[Card alloc] initWithRank:8 suit:Hearts isFaceup:YES],
                         [[Card alloc] initWithRank:11 suit:Spades isFaceup:YES]];
            break;
        }
        case 1: {
            tutorialText = @"We go in three rounds. First, everyone passes three cards to the player on their left. Then they pass two cards to the right. And finally, one last card to the left. Tap the cards you want to get rid of and when you’re ready, we go around the table and bet!";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:4 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:6 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:5 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:3 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:12 suit:Hearts isFaceup:YES],
                         [[Card alloc] initWithRank:10 suit:Spades isFaceup:YES]];
            trashHand = @[[[Card alloc] initWithRank:4 suit:Clubs isFaceup:YES],
                          [[Card alloc] initWithRank:8 suit:Hearts isFaceup:YES],
                          [[Card alloc] initWithRank:11 suit:Spades isFaceup:YES]];
            break;
        }
        case 2: {
            tutorialText = @"You may start out with a straight flush - but you have to give up a card and hope for the best. Or, you may think you’re getting closer to a good hand - but what will your buddy next to you stick you with?";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:4 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:6 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:5 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:3 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:12 suit:Hearts isFaceup:YES],
                         [[Card alloc] initWithRank:10 suit:Spades isFaceup:YES]];
            trashHand = @[[[Card alloc] initWithRank:4 suit:Clubs isFaceup:YES],
                          [[Card alloc] initWithRank:8 suit:Hearts isFaceup:YES],
                          [[Card alloc] initWithRank:11 suit:Spades isFaceup:YES]];
            break;
        }
        case 3: {
            tutorialText = @"At the end, the best hand wins the pot. Poker rules apply. Helpful hint: you can tap and slide your cards to make it easier to see your hand as it comes together - or gets blown to pieces!";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:4 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:6 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:5 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:3 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:12 suit:Hearts isFaceup:YES],
                         [[Card alloc] initWithRank:10 suit:Spades isFaceup:YES]];
            trashHand = @[[[Card alloc] initWithRank:4 suit:Clubs isFaceup:YES],
                          [[Card alloc] initWithRank:8 suit:Hearts isFaceup:YES],
                          [[Card alloc] initWithRank:11 suit:Spades isFaceup:YES]];
            break;
        }
        case 4: {
            tutorialText = @"And that’s it! Every game of Anaconda is a battle of the half-wits, so just have fun!";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:4 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:6 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:5 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:3 suit:Diamonds isFaceup:YES],
                         [[Card alloc] initWithRank:12 suit:Hearts isFaceup:YES],
                         [[Card alloc] initWithRank:10 suit:Spades isFaceup:YES]];
            trashHand = @[[[Card alloc] initWithRank:4 suit:Clubs isFaceup:YES],
                          [[Card alloc] initWithRank:8 suit:Hearts isFaceup:YES],
                          [[Card alloc] initWithRank:11 suit:Spades isFaceup:YES]];
            
            [self endTutorial];
            break;
        }
    }
    
    [self updateTutorialText:tutorialText];
    
    CGFloat cardDisplayHeight = CGRectGetHeight(self.view.frame) - CGRectGetHeight(talkCardImageView.frame) - CGRectGetHeight(buttonBackground.frame) - MARGIN_STANDARD * 4;
    
    cardDisplay = [[HGPCardDisplay alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, CGRectGetMaxY(talkCardImageView.frame) + MARGIN_STANDARD, CGRectGetWidth(self.view.frame) - MARGIN_STANDARD * 2.0, cardDisplayHeight) cards:demoHand isHuman:YES];
    
    int cardsToAnimate = 3;
    if (page < cardsToAnimate) cardsToAnimate = 3 - page;
    for (int i = 0; i < cardsToAnimate; i++) {
        bool slideLeft = cardsToAnimate % 2 != 0;
        
        // Slide each card off the screen to the left
        UIImageView* card = cardDisplay.cardImages[slideLeft ? i : ([demoHand count] - 1) - i];
        CGRect originalRect = card.frame;
        CGRect destinationRect = card.frame;
        destinationRect.origin.x = slideLeft ? 0 - self.view.frame.size.width : self.view.frame.size.width;
        [UIView animateWithDuration:1.0
                              delay:1.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             card.frame = destinationRect;
                         }
                         completion:^(BOOL finished){
                             // Update the card and ready it by locating it (without animation) off to the right-hand side of the screen
                             card.image = [trashHand[i] getImage];
                             CGRect trashCardOriginRect = card.frame;
                             trashCardOriginRect.origin.x = slideLeft ? self.view.frame.size.width : 0 - self.view.frame.size.width;
                             card.frame = trashCardOriginRect;
                             
                             // ... and then slide it in where the old card was
                             [UIView animateWithDuration:1.0
                                                   delay:0.0
                                                 options: UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  card.frame = originalRect;
                                              }
                                              completion:^(BOOL finished){
                                                  // Now we're done
                                              }
                              ];
                         }];
    }
    
    [self.view addSubview:cardDisplay];
}

-(void)advanceDayBaseballTutorial {
    NSString* tutorialText;
    NSArray<Card*>* demoHand;
    switch(page) {
        case 0: {
            tutorialText = @"Day baseball is good old seven card stud, with a couple of wrinkles. Players are dealt two cards facedown down and one faceup.";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Diamonds isFaceup:NO],
                         [[Card alloc] initWithRank:8 suit:Hearts isFaceup:NO],
                         [[Card alloc] initWithRank:7 suit:Clubs isFaceup:YES]];
            break;
        }
        case 1: {
            tutorialText = @"We keep dealing around the table - three more cards up, and the last card is down. You’ll see what you're holding, but everyone else is just guessing - and betting.";
            demoHand = @[[[Card alloc] initWithRank:3 suit:Clubs isFaceup:YES]];
            break;
        }
        case 2: {
            tutorialText = @"Here’s the wrinkle: 3’s and 9’s are wild. And if you’re dealt a 4, you get a chance to buy another card!";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Hearts isFaceup:YES]];
            break;
        }
        case 3: {
            tutorialText = @"If your pals at the table think they have a winner, they’ll bet large - and you’d better keep up. But if the action gets too hot, just fold. Live to bet another day.";
            demoHand = @[[[Card alloc] initWithRank:9 suit:Clubs isFaceup:YES],
                         [[Card alloc] initWithRank:7 suit:Spades isFaceup:NO]];
            
            [self endTutorial];
            break;
        }
    }
    
    [self updateTutorialText:tutorialText];
    
    // If the card display has not been initialized, do that ...
    if (!cardDisplay) {
        CGFloat cardDisplayHeight = CGRectGetHeight(self.view.frame) - CGRectGetHeight(talkCardImageView.frame) - CGRectGetHeight(buttonBackground.frame) - MARGIN_STANDARD * 4;
        
        cardDisplay = [[HGPCardDisplay alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, CGRectGetMaxY(talkCardImageView.frame) + MARGIN_STANDARD, CGRectGetWidth(self.view.frame) - MARGIN_STANDARD * 2.0, cardDisplayHeight) cards:demoHand isHuman:YES];
        
        [self.view addSubview:cardDisplay];
    }
    // ... otherwise, just deal cards to it
    else {
        [cardDisplay dealCardsToDisplay:demoHand];
        
        // TODO: Shouldn't need to re-add the card display - just leave it up. See nextPage for the problem
        [self.view addSubview:cardDisplay];
    }
}

-(void)advanceFollowTheQueenTutorial {
    NSString* tutorialText;
    NSArray<Card*>* demoHand;
    switch(page) {
        case 0: {
            tutorialText = @"Follow the Queen is another version of seven-card stud poker. Everyone starts with two cards down and one card up. You keep betting as the cards are dealt.";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Diamonds isFaceup:NO],
                         [[Card alloc] initWithRank:8 suit:Hearts isFaceup:NO],
                         [[Card alloc] initWithRank:7 suit:Clubs isFaceup:YES],
                         [[Card alloc] initWithRank:4 suit:Clubs isFaceup:YES]];
            break;
        }
        case 1: {
            tutorialText = @"But when the Queen shows up, the game changes. The next card that’s dealt after the Queen is the wild card.";
            demoHand = @[[[Card alloc] initWithRank:12 suit:Clubs isFaceup:YES]];
            break;
        }
        case 2: {
            tutorialText = @"If another Queen shows up, the table has a new wild card - and your hand might be worth a lot more. Or a lot less!";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Hearts isFaceup:YES]];
            break;
        }
        case 3: {
            tutorialText = @"Betting continues until every player has seven cards, and then we’ll see who’s got the Queen’s favor. There’s no arguing with royalty - but if she wipes you out this time, just play another round!";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Hearts isFaceup:NO]];
            [self endTutorial];
            break;
        }
    }
    
    [self updateTutorialText:tutorialText];
    
    // If the card display has not been initialized, do that ...
    if (!cardDisplay) {
        CGFloat cardDisplayHeight = CGRectGetHeight(self.view.frame) - CGRectGetHeight(talkCardImageView.frame) - CGRectGetHeight(buttonBackground.frame) - MARGIN_STANDARD * 4;
        
        cardDisplay = [[HGPCardDisplay alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, CGRectGetMaxY(talkCardImageView.frame) + MARGIN_STANDARD, CGRectGetWidth(self.view.frame) - MARGIN_STANDARD * 2.0, cardDisplayHeight) cards:demoHand isHuman:YES];
        
        [self.view addSubview:cardDisplay];
    }
    // ... otherwise, just deal cards to it
    else {
        [cardDisplay dealCardsToDisplay:demoHand];
        
        // TODO: Shouldn't need to re-add the card display - just leave it up. See nextPage for the problem
        [self.view addSubview:cardDisplay];
        
    }
}


-(void)advanceHighLowTutorial {
    NSString* tutorialText;
    NSArray<Card*>* demoHand;
    switch(page) {
        case 0: {
            tutorialText = @"High-Low is another version of seven-card stud poker, with a wild card to make it interesting. Everyone starts with two cards down and one card up. You keep betting as the cards are dealt.";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Diamonds isFaceup:NO],
                         [[Card alloc] initWithRank:8 suit:Hearts isFaceup:NO],
                         [[Card alloc] initWithRank:7 suit:Clubs isFaceup:YES]];
            break;
        }
        case 1: {
            tutorialText = @"We keep dealing around the table - three more cards up, and the last card is down. Then, when all the cards are out, it gets interesting: you have to bet on whether you can win the high hand, or the low hand.";
            demoHand = @[[[Card alloc] initWithRank:3 suit:Clubs isFaceup:YES]];
            break;
        }
        case 2: {
            tutorialText = @"High hands work like you’re used to: royal flush beats two pair and all that. The low hand is just a straight-up low hand: five different cards that are as low as they can be.";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Hearts isFaceup:YES]];
            break;
        }
        case 3: {
            tutorialText = @"Cards in the low hand must be 8 or lower, and this time, Aces are low. We compare ’em card by card: A 6-5 beats a 7-4, an 8-5 probably isn't going to beat anything. The lowest hand is the Wheel: 5, 4, 3, 2, Ace.";
            demoHand = @[[[Card alloc] initWithRank:7 suit:Hearts isFaceup:YES]];
            break;
        }
        case 4: {
            tutorialText = @"The winner of the high hand and the winner of the low hand split the pot. That gives you an opportunity: If nobody else has a low hand, you could sneak in and win it with no trouble.";
            demoHand = @[[[Card alloc] initWithRank:9 suit:Clubs isFaceup:YES],
                         [[Card alloc] initWithRank:7 suit:Spades isFaceup:NO]];
            break;
        }
        case 5: {
            tutorialText = @"If you’re feeling brave, you could declare you have the high AND low hand. A 6-5-4-3-2 could also make a nice straight flush! If you win, you get the whole pot - but if anyone comes in with a higher or a lower hand, you lose.";
            break;
        }
        case 6: {
            tutorialText = @"And that's High-Low. Perfect for bluffers, opportunists, liars, and anyone who likes to surprise the table with a big risky move from time to time.";
            [self endTutorial];
            break;
        }
    }
    
    [self updateTutorialText:tutorialText];
    
    // If the card display has not been initialized, do that ...
    if (!cardDisplay) {
        CGFloat cardDisplayHeight = CGRectGetHeight(self.view.frame) - CGRectGetHeight(talkCardImageView.frame) - CGRectGetHeight(buttonBackground.frame) - MARGIN_STANDARD * 4;
        
        cardDisplay = [[HGPCardDisplay alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, CGRectGetMaxY(talkCardImageView.frame) + MARGIN_STANDARD, CGRectGetWidth(self.view.frame) - MARGIN_STANDARD * 2.0, cardDisplayHeight) cards:demoHand isHuman:YES];
        
        [self.view addSubview:cardDisplay];
    }
    // ... otherwise, just deal cards to it
    else {
        [cardDisplay dealCardsToDisplay:demoHand];
        
        // TODO: Shouldn't need to re-add the card display - just leave it up. See nextPage for the problem
        [self.view addSubview:cardDisplay];
        
    }
}

// Animation
-(void)revealMiddleCard {
    // Each time, animate the middle card to flip
    if (cardDisplay.cardImages && [cardDisplay.cardImages count] > 2 && middleCardImageToDisplay) {
        UIImageView* middleCardImage = cardDisplay.cardImages[1];
        
        // TODO: Get the actual card
        middleCardImage.image = middleCardImageToDisplay;
        
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [middleCardImage.layer addAnimation:transition forKey:nil];
    }
}

// A helper method to update the tutorial text and format it if necessary into the available space
-(void)updateTutorialText:(NSString*)text {
    [instructionalText setText:text];
}

#pragma mark Action handlers

-(void)nextPage {
    page++;
    
    // Clear out the old content
    [cardDisplay removeFromSuperview];  // TODO: Move toward keeping card display around, like we do with day baseball
    
    [self advanceTutorial];
}

-(void)quitTutorial {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

// A helper method to take care of changing the UI to prepare for the end of the tutorial
-(void)endTutorial {
    [nextButton setHidden:YES];
    [quitButton setHidden:NO];
}

# pragma mark Helper methods

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
