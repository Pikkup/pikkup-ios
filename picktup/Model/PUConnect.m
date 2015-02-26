//
//  PUConnect.m
//  picktup
//
//  Created by Planet 1107 on 03/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUConnect.h"
#import "PUInvite.h"

static PUConnect *sharedConnect;

@implementation PUConnect

+ (PUConnect*)sharedConnect {
    
    if (!sharedConnect) {
        sharedConnect = [[PUConnect alloc] init];
    }
    return sharedConnect;
}

- (id)init {
    
    self = [super init];
    if (self) {
        sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kPUBaseLink]];
        [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        //[sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [sessionManager.requestSerializer setValue:kAPIKey forHTTPHeaderField:@"api_key"];
        
        NSData *archivedUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
        if (archivedUser) {
            _user = [NSKeyedUnarchiver unarchiveObjectWithData:archivedUser];
        }
    }
    return self;
}

- (void)saveCurrentUser {
    
    if (self.user) {
        NSData *archivedUser = [NSKeyedArchiver archivedDataWithRootObject:self.user];
        [[NSUserDefaults standardUserDefaults] setObject:archivedUser forKey:@"user"];
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
        [[PUConnect sharedConnect] setDeviceToken:deviceToken onSuccess:^{ } onFaliure:^(PUServerResponse serverResponseCode) { }];
    }
}

- (void)removeCurrentUser {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _user = nil;
    [[PUConnect sharedConnect] setDeviceToken:nil onSuccess:^{ } onFaliure:^(PUServerResponse serverResponseCode) { }];
}

- (void)registerWithUsername:(NSString*)username
                    fullName:(NSString*)fullName
                    password:(NSString*)password
               facebookToken:(NSString *)facebookToken
                    latitude:(double)latitude
                   longitude:(double)longitude
                       image:(NSData *)imageData
                   onSuccess:(void (^)(PUUser *user))success
                   onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = username ? username : @"";
    parameters[@"password"] = password ? password : @"";
    parameters[@"facebookToken"] = facebookToken ? facebookToken : @"";
    parameters[@"fullName"] = fullName ? fullName : @"";
    if (latitude != 0.0 && longitude != 0.0) {
        parameters[@"latitude"] = @(latitude);
        parameters[@"longitude"] = @(longitude);
    }
    [sessionManager POST:@"api/register/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imageData) {
            [formData appendPartWithFileData:imageData name:@"imageUrl" fileName:@"profile.jpeg" mimeType:@"image/jpeg"];
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *rawUser = responseObject[@"item"];
        int status = (int)[responseObject[@"status"] integerValue];
        if (status == 0) {
            PUUser *user = [[PUUser alloc] initWithDictionary:rawUser];
            _user = user;
            [self saveCurrentUser];
            success(user);
        } else {
            if ([responseObject respondsToSelector:@selector(description)]) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[responseObject description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            faliure(UNKNOWN_ERROR);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        faliure(UNKNOWN_ERROR);
    }];
}

- (void)updateProfileWithUsername:(NSString*)username
                         fullName:(NSString*)fullName
                         homePark:(NSString*)homePark
                    favoriteSport:(NSString*)favoriteSport
                     favoriteTeams:(NSString*)favoriteTeams
                   favoritePlayer:(NSString*)favoritePlayer
                    facebookToken:(NSString*)facebookToken
                            image:(NSData *)image
                        onSuccess:(void (^)(PUUser *user))success
                        onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (username.length) {
        parameters[@"username"] = username;
    }
    if (fullName.length) {
        parameters[@"fullName"] = fullName;
    }
    if (homePark.length) {
        parameters[@"homePark"] = homePark;
    }
    if (favoriteSport.length) {
        parameters[@"favoriteSport"] = favoriteSport;
    }
    if (favoriteTeams.length) {
        parameters[@"favoriteTeams"] = favoriteTeams;
    }
    if (favoritePlayer.length) {
        parameters[@"favoritePlayer"] = favoritePlayer;
    }
    if (facebookToken.length) {
        parameters[@"facebookToken"] = facebookToken;
    }
    
    parameters[@"userID"] = @(self.user.userId);

    [sessionManager POST:@"api/updateProfile/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (image) {
            [formData appendPartWithFileData:image name:@"imageUrl" fileName:@"profile.jpeg" mimeType:@"image/jpeg"];
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *rawUser = responseObject[@"item"];
        int status = (int)[responseObject[@"status"] integerValue];
        if (status == 0) {
            PUUser *user = [[PUUser alloc] initWithDictionary:rawUser];
            _user = user;
            [self saveCurrentUser];
            success(user);
        } else {
            faliure(UNKNOWN_ERROR);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        faliure(UNKNOWN_ERROR);
    }];
}

