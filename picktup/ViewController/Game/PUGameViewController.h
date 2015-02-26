//
//  PUGameViewController.h
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSuperViewController.h"

@interface PUGameViewController : PUSuperViewController

@property (assign, nonatomic) PUEventType eventType;

- (void)reloadOnUserLocation;
- (void)reloadData;


@end
