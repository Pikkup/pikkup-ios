//
//  PUMessage.m
//  picktup
//
//  Created by Josip Cavar on 26/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUMessage.h"

@implementation PUMessage

- (instancetype)initWithDictionary:(NSDictionary*)rawMessage {
    
    self = [super init];
    if (self) {
        _messageId = [rawMessage[@"messageID"] integerValue];
        _messageText = rawMessage[@"message"];
        _messageTimeAgo = rawMessage[@"timeAgo"];
        NSDictionary *rawUserFrom = rawMessage[@"fromUser"];
        _userFrom = [[PUUser alloc] initWithDictionary:rawUserFrom];
        NSDictionary *rawUserTo = rawMessage[@"toUser"];
        _userTo = [[PUUser alloc] initWithDictionary:rawUserTo];
    }
    return self;
}

@end