- (void)loginWithUsername:(NSString*)username password:(NSString*)password onSuccess:(void (^)(PUUser *user))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (username.length && password.length) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"username"] = username;
        parameters[@"password"] = password;
        [sessionManager POST:@"api/login/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *rawUser = responseObject[@"item"];
            int status = (int)[responseObject[@"status"] integerValue];
            if (status == 0 && [rawUser isKindOfClass:[NSDictionary class]] && rawUser.count) {
                PUUser *user = [[PUUser alloc] initWithDictionary:rawUser];
                _user = user;
                [self saveCurrentUser];
                success(user);
            } else {
                if ([responseObject respondsToSelector:@selector(description)]) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:[responseObject description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
                faliure(UNKNOWN_ERROR);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No parameters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        faliure(BAD_REQUEST);
    }
}

- (void)loginWithFacebookToken:(NSString *)token onSuccess:(void (^)(PUUser *user))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (token.length) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userToken"] = token;
        [sessionManager POST:@"api/loginToken/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *rawUser = responseObject[@"item"];
            int status = (int)[responseObject[@"status"] integerValue];
            if (status == 0 && [rawUser isKindOfClass:[NSDictionary class]] && rawUser.count) {
                PUUser *user = [[PUUser alloc] initWithDictionary:rawUser];
                _user = user;
                [self saveCurrentUser];
                success(user);
            } else {
                faliure(UNKNOWN_ERROR);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
            faliure((PUServerResponse)response.statusCode);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)userForUserId:(NSInteger)userId onSuccess:(void (^)(PUUser *user))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(userId);
        if (self.user.userId) {
            parameters[@"forUserID"] = @(self.user.userId);
        }
        [sessionManager POST:@"api/profile/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *rawUser = responseObject[@"user"];
            PUUser *user = [[PUUser alloc] initWithDictionary:rawUser];
            _user = user;
            [self saveCurrentUser];
            success(user);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)usersForSearchText:(NSString*)searchText page:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *users))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && searchText.length && page > 0 && count > 0) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"searchTerm"] = searchText;
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/users/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSArray *rawUsers = responseObject[@"items"];
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                PUUser *user = [[PUUser alloc] initWithDictionary:rawUser];
                [users addObject:user];
            }
            success(users);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)usersForEvent:(PUEvent*)event page:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *users))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && event.eventId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"eventID"] = @(event.eventId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getUsersForEvent/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSArray *rawUsers = responseObject[@"items"];
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                PUUser *user = [[PUUser alloc] initWithDictionary:rawUser[@"item"]];
                [users addObject:user];
            }
            success(users);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)addSkillLevel:(int)skillLevel forEventType:(PUEventType)eventType notify:(BOOL)notify onCompletion:(void (^)(PUUser *user, PUServerResponse serverResponseCode))completion {
    
    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"gameTypeID"] = @(eventType);
        parameters[@"skillLevel"] = @(skillLevel);
        parameters[@"notification"] = @(notify);
        
        [sessionManager POST:@"api/addSkill/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {

            PUUser *user = [[PUUser alloc] initWithDictionary:responseObject[@"item"]];
            _user = user;
            [self saveCurrentUser];
            completion(user, OK);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completion(nil, UNKNOWN_ERROR);
        }];
    } else {
        completion(nil, BAD_REQUEST);
    }
}


