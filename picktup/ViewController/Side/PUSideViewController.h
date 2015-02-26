//
//  PUSideViewController.h
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PUSideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *navigationControllers;

@end
