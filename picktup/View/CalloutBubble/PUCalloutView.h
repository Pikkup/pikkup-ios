//
//  PUCalloutView.h
//  picktup
//
//  Created by Josip Cavar on 23/07/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

@class PUEvent;

@interface PUCalloutView : UIView

@property (weak, nonatomic) IBOutlet UIButton *buttonAccessory;
@property (strong, nonatomic) PUEvent *event;

@end
