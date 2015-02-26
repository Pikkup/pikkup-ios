//
//  PUSkill.m
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSkill.h"

@implementation PUSkill

- (instancetype)initWithDictionary:(NSDictionary*)rawSkill {
    
    self = [super init];
    if (self) {
        
        _skillId = [rawSkill[@"skillID"] intValue];
        _skillName = rawSkill[@"name"];
        _skillLevel = [rawSkill[@"skill"] intValue];
        _skillGameTypeId = [rawSkill[@"gameTypeID"] intValue];
        _skillNotify = [rawSkill[@"notification"] boolValue];
    }
    return self;
}


#pragma mark - NSCoding methods

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:self.skillId forKey:@"skillId"];
    [encoder encodeObject:self.skillName forKey:@"skillName"];
    [encoder encodeInt:self.skillLevel forKey:@"skillLavel"];
    [encoder encodeInt:self.skillGameTypeId forKey:@"gameTypeID"];
    [encoder encodeBool:self.skillNotify forKey:@"notification"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {
        self.skillId = [decoder decodeIntForKey:@"skillId"];
        self.skillName = [decoder decodeObjectForKey:@"skillName"];
        self.skillLevel = [decoder decodeIntForKey:@"skillLavel"];
        self.skillGameTypeId = [decoder decodeIntForKey:@"gameTypeID"];
        self.skillNotify = [decoder decodeBoolForKey:@"notification"];
    }
    return self;
}

@end
