//
//  HGPDialogCard.h
//  Haxan Gulch Poker
//
//  Created by Chris Dahlen on 5/15/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSFadingScrollView/SSFadingScrollView.h>
#import "SceneDelegate.h"

@interface HGPDialogCard : UIView

@property (nonatomic, strong) NSString* _Nullable portraitImageName;
@property (nonatomic, strong) NSString* _Nullable text;
@property (nonatomic, strong) NSArray<NSString*>* _Nullable choices;

- (instancetype _Nullable )initWithFrame:(CGRect)frame text:(NSString*_Nullable)text choices:(NSArray<NSString*>*_Nullable)choices;

- (instancetype _Nullable )initWithFrame:(CGRect)frame portraitImageName:(NSString*_Nullable)imageName text:(NSString*_Nullable)text choices:(NSArray<NSString*>*_Nullable)choices;

// The delegate that lets the dialog communicate with and pass a player selection back to the view controller
// TODO: This should be more flexible, so that we can pass a button in here rather than relying on this one rigid mechanism to let people make choices
@property (nullable, nonatomic, weak) id<SceneDelegate> delegate;

@end
