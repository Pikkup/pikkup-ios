//
//  PUEvent.h
//  picktup
//
//  Created by Planet 1107 on 05/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUObject.h"
#import <MapKit/MapKit.h>
#import "PUPark.h"

typedef NS_ENUM(NSUInteger, PUEventType) {
    PUEventTypeUnknown = 0,
    PUEventTypeAll = 1,
    PUEventTypeSoccer = 2,
    PUEventTypeBasketball = 3,
    PUEventTypeFootball = 4,
    PUEventTypeBaseball = 5,
    PUEventTypeSoftball = 6,
    PUEventTypeGolf = 7,
    PUEventTypeTennis = 8,
    PUEventTypeUltimateFrisbee = 9,
    PUEventTypeCricket = 10,
    PUEventTypeVolleyball = 11,
    PUEventTypeRacquetball = 12,
    PUEventTypeHandball = 13,
    PUEventTypeRugby = 14,
    PUEventTypeHockey = 15
};

#define kPUGames @[@"Soccer", @"Basketball", @"Football", @"Baseball", @"Softball", @"Golf", @"Tennis", @"Ultimate frisbee", @"Cricket", @"Volleyball", @"Racquetball", @"Handball", @"Rugby", @"Hockey"]

@interface PUEvent : PUObject <MKAnnotation>

@property (nonatomic) NSUInteger eventId;
@property (nonatomic) PUEventType eventType;
@property (nonatomic) NSUInteger eventMaxPlayers;
@property (strong, nonatomic) NSDate *eventStartDate;
@property (strong, nonatomic) NSDate *eventEndDate;
@property (strong, nonatomic) NSString *eventDescription;
@property (strong, nonatomic) PUPark *park;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

- (instancetype)initWithDictionary:(NSDictionary*)rawEvent;
- (NSString*)eventName;

@end
