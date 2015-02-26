//
//  PUUserInfoTableViewCell.h
//  picktup
//
//  Created by Planet 1107 on 21/07/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

@class PUUser;

@interface PUUserInfoTableViewCell : UITableViewCell

@property (strong, nonatomic) PUUser *user;
@property (assign, nonatomic) BOOL shouldShowFollowUnfollowButton;

@end
