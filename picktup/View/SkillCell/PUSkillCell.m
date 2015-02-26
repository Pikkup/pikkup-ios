//
//  PUSkillCell.m
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSkillCell.h"
#import <DLAVAlertView.h>
#import "PUConnect.h"
#import "PUSkill.h"
#import "PUSkillAlertContentView.h"
#import "PUEvent.h"

@interface PUSkillCell ()

@property (strong, nonatomic) IBOutlet UIButton *buttonSetSkill;
@property (strong, nonatomic) IBOutlet UIView *viewStars;
@property (strong, nonatomic) IBOutlet UILabel *labelSkillType;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViewStars;

@end

@implementation PUSkillCell

- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (self.skill) {
        self.viewStars.alpha = 1.0f;
        self.buttonSetSkill.alpha = 0.0f;
    } else {
        self.viewStars.alpha = 0.0f;
        self.buttonSetSkill.alpha = 1.0f;
    }
    if (self.shouldShowSkillNotSet) {
        [self.buttonSetSkill setTitle:@"Skill not set" forState:UIControlStateNormal];
        self.buttonSetSkill.enabled = NO;
    } else {
        [self.buttonSetSkill setTitle:@"Set skill" forState:UIControlStateNormal];
        self.buttonSetSkill.enabled = YES;
    }

    for (UIImageView *imageView in self.imageViewStars) {
        if (imageView.tag < self.skill.skillLevel) {
            [imageView setImage:[UIImage imageNamed:@"star-full"]];
        } else {
            [imageView setImage:[UIImage imageNamed:@"star-empty"]];
        }
    }
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

- (IBAction)buttonSetSkillTouchUpInside:(id)sender {
    
    DLAVAlertView *addSkillAlertView = [[DLAVAlertView alloc] initWithTitle:@"Add skill:" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    PUSkillAlertContentView *skillAlertContentView = [[NSBundle mainBundle] loadNibNamed:@"PUSkillAlertContentView" owner:self options:nil].firstObject;
    addSkillAlertView.contentView = skillAlertContentView;
    [addSkillAlertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[PUConnect sharedConnect] addSkillLevel:skillAlertContentView.skillLevel forEventType:self.skillType notify:YES onCompletion:^(PUUser *user, PUServerResponse serverResponseCode) {
                [self.delegate cell:self didAddSkillToUser:user];
            }];
        }
    }];
}

@end
