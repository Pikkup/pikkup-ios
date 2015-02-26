//
//  PUCalloutView.m
//  picktup
//
//  Created by Josip Cavar on 23/07/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUCalloutView.h"
#import "PUEvent.h"

@interface PUCalloutView ()

@property (weak, nonatomic) IBOutlet UILabel *labelParkName;

@end

@implementation PUCalloutView

- (void)setEvent:(PUEvent *)event {
    
    _event = event;
    self.labelParkName.text = [@"Park: " stringByAppendingString:self.event.park.title];
}

@end
