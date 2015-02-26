//
//  PUAppDelegate.h
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ViewDeck/IIViewDeckController.h>
#import "PUSideViewController.h"

@interface PUAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IIViewDeckController *viewDeckController;
@property (strong, nonatomic) PUSideViewController *sideViewController;

@end
