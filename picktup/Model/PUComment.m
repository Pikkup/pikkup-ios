//
//  PUComment.m
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUComment.h"

@implementation PUComment

- (instancetype)initWithDictionary:(NSDictionary*)rawComment {
    
    self = [super init];
    if (self) {
        
        _commentId = [rawComment[@"commentID"] integerValue];
        _commentText = rawComment[@"commentText"];
        
        NSString *rawDate = rawComment[@"commentDate"];
        if (rawDate.length) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            _commentDate = [dateFormatter dateFromString:rawDate];
        }
        
        NSDictionary *rawUser = rawComment[@"user"];
        if ([rawUser isKindOfClass:[NSDictionary class]]) {
            _user = [[PUUser alloc] initWithDictionary:rawUser];
        }
    }
    return self;
}

@end
