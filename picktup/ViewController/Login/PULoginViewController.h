//
//  PULoginViewController.h
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUSuperViewController.h"

@interface PULoginViewController : PUSuperViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewLogin;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;

@end
