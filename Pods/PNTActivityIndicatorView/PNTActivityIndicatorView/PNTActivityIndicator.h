//
//  PNTActivityIndicator.m
//
//  Copyright 2014 Planet1107.
//

#import <UIKit/UIKit.h>

#define kDefaultSpinDurationTime 0.8f

@class MBProgressHUD;

@interface PNTActivityIndicator : UIView

@property (assign) float spinDurationTime;

- (id)initWithFrame:(CGRect)frame;
- (void)startAnimating;
- (void)stopAnimating;

+ (MBProgressHUD *)customActivityHUD;

@end
