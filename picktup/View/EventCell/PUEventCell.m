//
//  PUEventCell.m
//  picktup
//
//  Created by Planet 1107 on 10/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUEventCell.h"

@implementation PUEventCell

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (self.event) {
        self.labelEventName.text = [NSString stringWithFormat:@"%@ - %@", self.event.eventName, self.event.park.title];
        if (self.event.eventStartDate) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MMM d, yyyy, hh:mm a";
            self.labelEventTime.text = [dateFormatter stringFromDate:self.event.eventStartDate];
        }
    }
}

@end
