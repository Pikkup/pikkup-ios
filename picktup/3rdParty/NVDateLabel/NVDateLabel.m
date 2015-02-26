//
//  NVDateLabel.m
//
//  Created by Nikša Vlahušić on 12/11/13.
//
//

#import "NVDateLabel.h"

@implementation NVDateLabel

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSString *)timeAgoFromDate:(NSDate*)date {
    
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSDate *todayDate = [NSDate date];
    double secondsOffset = [timeZone secondsFromGMTForDate:todayDate];
    
    double ti = [date timeIntervalSinceDate:todayDate];
    ti += secondsOffset;
    ti = ti * -1;
    if (ti < 1) {
        return @"now";
    } else if (ti < 60) {
        return [NSString stringWithFormat:@"%ds", (int)ti];
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%dm", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%dh", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%dd", diff];
    } else if (ti < 31556926) {
        int diff = round(ti / 60 / 60 / 24 / 30);
        return [NSString stringWithFormat:@"%dmo", diff];
    } else {
        int diff = round(ti / 60 / 60 / 24 / 30 / 12);
        return [NSString stringWithFormat:@"%dy", diff];
    }
}

- (void)setTextWithDate:(NSDate*)date updateInterval:(NSTimeInterval)updateInterval {
    
    [self stopAutoUpdate];
    
    _date = date;
    _updateInterval = updateInterval;
    self.text = [self timeAgoFromDate:self.date];
    timerRefresh = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(handleFireTimer:) userInfo:nil repeats:YES];
}

- (void)stopAutoUpdate {
    
    if ([timerRefresh isValid]) {
        [timerRefresh invalidate];
    }
    timerRefresh = nil;
}

- (void)handleFireTimer:(NSTimer*)timer {
    
    self.text = [self timeAgoFromDate:self.date];
}

- (void)dealloc {
    
    [self stopAutoUpdate];
}



@end
