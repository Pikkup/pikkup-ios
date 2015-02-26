//
//  PUWelcomeViewController.m
//  picktup
//
//  Created by Planet 1107 on 06/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUWelcomeViewController.h"
#import "PULoginViewController.h"
#import "PURegisterViewController.h"
#import "PUSideViewController.h"
#import "PUAppDelegate.h"

@interface PUWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewWelcome;
@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlWelcome;

@end

@implementation PUWelcomeViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Pikkup";
    //self.automaticallyAdjustsScrollViewInsets = NO;
    [self.scrollViewWelcome addSubview:self.viewContent];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.viewContent.frame = CGRectMake(0.0f, CGRectGetHeight(self.scrollViewWelcome.frame) - CGRectGetHeight(self.viewContent.frame), CGRectGetWidth(self.viewContent.frame), CGRectGetHeight(self.viewContent.frame));
    self.scrollViewWelcome.contentSize = CGSizeMake(CGRectGetWidth(self.viewContent.frame), CGRectGetHeight(self.scrollViewWelcome.frame));
    
    if ([PUConnect sharedConnect].user) {
        PUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.sideViewController = [[PUSideViewController alloc] initWithNibName:@"PUSideViewController" bundle:nil];
        appDelegate.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:appDelegate.sideViewController.navigationControllers[0] leftViewController:appDelegate.sideViewController rightViewController:nil];
        appDelegate.viewDeckController.leftSize = 320 - 273;
        [appDelegate.window.rootViewController presentViewController:appDelegate.viewDeckController animated:NO completion:^{ }];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods

- (IBAction)buttonLoginTouchUpInside:(id)sender {
    
    PULoginViewController *loginViewController = [[PULoginViewController alloc] initWithNibName:@"PULoginViewController" bundle:nil];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (IBAction)buttonRegisterTouchUpInside:(id)sender {
    
    PURegisterViewController *registerViewController = [[PURegisterViewController alloc] initWithNibName:@"PURegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (IBAction)valueChangedInPageControl:(UIPageControl *)sender {
    
    int index = (int)sender.currentPage;
    [self.scrollViewWelcome scrollRectToVisible:CGRectMake(CGRectGetWidth(self.scrollViewWelcome.frame) * index, 0.0f, CGRectGetWidth(self.scrollViewWelcome.frame), CGRectGetHeight(self.scrollViewWelcome.frame)) animated:YES];
}

@end
