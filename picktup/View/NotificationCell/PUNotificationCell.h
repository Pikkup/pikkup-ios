//
//  PUNotificationCell.h
//  picktup
//
//  Created by Planet 1107 on 06/11/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUEvent.h"
#import "PUUser.h"
#import "PUSkill.h"

@protocol PUNotificationCellDelegate <NSObject>

- (void)cell:(UITableViewCell *)cell didChangeSkillNotifyToUser:(PUUser *)user;

@end

@interface PUNotificationCell : UITableViewCell

@property (assign, nonatomic) PUEventType skillType;
@property (strong, nonatomic) PUSkill *skill;
@property (weak, nonatomic) id<PUNotificationCellDelegate>delegate;

@end
