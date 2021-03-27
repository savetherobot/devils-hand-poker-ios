//
//  HGPDialogCard.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/15/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPDialogCard.h"

@implementation HGPDialogCard

- (instancetype)initWithFrame:(CGRect)frame text:(NSString*)text choices:(NSArray<NSString*>*)choices
{
    self = [super initWithFrame:frame];
    
    self.text = text;
    
    // Show the background
    UIImageView* talkCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    UIImage* talkCardImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dialog_background" ofType:@"png"]];
    
    talkCardImageView.image = talkCardImage;
    [self addSubview:talkCardImageView];
    
    UILabel* introTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, MARGIN_WIDE, CGRectGetWidth(self.frame) - (MARGIN_WIDE * 2), CGRectGetHeight(self.frame) - 90.0f)];
    [introTextLabel setNumberOfLines:0];
    [introTextLabel setFont: [UIFont fontForBody]];
    [introTextLabel setText:self.text];
    
    CGFloat originalWidth = CGRectGetWidth(introTextLabel.frame);
    [introTextLabel sizeToFit];
    CGRect introTextFrame = introTextLabel.frame;
    introTextFrame.size.width = originalWidth;
    [introTextLabel setFrame:introTextFrame];
    
    self.choices = choices;
    
    int choiceButtonY = CGRectGetMaxY(introTextLabel.frame);
    
    NSMutableArray* choiceButtons = [[NSMutableArray alloc] init];
    
    if (choices && [choices count] > 0) {
        choiceButtonY += kOverlayCardMargin;
        for (int i = 0; i < [choices count]; i++) {
            UIButton* choiceButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, choiceButtonY, CGRectGetWidth(introTextLabel.frame), CHOICE_BUTTON_HEIGHT)];
            [choiceButton setTitle:[NSString stringWithFormat:@"%@", choices[i]] forState:UIControlStateNormal];
            [choiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [choiceButton.titleLabel setFont:[UIFont fontForBody]];
            [choiceButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"talk_card_btn_background" ofType:@"png"]] forState:UIControlStateNormal];
            [choiceButton addTarget:self action:@selector(choiceMade:) forControlEvents:UIControlEventTouchUpInside];
            [choiceButton setTag:i];
            choiceButtonY += CGRectGetHeight(choiceButton.frame) + MARGIN_STANDARD;
            
            [choiceButtons addObject:choiceButton];
        }
    }
    
    // Create a container for the text and any buttons
    SSFadingScrollView* textScrollView = [[SSFadingScrollView alloc] initWithFrame:CGRectMake(MARGIN_WIDE, kOverlayCardMargin, CGRectGetWidth(self.frame) - (MARGIN_WIDE * 2), CGRectGetHeight(self.frame) - kOverlayCardMargin * 3)];

    [textScrollView setShowsHorizontalScrollIndicator:NO];
    [textScrollView setShowsVerticalScrollIndicator:YES];
    
    [textScrollView addSubview:introTextLabel];
    for (UIButton* choiceButton in choiceButtons) {
        [textScrollView addSubview:choiceButton];
    }
    
    CGFloat textContextSizeHeight = choiceButtonY;
    [textScrollView setContentSize:CGSizeMake(CGRectGetWidth(textScrollView.frame), textContextSizeHeight)];
    
    [self addSubview:textScrollView];
    
    [self setUserInteractionEnabled:YES];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame portraitImageName:(NSString*)imageName text:(NSString*)text choices:(NSArray<NSString*>*)choices
{
    self = [super initWithFrame:frame];
    
    self.portraitImageName = imageName;
    self.text = text;
    
    // Show the background
    UIImageView* talkCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    UIImage* talkCardImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:@"dialog_background"
                                                               ofType:@"png"]];
    talkCardImageView.image = talkCardImage;
    [self addSubview:talkCardImageView];

    UIImage* portraitImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.portraitImageName ofType:@"png"]];
    CGFloat portraitWidth = (CGRectGetWidth(self.frame) / 2) - kOverlayCardMargin * 2.0f;
    CGFloat portraitHeight = portraitWidth; // Right now the images are squares
    UIImageView* portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kOverlayCardMargin, kOverlayCardMargin, portraitWidth, portraitHeight)];
    portraitImageView.image = portraitImage;
    [self addSubview:portraitImageView];
    
    UILabel* introTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, kOverlayCardMargin, (CGRectGetWidth(self.frame) / 2) - kOverlayCardMargin, CGRectGetHeight(self.frame) - 90.0f)];
    [introTextLabel setNumberOfLines:0];
    [introTextLabel setFont: [UIFont fontForBody]];
    [introTextLabel setText:self.text];
    [introTextLabel sizeToFit];
    
    self.choices = choices;
    
    int choiceButtonY = CGRectGetMaxY(introTextLabel.frame);
    
    NSMutableArray* choiceButtons = [[NSMutableArray alloc] init];
    
    if (choices && [choices count] > 0) {
        choiceButtonY += kOverlayCardMargin;
        for (int i = 0; i < [choices count]; i++) {
            UIButton* choiceButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, choiceButtonY, CGRectGetWidth(introTextLabel.frame), CHOICE_BUTTON_HEIGHT)];
            [choiceButton setTitle:[NSString stringWithFormat:@"%@", choices[i]] forState:UIControlStateNormal];
            [choiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [choiceButton.titleLabel setFont:[UIFont fontForBody]];
            [choiceButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"talk_card_btn_background" ofType:@"png"]] forState:UIControlStateNormal];
            [choiceButton addTarget:self action:@selector(choiceMade:) forControlEvents:UIControlEventTouchUpInside];
            [choiceButton setTag:i];
            choiceButtonY += CGRectGetHeight(choiceButton.frame) + MARGIN_STANDARD;
            
            [choiceButtons addObject:choiceButton];
        }
    }
    
    // Create a container for the text and any buttons
    SSFadingScrollView* textScrollView = [[SSFadingScrollView alloc]  initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.47f, MARGIN_STANDARD, (CGRectGetWidth(self.frame) / 2) - kOverlayCardMargin, CGRectGetHeight(self.frame) - MARGIN_STANDARD * 2)];
    
    [textScrollView setShowsHorizontalScrollIndicator:NO];
    [textScrollView setShowsVerticalScrollIndicator:YES];
    
    [textScrollView addSubview:introTextLabel];
    for (UIButton* choiceButton in choiceButtons) {
        [textScrollView addSubview:choiceButton];
    }
    
    CGFloat textContextSizeHeight = choiceButtonY;
    [textScrollView setContentSize:CGSizeMake(CGRectGetWidth(textScrollView.frame), textContextSizeHeight)];
    
    [self addSubview:textScrollView];
    
    [self setUserInteractionEnabled:YES];
    
    return self;
}

-(void)choiceMade:(id)sender {
    UIButton* buttonSelected = (UIButton*)sender;
    
    //Pass the selection to the delegate for handling
    [self.delegate choiceSelected:(int)buttonSelected.tag];
}


@end
