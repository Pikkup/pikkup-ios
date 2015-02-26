//
//  PUUserPickerViewController.h
//  picktup
//
//  Created by Planet 1107 on 05/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSuperViewController.h"

@class PUUserPickerViewController;

@protocol PUUserPickerViewControllerDelegate <NSObject>

- (void)userPickerViewController:(PUUserPickerViewController*)userPickerViewController selectedUsers:(NSMutableArray*)selectedUsers;

@end

@interface PUUserPickerViewController : PUSuperViewController

@property (weak, nonatomic) id <PUUserPickerViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *initialText;

@end
