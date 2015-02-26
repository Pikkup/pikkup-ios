//
//  PUSuperViewController.m
//  picktup
//
//  Created by Planet 1107 on 20/05/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUSuperViewController.h"
#import "PUAppDelegate.h"
#import "PUCreateParkViewController.h"
#import "PUWelcomeViewController.h"
#import "PUGameViewController.h"
#import "PUConversationsViewController.h"
#import "PNTActivityIndicator.h"

@interface PUSuperViewController ()

@end

@implementation PUSuperViewController

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
    
    if (self.navigationController.viewControllers.count == 1 && ![self isKindOfClass:PUWelcomeViewController.class]) {
        UIButton *buttonShowSideBar = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonShowSideBar addTarget:self action:@selector(buttonMenuTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *imageButton = [UIImage imageNamed:@"nav-btn-menu"];
        buttonShowSideBar.bounds = CGRectMake(0, 0, imageButton.size.width, imageButton.size.height);
        [buttonShowSideBar setImage:imageButton forState:UIControlStateNormal];
        UIBarButtonItem *barButtonItemShowSideBar = [[UIBarButtonItem alloc] initWithCustomView:buttonShowSideBar];
        self.navigationItem.leftBarButtonItem = barButtonItemShowSideBar;
    }
    
    if (self.navigationController.viewControllers.count > 1) {
        UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonAdd addTarget:self action:@selector(buttonBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *imageButton = [UIImage imageNamed:@"nav-btn-back"];
        buttonAdd.bounds = CGRectMake(0, 0, imageButton.size.width, imageButton.size.height);
        [buttonAdd setImage:imageButton forState:UIControlStateNormal];
        UIBarButtonItem *barButtonItemAdd = [[UIBarButtonItem alloc] initWithCustomView:buttonAdd];
        self.navigationItem.leftBarButtonItem = barButtonItemAdd;
    }
    
    if (!self.hud) {
        
        self.hud = [PNTActivityIndicator customActivityHUD];
        [self.view addSubview:self.hud];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)buttonMenuTouchUpInside:(UIButton*)button {
    
    [self.view endEditing:YES];
    PUAppDelegate *appDelegate = (PUAppDelegate *)[UIApplication sharedApplication].delegate;
    IIViewDeckController *viewDeckController = appDelegate.viewDeckController;
    [viewDeckController toggleLeftView];
}

- (void)buttonBackTouchUpInside:(UIButton*)button {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
