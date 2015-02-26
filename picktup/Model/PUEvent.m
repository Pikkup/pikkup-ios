//
//  PUEvent.m
//  picktup
//
//  Created by Planet 1107 on 05/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUEvent.h"

@implementation PUEvent

- (instancetype)initWithDictionary:(NSDictionary*)rawEvent {
    
    self = [super init];
    if (self && rawEvent.count > 1) {
        _eventId = [rawEvent[@"eventID"] unsignedIntegerValue];
        _eventType = (PUEventType)[rawEvent[@"gameTypeID"] integerValue];
        _eventMaxPlayers = [rawEvent[@"maxPlayers"] unsignedIntegerValue];

        NSString *rawDate = rawEvent[@"startDate"];
        if (rawDate.length) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            _eventStartDate = [dateFormatter dateFromString:rawDate];
        }
        
        rawDate = rawEvent[@"endDate"];
        if (rawDate.length) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            _eventEndDate = [dateFormatter dateFromString:rawDate];
        }
        _eventDescription = rawEvent[@"description"];
        
        double latitude = [rawEvent[@"latitude"] isKindOfClass:NSNumber.class] ? [rawEvent[@"latitude"] doubleValue] : 0;
        double longitude = [rawEvent[@"longitude"] isKindOfClass:NSNumber.class] ? [rawEvent[@"longitude"] doubleValue] : 0;
        if (!latitude) {
            latitude = [rawEvent[@"latitude"] isKindOfClass:NSString.class] ? [rawEvent[@"latitude"] doubleValue] : 0;
        }
        if (!longitude) {
            longitude = [rawEvent[@"longitude"] isKindOfClass:NSString.class] ? [rawEvent[@"longitude"] doubleValue] : 0;
        }
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        _park = [[PUPark alloc] initWithDictionary:@{@"parkID" : rawEvent[@"parkID"],
                                                     @"name" : rawEvent[@"parkName"],
                                                     @"latitude" : rawEvent[@"latitude"],
                                                     @"longitude" : rawEvent[@"longitude"]}];
        _title = _park.title;
        _subtitle = _park.subtitle;
    }
    return self;
}

- (NSString*)eventName {
    
    if (self.eventType == 0) {
        return @"Unknown";
    } else if (self.eventType == 1) {
        return @"All";
    } else if (self.eventType < kPUGames.count + 2){
        return [kPUGames objectAtIndex:self.eventType - 2];
    } else {
        return @"Unknown";
    }
}

@end
