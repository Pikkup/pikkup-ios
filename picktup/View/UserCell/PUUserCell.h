//
//  PUUserCell.h
//  picktup
//
//  Created by Planet 1107 on 20/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUUser.h"
#import "PUEvent.h"

@protocol PUUserCellDelegate <NSObject>

- (void)cell:(UITableViewCell *)cell didTouchUpInsideUserButton:(UIButton *)button;

@end


@interface PUUserCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViewsStars;

@property (assign, nonatomic) PUEventType eventType;
@property (strong, nonatomic) PUUser *user;
@property (weak, nonatomic) id<PUUserCellDelegate>delegate;

@end
