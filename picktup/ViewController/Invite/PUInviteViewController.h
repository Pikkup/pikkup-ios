//
//  PUInviteViewController.h
//  picktup
//
//  Created by Planet 1107 on 07/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSuperViewController.h"

@protocol PUInviteViewControllerDelegate <NSObject>

- (void)invitedUsers:(NSArray*)users;

@end

@interface PUInviteViewController : PUSuperViewController

@property (strong, nonatomic) PUEvent *event;
@property (assign, nonatomic) id <PUInviteViewControllerDelegate> delegate;

@end
