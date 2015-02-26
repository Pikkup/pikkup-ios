//
//  PUCreateGameViewController.h
//  picktup
//
//  Created by Planet 1107 on 20/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUSuperViewController.h"

@protocol PUCreateParkViewControllerDelegate <NSObject>

- (void)parkCreated:(PUPark*)createdPark;

@end

@interface PUCreateParkViewController : PUSuperViewController

@property (assign, nonatomic) id <PUCreateParkViewControllerDelegate> delegate;

@end
