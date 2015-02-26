//
//  PUInvite.h
//  picktup
//
//  Created by Josip Cavar on 04/09/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUObject.h"

@class PUUser;
@class PUEvent;

@interface PUInvite : PUObject

@property (strong, nonatomic) PUEvent *event;
@property (strong, nonatomic) PUUser *fromUser;
@property (assign, nonatomic) int toUserId;
@property (assign, nonatomic) int inviteId;
@property (assign, nonatomic) int inviteStatusId;

- (instancetype)initWithDictionary:(NSDictionary*)rawSkill;

@end
