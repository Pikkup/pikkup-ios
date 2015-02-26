//
//  PUMessageTableViewCell.h
//  picktup
//
//  Created by Josip Cavar on 26/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUMessage.h"
#import "NVDateLabel.h"
#import <UIImageView+AFNetworking.h>

@interface PUMessageCell : UITableViewCell

@property (strong, nonatomic) PUMessage *message;

+ (float)heightWithMessage:(PUMessage *)message;

@end