- (void)messagesPage:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *messages))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && page > 0 && count > 0) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getMessages/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawMessages = responseObject[@"items"];
            if ([rawMessages isKindOfClass:[NSArray class]]) {
                NSMutableArray *messages = [NSMutableArray arrayWithCapacity:rawMessages.count];
                for (NSDictionary *rawMessage in rawMessages) {
                    PUMessage *message = [[PUMessage alloc] initWithDictionary:rawMessage];
                    [messages addObject:message];
                }
                success(messages);
            } else {
                faliure(UNKNOWN_ERROR);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)sendMessage:(NSString*)messageText toUsers:(NSArray*)users onSuccess:(void (^)(NSMutableArray *messages))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && messageText.length && users.count) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"fromUserID"] = @(self.user.userId);
        
        NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:users.count];
        for (PUUser *user in users) {
            [userIds addObject:@(user.userId)];
        }
        if (userIds.count == 1) {
            NSInteger userId = [userIds[0] integerValue];
            parameters[@"toUsers"] = [NSString stringWithFormat:@"%ld", (long)userId];
        } else {
            parameters[@"toUsers"] = [userIds componentsJoinedByString:@","];
        }
        
        parameters[@"message"] = messageText;
        
        [sessionManager POST:@"api/sendMessageToUsers/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject[@"status"] integerValue] == 0) {
                NSArray *rawMessages = responseObject[@"items"];
                NSMutableArray *messages = [NSMutableArray arrayWithCapacity:rawMessages.count];
                for (NSDictionary *rawMessage in rawMessages) {
                    PUMessage *message = [[PUMessage alloc] initWithDictionary:rawMessage];
                    [messages addObject:message];
                }
                success(messages);
            } else {
                faliure(UNKNOWN_ERROR);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)conversationWithUser:(PUUser*)user page:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *messages))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"fromUserID"] = @(self.user.userId);
        parameters[@"toUserID"] = @(user.userId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getConversation/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawMessages = responseObject[@"items"];
            NSMutableArray *messages = [NSMutableArray arrayWithCapacity:rawMessages.count];
            for (NSDictionary *rawMessage in rawMessages) {
                PUMessage *message = [[PUMessage alloc] initWithDictionary:rawMessage];
                [messages addObject:message];
            }
            success(messages);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)eventsWithEventType:(PUEventType)eventType latitude:(double)latitude longitude:(double)longitude radius:(NSUInteger)radius startDate:(NSDate*)startDate endDate:(NSDate*)endDate onSuccess:(void (^)(NSMutableArray *parks))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        //parameters[@"fromUserID"] = @(self.user.userId);
        parameters[@"gameTypeID"] = @(eventType);
        parameters[@"lat"] = @(latitude);
        parameters[@"long"] = @(longitude);
        parameters[@"distanceMeter"] = @(radius);
        
        [sessionManager POST:@"api/getEventsAround/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawEvents = responseObject[@"items"];
            if ([rawEvents isKindOfClass:[NSArray class]]) {
                NSMutableArray *events = [NSMutableArray arrayWithCapacity:rawEvents.count];
                for (NSDictionary *rawEvent in rawEvents) {
                    PUEvent *event = [[PUEvent alloc] initWithDictionary:rawEvent];
                    if ([event.eventStartDate timeIntervalSinceDate:startDate] >= 0 && [event.eventEndDate timeIntervalSinceDate:endDate] < 0) {
                        [events addObject:event];
                    }
                }
                success(events);
            } else {
                faliure(UNKNOWN_ERROR);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)addEventWithEventType:(PUEventType)eventType description:(NSString*)description maxPlayers:(NSUInteger)maxPlayers startDate:(NSDate*)startDate endDate:(NSDate*)endDate toPark:(PUPark*)park onSuccess:(void (^)(PUEvent *event))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"gameTypeID"] = @(eventType);
        parameters[@"description"] = description;
        parameters[@"maxPlayers"] = @(maxPlayers);
        parameters[@"startDate"] = [dateFormatter stringFromDate:startDate];
        parameters[@"endDate"] = [dateFormatter stringFromDate:endDate];
        parameters[@"parkID"] = @(park.parkId);
        
        [sessionManager POST:@"api/addEvent/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *rawEvent = responseObject[@"item"];
            if (rawEvent) {
                PUEvent *event = [[PUEvent alloc] initWithDictionary:rawEvent];
                success(event);
            } else {
                success(nil);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)eventsForPark:(PUPark *)park page:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *events))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {

    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        //parameters[@"fromUserID"] = @(self.user.userId);
        parameters[@"parkID"] = @(park.parkId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getEventsForPark/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawEvents = responseObject[@"items"];
            if ([rawEvents isKindOfClass:[NSArray class]]) {
                NSMutableArray *events = [NSMutableArray arrayWithCapacity:rawEvents.count];
                for (NSDictionary *rawEvent in rawEvents) {
                    PUEvent *event = [[PUEvent alloc] initWithDictionary:rawEvent];
                    [events addObject:event];
                }
                success(events);
            } else {
                faliure(NOT_FOUND);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)joinEvent:(PUEvent*)event onCompletion:(void (^)(PUServerResponse serverResponseCode))completion {
    
    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"eventID"] = @(event.eventId);
        
        [sessionManager POST:@"api/joinEvent/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            completion(OK);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completion(UNKNOWN_ERROR);
        }];
    } else {
        completion(BAD_REQUEST);
    }
}

