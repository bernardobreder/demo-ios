//
//  ViewController.m
//  MailSender
//
//  Created by Bernardo Breder on 14/12/14.
//  Copyright (c) 2014 Breder Organization. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic, strong) UIView* toolbarView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) MFMailComposeViewController *mailComposer;

@end

@implementation ViewController

- (void)loadView
{
	UIView* view = [[UIView alloc] init];
	
	_tableView = [[UITableView alloc] init];
	[view addSubview:_tableView];
	
	_toolbarView = [[UIView alloc] init];
	_toolbarView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
	[view addSubview:_toolbarView];
	
	_sendButton = [[UIButton alloc] init];
	[_sendButton setTitle:@"Enviar" forState:UIControlStateNormal];
	[_sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
	[_sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_sendButton addTarget:self action:@selector(onSendAction) forControlEvents:UIControlEventTouchUpInside];
	[_toolbarView addSubview:_sendButton];
	
	_mailComposer = [[MFMailComposeViewController alloc] init];
	
	self.view = view;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	CGSize size = UIScreen.mainScreen.bounds.size;
	_toolbarView.frame = CGRectMake(0, 0, size.width, 70);
	_tableView.frame = CGRectMake(0, 0, size.width, size.height);
	_tableView.contentInset = UIEdgeInsetsMake(70, 0, 0, 0);
	_sendButton.frame = CGRectMake(size.width-100, 20, 100, 50);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)onSendAction
{
	if ([MFMailComposeViewController canSendMail]) {
		NSString *emailTitle = @"Test Email";
		NSString *messageBody = @"iOS programming is so fun!";
		NSArray *toRecipents = [NSArray arrayWithObject:@"bernardobreder@gmail.com"];
		_mailComposer.mailComposeDelegate = self;
		[_mailComposer setSubject:emailTitle];
		[_mailComposer setMessageBody:messageBody isHTML:NO];
		[_mailComposer setToRecipients:toRecipents];
		
		// Present mail view controller on screen
		[self presentViewController:_mailComposer animated:YES completion:NULL];
	} else {
		NSLog(@"Can not send mail");
	}
}

#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
		 didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail sent failure: %@", [error localizedDescription]);
			break;
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:^() {
		_mailComposer = [[MFMailComposeViewController alloc] init];
	}];}

@end
