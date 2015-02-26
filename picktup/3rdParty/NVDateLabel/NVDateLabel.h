//
//  NVDateLabel.h
//
//  Created by Nikša Vlahušić on 12/11/13.
//
//

#import <UIKit/UIKit.h>

@interface NVDateLabel : UILabel {
    NSTimer *timerRefresh;
}

@property (readonly, nonatomic) NSDate *date;
@property (readonly) NSTimeInterval updateInterval;

- (void)setTextWithDate:(NSDate*)date updateInterval:(NSTimeInterval)updateInterval;

@end
