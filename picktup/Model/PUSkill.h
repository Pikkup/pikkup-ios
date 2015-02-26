//
//  PUSkill.h
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUObject.h"

@interface PUSkill : PUObject

@property (copy, nonatomic) NSString *skillName;
@property (assign, nonatomic) int skillLevel;
@property (assign, nonatomic) int skillId;
@property (assign, nonatomic) int skillGameTypeId;
@property (assign, nonatomic) BOOL skillNotify;

- (instancetype)initWithDictionary:(NSDictionary*)rawSkill;

@end
