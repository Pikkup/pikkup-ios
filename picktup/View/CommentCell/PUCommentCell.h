//
//  PUCommentCell.h
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUComment.h"
#import "NVDateLabel.h"
#import <UIImageView+AFNetworking.h>

@interface PUCommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet NVDateLabel *labelDate;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUserImage;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUserOverlay;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewMessageBackground;
@property (strong, nonatomic) IBOutlet UILabel *labelComment;

@property (strong, nonatomic) PUComment *comment;

+ (float)heightWithComment:(PUComment *)comment;

@end
