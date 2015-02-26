//
//  PUUser.m
//  picktup
//
//  Created by Planet 1107 on 03/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUUser.h"
#import "PUSkill.h"

@implementation PUUser

- (instancetype)initWithDictionary:(NSDictionary*)rawUser {
    
    self = [super init];
    if (self) {
        _userId = [rawUser[@"userID"] integerValue];
        _username = rawUser[@"username"];
        _userFullName = rawUser[@"fullname"] ;
        _userImagePath = rawUser[@"imageUrl"] == [NSNull null] ? nil : rawUser[@"imageUrl"];
        _userSmallImagePath = rawUser[@"imageSmallUrl"] == [NSNull null] ? nil : rawUser[@"imageSmallUrl"];
        _userHomePark = rawUser[@"homePark"] == [NSNull null] ? nil : rawUser[@"homePark"];
        _userFavoriteSport = rawUser[@"favoriteSport"] == [NSNull null] ? nil : rawUser[@"favoriteSport"];
        _userFavoriteTeams = rawUser[@"favoriteTeams"] == [NSNull null] ? nil : rawUser[@"favoriteTeams"];
        _userFavoritePlayer = rawUser[@"favoritePlayer"] == [NSNull null] ? nil : rawUser[@"favoritePlayer"];
        
        NSArray *rawSkills = rawUser[@"skills"];
        NSMutableArray *skills = [[NSMutableArray alloc] initWithCapacity:rawSkills.count];
        for (NSDictionary *rawSkill in rawSkills) {
            [skills addObject:[[PUSkill alloc] initWithDictionary:rawSkill]];
        }
        _userSkills = skills;
        _following = [rawUser[@"following"] integerValue];
        _follower = [rawUser[@"follower"] integerValue];
        
        NSNumber *latitude = rawUser[@"latitude"];
        NSNumber *longitude = rawUser[@"longitude"];
        if ([latitude isKindOfClass:NSNumber.class] && [longitude isKindOfClass:NSNumber.class]) {
            _userLocation = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        }
    }
    return self;
}


#pragma mark - NSCoding methods

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInteger:self.userId forKey:@"userId"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.userFullName forKey:@"userFullName"];
    [encoder encodeObject:self.userImagePath forKey:@"userImagePath"];
    [encoder encodeObject:self.userHomePark forKey:@"userHomePark"];
    [encoder encodeObject:self.userFavoriteSport forKey:@"userFavoriteSport"];
    [encoder encodeObject:self.userFavoriteTeams forKey:@"userFavoriteTeams"];
    [encoder encodeObject:self.userFavoritePlayer forKey:@"userFavoritePlayer"];
    [encoder encodeObject:self.userSkills forKey:@"userSkills"];
    [encoder encodeDouble:self.userLocation.latitude forKey:@"latitude"];
    [encoder encodeDouble:self.userLocation.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {
        self.userId = [decoder decodeIntegerForKey:@"userId"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.userFullName = [decoder decodeObjectForKey:@"userFullName"];
        self.userImagePath = [decoder decodeObjectForKey:@"userImagePath"];
        self.userHomePark = [decoder decodeObjectForKey:@"userHomePark"];
        self.userFavoriteSport = [decoder decodeObjectForKey:@"userFavoriteSport"];
        self.userFavoriteTeams = [decoder decodeObjectForKey:@"userFavoriteTeams"];
        self.userFavoritePlayer = [decoder decodeObjectForKey:@"userFavoritePlayer"];
        self.userSkills = [decoder decodeObjectForKey:@"userSkills"];
        double latitude = [decoder decodeDoubleForKey:@"latitude"];
        double longitude = [decoder decodeDoubleForKey:@"longitude"];
        if (latitude != 0.0 && longitude != 0.0) {
            _userLocation = CLLocationCoordinate2DMake(latitude, longitude);
        }
    }
    return self;
}

@end
