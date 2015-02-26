//
//  PUPark.m
//  picktup
//
//  Created by Planet 1107 on 05/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUPark.h"

@implementation PUPark

- (instancetype)initWithDictionary:(NSDictionary*)rawPark {
    
    self = [super init];
    if (self) {
        _parkId = [rawPark[@"parkID"] integerValue];
        _parkRating = [rawPark[@"rating"] integerValue];
        _parkImagePath = rawPark[@"imageUrl"];
        NSString *rawDate = rawPark[@"date"];
        if (rawDate.length) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            _parkDate = [dateFormatter dateFromString:rawDate];
        }
        
        _title = rawPark[@"name"];
        double latitude = [rawPark[@"latitude"] isKindOfClass:NSNumber.class] ? [rawPark[@"latitude"] doubleValue] : 0;
        double longitude = [rawPark[@"longitude"] isKindOfClass:NSNumber.class] ? [rawPark[@"longitude"] doubleValue] : 0;
        if (!latitude) {
            latitude = [rawPark[@"latitude"] isKindOfClass:NSString.class] ? [rawPark[@"latitude"] doubleValue] : 0;
        }
        if (!longitude) {
            longitude = [rawPark[@"longitude"] isKindOfClass:NSString.class] ? [rawPark[@"longitude"] doubleValue] : 0;
        }
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}

@end