- (void)addParkWithName:(NSString*)parkName rating:(NSUInteger)parkRating latitude:(double)latitude longitude:(double)longitude onSuccess:(void (^)(PUPark *park))success onFaliure:(void (^)(PUServerResponse serverResponseCode, NSString *message))faliure {
    
    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"name"] = parkName;
        parameters[@"rating"] = @(parkRating);
        parameters[@"latitude"] = @(latitude);
        parameters[@"longitude"] = @(longitude);
        
        [sessionManager POST:@"api/addPark/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *rawPark = responseObject[@"item"];
            if ([rawPark isKindOfClass:[NSDictionary class]] && rawPark.count) {
                PUPark *park = [[PUPark alloc] initWithDictionary:rawPark];
                success(park);
            } else {
                rawPark = responseObject[@"park"];
                if ([rawPark isKindOfClass:[NSDictionary class]] && rawPark.count) {
                    PUPark *park = [[PUPark alloc] initWithDictionary:rawPark];
                    success(park);
                } else {
                    faliure(UNKNOWN_ERROR, responseObject[@"message"]);
                }
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR, @"Unknown error");
        }];
    } else {
        faliure(BAD_REQUEST, @"Bad request");
    }
}

- (void)followUser:(PUUser*)user onCompletion:(void (^)(PUServerResponse serverResponseCode))completion {
    
    if (self.user.userId && user.userId && self.user.userId != user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"followingID"] = @(user.userId);
        
        [sessionManager POST:@"api/setFollow/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            completion(OK);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completion(UNKNOWN_ERROR);
        }];
    } else {
        completion(BAD_REQUEST);
    }
}

- (void)unfollowUser:(PUUser*)user onCompletion:(void (^)(PUServerResponse serverResponseCode))completion {
    
    if (self.user.userId && user.userId && self.user.userId != user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"followingID"] = @(user.userId);
        
        [sessionManager POST:@"api/removeFollow/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            completion(OK);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completion(UNKNOWN_ERROR);
        }];
    } else {
        completion(BAD_REQUEST);
    }
}

- (void)followersForUser:(PUUser*)user page:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *users))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"forUserID"] = @(self.user.userId);
        parameters[@"userID"] = @(user.userId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getFollowers/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawUsers = responseObject[@"items"];
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                PUUser *user = [[PUUser alloc] initWithDictionary:rawUser];
                [users addObject:user];
            }
            success(users);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)followingForUser:(PUUser*)user page:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *users))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"forUserID"] = @(self.user.userId);
        parameters[@"userID"] = @(user.userId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getFollowing/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawUsers = responseObject[@"items"];
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                PUUser *user = [[PUUser alloc] initWithDictionary:rawUser];
                [users addObject:user];
            }
            success(users);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)addComment:(NSString*)commentText toEvent:(PUEvent*)event onCompletion:(void (^)(PUServerResponse serverResponseCode))completion {
    
    if (self.user.userId && commentText.length && event.eventId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"commentText"] = commentText;
        parameters[@"eventID"] = @(event.eventId);
        
        [sessionManager POST:@"api/addComment/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            completion(OK);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completion(UNKNOWN_ERROR);
        }];
    } else {
        completion(BAD_REQUEST);
    }
}

