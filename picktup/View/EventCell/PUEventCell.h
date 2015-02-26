//
//  PUEventCell.h
//  picktup
//
//  Created by Planet 1107 on 10/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUEvent.h"

@interface PUEventCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelEventName;
@property (strong, nonatomic) IBOutlet UILabel *labelEventTime;
@property (strong, nonatomic) PUEvent *event;

@end
