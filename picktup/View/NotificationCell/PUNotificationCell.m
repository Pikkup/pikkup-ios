//
//  PUNotificationCell.m
//  picktup
//
//  Created by Planet 1107 on 06/11/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUNotificationCell.h"
#import "PUConnect.h"
#import "PUEvent.h"

@interface PUNotificationCell ()

@property (strong, nonatomic) IBOutlet UILabel *labelSkillType;
@property (strong, nonatomic) IBOutlet UISwitch *switchNotify;

@end

@implementation PUNotificationCell

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.switchNotify.on = self.skill.skillNotify;
}

- (void)setSkillType:(PUEventType)skillType {
    
    _skillType = skillType;
    if (_skillType > PUEventTypeAll) {
        self.labelSkillType.text = kPUGames[_skillType - 2];
    } else {
        self.labelSkillType.text = @"Unknown";
    }
}


#pragma mark - Action methods

- (IBAction)valueChangedInSwitch:(UISwitch *)sender {
    
    int skillLevel = self.skill.skillLevel;
    if (skillLevel == 0) {
        skillLevel = 1;
    }
    if (self.switchNotify.on) {
        
        self.skill.skillNotify = YES;
        
        [[PUConnect sharedConnect] addSkillLevel:skillLevel forEventType:self.skillType notify:self.skill.skillNotify onCompletion:^(PUUser *user, PUServerResponse serverResponseCode) {
            [self.delegate cell:self didChangeSkillNotifyToUser:user];
        }];
    } else {
        self.skill.skillNotify = NO;
        [[PUConnect sharedConnect] addSkillLevel:skillLevel forEventType:self.skillType notify:self.skill.skillNotify onCompletion:^(PUUser *user, PUServerResponse serverResponseCode) {
            [self.delegate cell:self didChangeSkillNotifyToUser:user];
        }];
    }
}


@end
