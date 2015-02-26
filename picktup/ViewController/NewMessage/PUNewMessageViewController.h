//
//  PUNewMessageViewController.h
//  picktup
//
//  Created by Planet 1107 on 05/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSuperViewController.h"
#import "PUUserPickerViewController.h"

@interface PUNewMessageViewController : PUSuperViewController <PUUserPickerViewControllerDelegate>

@property (strong, nonatomic) PUUser *messeageToUser;

@end
