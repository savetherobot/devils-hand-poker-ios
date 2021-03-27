//
//  HGPModal.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/8/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGPModal : UIView

/**
 Create a simple modal with a background and nothing else; can be used to set up buttons and other features
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 Create a conversation modal with text
 */
- (instancetype)initWithFrame:(CGRect)frame text:(NSString*)text;

/**
 Create a conversation modal with a portrait and text
 */
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString*)imageName text:(NSString*)text;


/**
 Accessor for the close button
 */
@property (nonatomic, strong) UIButton* closeButton;

@end
