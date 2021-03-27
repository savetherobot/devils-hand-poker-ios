//
//  HGPCreditsViewController.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/30/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPCreditsViewController.h"

@interface HGPCreditsViewController ()

@end

@implementation HGPCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImage* backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:@"A-D-K_DarkAlley_Background"
                                                               ofType:@"png"]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UIImageView* talkCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.1f, self.view.frame.size.height * 0.1f, self.view.frame.size.width * 0.8f, self.view.frame.size.height * 0.8f)];
    UIImage* talkCardImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:@"dialog_background"
                                                               ofType:@"png"]];
    talkCardImageView.image = talkCardImage;
    [self.view addSubview:talkCardImageView];
    
    NSString* creditsText = @"\nDEVIL’S HAND POKER\n\n\nby Chris Dahlen & Rich Woodall\nRound the Fire Entertainment, 2017\n\n\nMusic restored and recreated on player piano by Tom Brown Records, via archive.org. Public domain.\n\nSongs include:\n“Moonlight Memories”, perf. unknown \n“La Paloma”, perf. unknown\n“North Wind”, perf. unknown\n“Spanish Dance”, perf. Howard Brockway\n“Arabesque”, perf. Earl Billings\n\nThanks to Mark, David, Everett, Stephen, Tim, John, and Ali for introducing us to these terrific games.\n\nThanks especially to our playtesters, Nick, Teri, Matt, David, west coast David, Anne, and Amy.\n\n“They bet and raised, ate and drank, and from that point on resumed playing such games as high-low, acey-deucy, Chicago, Omaha, Texas hold’em, anaconda and a couple of other deviant strains in poker’s line of ancestry … ” - Don DeLillo\n\n";
    
    SSFadingScrollView* scrollView = [[SSFadingScrollView alloc] initWithFrame:CGRectMake(MARGIN_STANDARD * 2, MARGIN_STANDARD, CGRectGetWidth(talkCardImageView.frame) - (MARGIN_STANDARD * 4.0f), CGRectGetHeight(talkCardImageView.frame) - (MARGIN_STANDARD * 4.0f))];
    UILabel* creditsTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame))];
    [creditsTextLabel setNumberOfLines:0];
    [creditsTextLabel setFont: [UIFont fontForBody]];
    [creditsTextLabel setText:creditsText];
    [creditsTextLabel setTextColor:[UIColor blackColor]];
    [creditsTextLabel sizeToFit];
    
    CGFloat closeButtonEdge = 25.0f;
    UIButton* closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(talkCardImageView.frame) - closeButtonEdge, closeButtonEdge / 2, closeButtonEdge, closeButtonEdge)];
    
    
    [closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"X_out_BTN" ofType:@"png"]] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissMe) forControlEvents:UIControlEventTouchUpInside];
    
    [talkCardImageView addSubview:closeButton];
    
    // Necessary in order to let all its subviews act
    [talkCardImageView setUserInteractionEnabled:YES];
    
    [scrollView addSubview:creditsTextLabel];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.frame), CGRectGetHeight(creditsTextLabel.frame))];
    [talkCardImageView addSubview:scrollView];
    [self.view addSubview:talkCardImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Credits"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

// Dismiss the modal
-(void)dismissMe {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
