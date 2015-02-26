//
//  PUPark.h
//  picktup
//
//  Created by Planet 1107 on 05/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUObject.h"
#import <MapKit/MapKit.h>

@interface PUPark : PUObject <MKAnnotation>

@property (nonatomic) NSUInteger parkId;
@property (nonatomic) NSUInteger parkRating;
@property (strong, nonatomic) NSString *parkImagePath;
@property (strong, nonatomic) NSDate *parkDate;

#pragma mark - MKAnntotation members

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

- (instancetype)initWithDictionary:(NSDictionary*)rawPark;

@end