- (void)commentsForEvent:(PUEvent*)event page:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *comments))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (event.eventId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"eventID"] = @(event.eventId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getCommentsForEvent/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawComments = responseObject[@"items"];
            NSMutableArray *comments = [NSMutableArray arrayWithCapacity:rawComments.count];
            for (NSDictionary *rawComment in rawComments) {
                PUComment *comment = [[PUComment alloc] initWithDictionary:rawComment];
                [comments addObject:comment];
            }
            success(comments);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)deleteComment:(PUComment*)comment onCompletion:(void (^)(PUServerResponse serverResponseCode))completion {
    
    if (comment.commentId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"commentID"] = @(comment.commentId);
        
        [sessionManager POST:@"api/deleteComment/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            completion(OK);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completion(UNKNOWN_ERROR);
        }];
    } else {
        completion(BAD_REQUEST);
    }
}

- (void)sendInviteToUser:(PUUser *)user forEvent:(PUEvent *)event onSuccess:(void (^)())success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && user != nil) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"fromUserID"] = @(self.user.userId);
        parameters[@"toUserID"] = @(user.userId);
        parameters[@"eventID"] = @(event.eventId);

        [sessionManager POST:@"api/sendInvite/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawMessages = responseObject[@"items"];
            NSMutableArray *messages = [NSMutableArray arrayWithCapacity:rawMessages.count];
            for (NSDictionary *rawMessage in rawMessages) {
                PUMessage *message = [[PUMessage alloc] initWithDictionary:rawMessage];
                [messages addObject:message];
            }
            success(messages);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)setInviteStatusForInviteWithId:(NSString *)inviteId status:(NSString *)iviteStatusId onSuccess:(void (^)(int inviteStatusID))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId && inviteId.length > 0) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"inviteStatusID"] = iviteStatusId;
        parameters[@"inviteID"] = inviteId;
        
        [sessionManager POST:@"api/setInviteStatus/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject[@"status"] integerValue] == 0) {
                success([responseObject[@"item"][@"inviteStatusID"] intValue]);
            } else {
                faliure(UNKNOWN_ERROR);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)invitesForCurrentUserPage:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *events))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        //parameters[@"fromUserID"] = @(self.user.userId);
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getInvitesForUser/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawEvents = responseObject[@"items"];
            if ([rawEvents isKindOfClass:[NSArray class]]) {
                NSMutableArray *events = [NSMutableArray arrayWithCapacity:rawEvents.count];
                for (NSDictionary *rawEvent in rawEvents) {
                    PUInvite *invite = [[PUInvite alloc] initWithDictionary:rawEvent];
                    [events addObject:invite];
                }
                success(events);
            } else {
                faliure(NOT_FOUND);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)eventsForCurrentUserPage:(NSUInteger)page count:(NSUInteger)count onSuccess:(void (^)(NSMutableArray *events))success onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        //parameters[@"fromUserID"] = @(self.user.userId);
        parameters[@"userID"] = @(self.user.userId);
        parameters[@"page"] = @(page);
        parameters[@"take"] = @(count);
        
        [sessionManager POST:@"api/getEventsForUser/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rawEvents = responseObject[@"items"];
            if ([rawEvents isKindOfClass:[NSArray class]]) {
                NSMutableArray *events = [NSMutableArray arrayWithCapacity:rawEvents.count];
                for (NSDictionary *rawEvent in rawEvents) {
                    PUEvent *event = [[PUEvent alloc] initWithDictionary:rawEvent[@"item"]];
                    [events addObject:event];
                }
                success(events);
            } else {
                faliure(NOT_FOUND);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)setDeviceToken:(NSString *)deviceToken
             onSuccess:(void (^)())success
             onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure {
    
    if (self.user.userId) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        //parameters[@"fromUserID"] = @(self.user.userId);
        parameters[@"userID"] = @(self.user.userId);
        
        NSString *path;
        if (deviceToken.length) {
            path = @"api/setDeviceToken/";
            parameters[@"deviceToken"] = deviceToken;
        } else {
            path = @"api/removeDeviceToken/";
        }
        
        [sessionManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            int status = [responseObject[@"status"] intValue];
            if (status == 0) {
                success();
            } else {
                faliure(UNKNOWN_ERROR);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            faliure(UNKNOWN_ERROR);
        }];
    } else {
        faliure(BAD_REQUEST);
    }
}

- (void)logout {
    
    [self removeCurrentUser];
}

@end
