//
//  PUConnect.h
//  picktup
//
//  Created by Planet 1107 on 03/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#define kPUBaseLink @"http://planet1107-solutions.net/pikup/"
#define kAPIKey @"@#WLiV!SD)=jge{09rfa(XCYXIRIFJDQ#_r9ZWEXYCJ#%#q"
#define kConnectionTimeout 60
#define kCompressionQuality 1.0f

#import "PUUser.h"
#import "PUMessage.h"
#import "PUEvent.h"
#import "PUPark.h"
#import "PUComment.h"

enum PUServerResponse {
    OK = 200,
    CREATED = 201,
    BAD_REQUEST = 400,
    UNAUTHORIZED = 401,
    NOT_FOUND = 404,
    NOT_ACCEPTABLE = 406,
    CONFLICT = 409,
    EXPECTATION_FAILED = 417,
    NO_CONNECTION = -1,
    SERVICE_UNAVAILABLE = 500,
    UNKNOWN_ERROR = 0
}; typedef enum PUServerResponse PUServerResponse;

@interface PUConnect : NSObject {
    AFHTTPSessionManager *sessionManager;
}

@property (readonly) PUUser *user;

+ (PUConnect*)sharedConnect;

- (void)registerWithUsername:(NSString*)username
                    fullName:(NSString*)fullName
                    password:(NSString*)password
               facebookToken:(NSString *)facebookToken
                    latitude:(double)latitude
                   longitude:(double)longitude
                       image:(NSData *)imageData
                   onSuccess:(void (^)(PUUser *user))success
                   onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)updateProfileWithUsername:(NSString*)username
                         fullName:(NSString*)fullName
                         homePark:(NSString*)homePark
                    favoriteSport:(NSString*)favoriteSport
                     favoriteTeams:(NSString*)favoriteTeams
                   favoritePlayer:(NSString*)favoritePlayer
                    facebookToken:(NSString*)facebookToken
                            image:(NSData *)image
                        onSuccess:(void (^)(PUUser *user))success
                        onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)loginWithUsername:(NSString*)username
                 password:(NSString*)password
                onSuccess:(void (^)(PUUser *user))success
                onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)loginWithFacebookToken:(NSString *)token
                     onSuccess:(void (^)(PUUser *user))success
                     onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)usersForSearchText:(NSString*)searchText
                      page:(NSUInteger)page
                     count:(NSUInteger)count
                 onSuccess:(void (^)(NSMutableArray *users))success
                 onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)usersForEvent:(PUEvent*)event
                 page:(NSUInteger)page
                count:(NSUInteger)count
            onSuccess:(void (^)(NSMutableArray *users))success
            onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)addSkillLevel:(int)skillLevel
         forEventType:(PUEventType)eventType
               notify:(BOOL)notify
         onCompletion:(void (^)(PUUser *user, PUServerResponse serverResponseCode))completion;

- (void)messagesPage:(NSUInteger)page
               count:(NSUInteger)count
           onSuccess:(void (^)(NSMutableArray *messages))success
           onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)sendMessage:(NSString*)messageText
            toUsers:(NSArray*)users
          onSuccess:(void (^)(NSMutableArray *messages))success
          onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)conversationWithUser:(PUUser*)user
                        page:(NSUInteger)page
                       count:(NSUInteger)count
                   onSuccess:(void (^)(NSMutableArray *messages))success
                   onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)eventsWithEventType:(PUEventType)eventType
                   latitude:(double)latitude
                  longitude:(double)longitude
                     radius:(NSUInteger)radius
                  startDate:(NSDate*)startDate
                    endDate:(NSDate*)endDate
                  onSuccess:(void (^)(NSMutableArray *parks))success
                  onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)addEventWithEventType:(PUEventType)eventType
                  description:(NSString*)description
                   maxPlayers:(NSUInteger)maxPlayers
                    startDate:(NSDate*)startDate
                      endDate:(NSDate*)endDate
                       toPark:(PUPark*)park
                    onSuccess:(void (^)(PUEvent *event))success
                    onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)eventsForPark:(PUPark *)park
                 page:(NSUInteger)page
                count:(NSUInteger)count
            onSuccess:(void (^)(NSMutableArray *events))success
            onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)joinEvent:(PUEvent*)event
     onCompletion:(void (^)(PUServerResponse serverResponseCode))completion;

- (void)addParkWithName:(NSString*)parkName
                 rating:(NSUInteger)parkRating
               latitude:(double)latitude longitude:(double)longitude
              onSuccess:(void (^)(PUPark *park))success
              onFaliure:(void (^)(PUServerResponse serverResponseCode, NSString *message))faliure;

- (void)followUser:(PUUser*)user
      onCompletion:(void (^)(PUServerResponse serverResponseCode))completion;

- (void)unfollowUser:(PUUser*)user
        onCompletion:(void (^)(PUServerResponse serverResponseCode))completion;

- (void)followersForUser:(PUUser*)user
                    page:(NSUInteger)page
                   count:(NSUInteger)count
               onSuccess:(void (^)(NSMutableArray *users))success
               onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)followingForUser:(PUUser*)user
                    page:(NSUInteger)page
                   count:(NSUInteger)count
               onSuccess:(void (^)(NSMutableArray *users))success
               onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)addComment:(NSString*)commentText
           toEvent:(PUEvent*)event
      onCompletion:(void (^)(PUServerResponse serverResponseCode))completion;

- (void)commentsForEvent:(PUEvent*)event
                    page:(NSUInteger)page
                   count:(NSUInteger)count
               onSuccess:(void (^)(NSMutableArray *comments))success
               onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)deleteComment:(PUComment*)comment
         onCompletion:(void (^)(PUServerResponse serverResponseCode))completion;

- (void)eventsForCurrentUserPage:(NSUInteger)page
                           count:(NSUInteger)count
                       onSuccess:(void (^)(NSMutableArray *events))success
                       onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)sendInviteToUser:(PUUser *)user
                forEvent:(PUEvent *)event
               onSuccess:(void (^)())success
               onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)setInviteStatusForInviteWithId:(NSString *)inviteId
                                status:(NSString *)iviteStatusId
                             onSuccess:(void (^)(int inviteStatusID))success
                             onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)invitesForCurrentUserPage:(NSUInteger)page
                            count:(NSUInteger)count
                        onSuccess:(void (^)(NSMutableArray *events))success
                        onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)setDeviceToken:(NSString *)deviceToken
             onSuccess:(void (^)())success
             onFaliure:(void (^)(PUServerResponse serverResponseCode))faliure;

- (void)logout;

@end
