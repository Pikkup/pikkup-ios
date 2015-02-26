//
//  PUComment.h
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUObject.h"
#import "PUUser.h"

@interface PUComment : PUObject

- (instancetype)initWithDictionary:(NSDictionary*)rawComment;

@property (nonatomic) NSUInteger commentId;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSDate *commentDate;
@property (strong, nonatomic) PUUser *user;

@end
