//
//  HGPTutorialViewController.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 8/14/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "HGPModal.h"
#import "HGPCardDisplay.h"
#import "Card.h"

@interface HGPTutorialViewController : UIViewController {
    UIImageView* buttonBackground;
    UIImageView* talkCardImageView;
    UIButton* nextButton;
    UIButton* quitButton;
    UILabel* instructionalText;
    HGPCardDisplay* cardDisplay;
    int page;
    
    // Shameless hack to feed the middle card image to revealMiddleCard method
    UIImage* middleCardImageToDisplay;
}

@property (nonatomic) Game game;

@end
