//
//  PUInvite.m
//  picktup
//
//  Created by Josip Cavar on 04/09/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUInvite.h"
#import "PUUser.h"
#import "PUEvent.h"

@implementation PUInvite

- (instancetype)initWithDictionary:(NSDictionary*)rawSkill {
    
    self = [super init];
    if (self) {
        id event = rawSkill[@"event"];
        if ([event isKindOfClass:[NSDictionary class]]) {
            _event = [[PUEvent alloc] initWithDictionary:event];
        }
        _fromUser = [[PUUser alloc] initWithDictionary:rawSkill[@"fromUser"]];
        _inviteId = [rawSkill[@"inviteID"] intValue];
        _inviteStatusId = [rawSkill[@"inviteStatusID"] intValue];
        _toUserId = [rawSkill[@"toUserID"] intValue];
    }
    return self;
}

@end
