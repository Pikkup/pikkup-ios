//
//  PUUser.h
//  picktup
//
//  Created by Planet 1107 on 03/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUObject.h"
#import <CoreLocation/CoreLocation.h>

@interface PUUser : PUObject <NSCoding>

@property (nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userFullName;
@property (strong, nonatomic) NSString *userImagePath;
@property (strong, nonatomic) NSString *userSmallImagePath;
@property (strong, nonatomic) NSString *userHomePark;
@property (strong, nonatomic) NSString *userFavoriteSport;
@property (strong, nonatomic) NSString *userFavoriteTeams;
@property (strong, nonatomic) NSString *userFavoritePlayer;
@property (strong, nonatomic) NSArray *userSkills;
@property (assign, nonatomic) NSInteger following;
@property (assign, nonatomic) NSInteger follower;
@property (assign, nonatomic) CLLocationCoordinate2D userLocation;

- (instancetype)initWithDictionary:(NSDictionary*)rawUser;

@end
