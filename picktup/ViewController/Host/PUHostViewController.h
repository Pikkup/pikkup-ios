//
//  PUHostViewController.h
//  picktup
//
//  Created by Planet 1107 on 07/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSuperViewController.h"

@protocol PUHostViewControllerDelegate <NSObject>

- (void)addedEvent:(PUEvent*)event;

@end

@interface PUHostViewController : PUSuperViewController

@property (strong, nonatomic) PUPark *park;
@property (weak, nonatomic) id <PUHostViewControllerDelegate> delegate;

@end
