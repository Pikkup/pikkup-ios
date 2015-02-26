//
//  PUSkillCell.h
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUEvent.h"
#import "PUSkill.h"
#import "PUUser.h"

@protocol PUSkillCellDelegate <NSObject>

- (void)cell:(UITableViewCell *)cell didAddSkillToUser:(PUUser *)user;

@end

@interface PUSkillCell : UITableViewCell

@property (strong, nonatomic) PUSkill *skill;
@property (assign, nonatomic) PUEventType skillType;
@property (weak, nonatomic) id<PUSkillCellDelegate>delegate;
@property (assign, nonatomic) BOOL shouldShowSkillNotSet;

@end
