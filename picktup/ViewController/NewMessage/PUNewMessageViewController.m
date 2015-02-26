//
//  PUNewMessageViewController.m
//  picktup
//
//  Created by Planet 1107 on 05/06/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "PUNewMessageViewController.h"
#import "HPGrowingTextView.h"
#import "PUTextField.h"

@interface PUNewMessageViewController () <UITextFieldDelegate, HPGrowingTextViewDelegate>

@property (strong, nonatomic) IBOutlet PUTextField *textFieldTo;
@property (strong, nonatomic) IBOutlet UIView *viewContainerMessage;
@property (strong, nonatomic) HPGrowingTextView *textViewMessage;

@property (strong, nonatomic) NSMutableArray *usersTo;

@end

@implementation PUNewMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _usersTo = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"New Message";
    
    self.textViewMessage = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    self.textViewMessage.isScrollable = NO;
    self.textViewMessage.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textViewMessage.minNumberOfLines = 1;
	self.textViewMessage.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
	self.textViewMessage.returnKeyType = UIReturnKeyDefault; //just as an example
	self.textViewMessage.font = [UIFont systemFontOfSize:15.0f];
	self.textViewMessage.delegate = self;
    self.textViewMessage.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textViewMessage.backgroundColor = [UIColor whiteColor];
    self.textViewMessage.placeholder = @"Type your message...";
    //self.textViewMessage.textColor = kSPColorGray149;
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.viewContainerMessage.frame.size.width, self.viewContainerMessage.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.textViewMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self.viewContainerMessage addSubview:imageView];
    [self.viewContainerMessage addSubview:self.textViewMessage];
    [self.viewContainerMessage addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(self.viewContainerMessage.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    
    //[doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    //doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[self.viewContainerMessage addSubview:doneBtn];
    self.viewContainerMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    if (self.messeageToUser) {
        [self userPickerViewController:nil selectedUsers:[NSMutableArray arrayWithArray:@[self.messeageToUser]]];
    }

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HPGrowingTextViewDelegate methods

-(void)resignTextView {
    
	[self.textViewMessage resignFirstResponder];
    if (self.textViewMessage.text.length && self.usersTo.count) {
        [self.hud show:YES];
        [[PUConnect sharedConnect] sendMessage:self.textViewMessage.text toUsers:self.usersTo onSuccess:^(NSMutableArray *messages) {
            [self.hud hide:NO];
            [self.navigationController popViewControllerAnimated:YES];
        } onFaliure:^(PUServerResponse serverResponseCode) {
            [self.hud hide:NO];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured and your message was not sent, please check your network connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [self.textViewMessage becomeFirstResponder];
        }];
    }
}

-(void)keyboardWillShow:(NSNotification *)note {
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.viewContainerMessage.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.viewContainerMessage.frame = containerFrame;
    
    
	// commit animations
	[UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)note {
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.viewContainerMessage.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.viewContainerMessage.frame = containerFrame;
    
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.viewContainerMessage.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.viewContainerMessage.frame = r;
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (string.length == 1) {
        [self.textFieldTo resignFirstResponder];
        PUUserPickerViewController *userPickerViewController = [[PUUserPickerViewController alloc] initWithNibName:@"PUUserPickerViewController" bundle:nil];
        userPickerViewController.delegate = self;
        userPickerViewController.initialText = string;
        [self.navigationController pushViewController:userPickerViewController animated:YES];
    } else if (string.length == 0) {
        [self.usersTo removeLastObject];
        NSMutableString *newText = [NSMutableString string];
        for (PUUser *user in self.usersTo) {
            [newText appendFormat:@"%@, ", user.username];
        }
        self.textFieldTo.text = newText;
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - PUUserPickerViewControllerDelegate methods

- (void)userPickerViewController:(PUUserPickerViewController*)userPickerViewController selectedUsers:(NSMutableArray*)selectedUsers {
    
    if (selectedUsers.count) {
        [self.usersTo addObjectsFromArray:selectedUsers];
        NSMutableString *newText = [NSMutableString string];
        for (PUUser *user in self.usersTo) {
            [newText appendFormat:@"%@, ", user.username];
        }
        self.textFieldTo.text = newText;
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
