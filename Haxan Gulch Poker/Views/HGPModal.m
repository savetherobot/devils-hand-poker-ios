//
//  HGPModal.m
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/8/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import "HGPModal.h"

@implementation HGPModal

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Set up the background
        UIImageView* talkCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        
        UIImage* talkCardImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                                   pathForResource:@"dialog_background"
                                                                   ofType:@"png"]];
        talkCardImageView.image = talkCardImage;
        [self addSubview:talkCardImageView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame text:(NSString*)text
{
    self = [super initWithFrame:frame];
    
    CGFloat marginInModal = 5.0f;
    CGFloat closeButtonEdge = 25.0f;
    
    // Set up the background
    UIImageView* talkCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    UIImage* talkCardImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:@"dialog_background"
                                                               ofType:@"png"]];
    talkCardImageView.image = talkCardImage;
    [self addSubview:talkCardImageView];
    
    // Add the text ...
    CGFloat labelWidth = CGRectGetWidth(self.frame) - MARGIN_STANDARD;
    UILabel* introTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_STANDARD, marginInModal, labelWidth, CGRectGetHeight(self.frame) - (marginInModal * 2.0f))];
    [introTextLabel setNumberOfLines:0];
    [introTextLabel setFont: [UIFont fontForBody]];
    [introTextLabel setText:text];
    [self addSubview:introTextLabel];
    
    // ... and the close button
    CGFloat closeButtonY = CGRectGetHeight(self.frame) * 0.2;
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - closeButtonEdge - marginInModal, closeButtonY, closeButtonEdge, closeButtonEdge)];
    [self.closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"X_out_BTN" ofType:@"png"]] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(dismissMe) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.closeButton];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString*)imageName text:(NSString*)text
{
    self = [super initWithFrame:frame];

    CGFloat marginInModal = 5.0f;
    CGFloat portraitEdge = CGRectGetHeight(self.frame) - marginInModal * 2.0f;
    if (portraitEdge > 100.0f) portraitEdge = 100.0f;
    CGFloat closeButtonEdge = 25.0f;
    
    // Set up the background
    UIImageView* talkCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    UIImage* talkCardImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:@"dialog_background"
                                                               ofType:@"png"]];
    talkCardImageView.image = talkCardImage;
    [self addSubview:talkCardImageView];
    
    // Add a portrait thumbnail
    UIImageView* portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(marginInModal, marginInModal, portraitEdge, portraitEdge)];
    UIImage* portraitImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                               pathForResource:imageName
                                                               ofType:@"png"]];
    portraitImageView.image = portraitImage;
    [self addSubview:portraitImageView];
    
    // ... the text
    CGFloat labelWidth = CGRectGetWidth(self.frame) - CGRectGetMaxX(portraitImageView.frame) - marginInModal * 2 - MARGIN_STANDARD;
    UILabel* introTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(portraitImageView.frame) + marginInModal, marginInModal, labelWidth, CGRectGetHeight(self.frame) - (marginInModal * 2.0f) - 3.0f)];   // Trim a little more off the height because it tends to look low against this irregular background
    [introTextLabel setNumberOfLines:0];
    [introTextLabel setFont: [UIFont fontForBody]];
    [introTextLabel setText:text];
    [self addSubview:introTextLabel];
    
    // ... and the close button
    CGFloat closeButtonY = CGRectGetHeight(self.frame) * 0.2;
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - closeButtonEdge - marginInModal, closeButtonY, closeButtonEdge, closeButtonEdge)];
    [self.closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"X_out_BTN" ofType:@"png"]] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(dismissMe) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.closeButton];
    
    return self;
}

// Dismiss the modal
-(void)dismissMe {
    [self removeFromSuperview];
}

@end
