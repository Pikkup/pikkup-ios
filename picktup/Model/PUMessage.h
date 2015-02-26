//
//  PUMessage.h
//  picktup
//
//  Created by Josip Cavar on 26/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUObject.h"
#import "PUUser.h"

@interface PUMessage : PUObject

@property (nonatomic) NSUInteger messageId;
@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) NSDate *messageDate;
@property (strong, nonatomic) NSString *messageTimeAgo;
@property (strong, nonatomic) PUUser *userTo;
@property (strong, nonatomic) PUUser *userFrom;

- (instancetype)initWithDictionary:(NSDictionary*)rawMessage;

@end
