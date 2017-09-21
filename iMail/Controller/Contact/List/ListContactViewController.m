//
//  ListContactViewController.m
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "ListContactViewController.h"

@interface ListContactViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ListContactViewController

@synthesize serviceLocator;
@synthesize tableView;

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        [self.view addSubview:view];
        CONSTRAINT4(view, self.view, NSLayoutAttributeLeft, 1.0, 0.0, NSLayoutAttributeRight, 1.0, 0.0, NSLayoutAttributeTop, 1.0, 0.0, NSLayoutAttributeHeight, 0.0, 70);
        {
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@"Adicionar" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onTableTouch) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            button.frame = CGRectMake(0, 20, 100, 50);
        }
        {
            UILabel *label = [[UILabel alloc] init];
            label.text = @"Contatos";
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            CONSTRAINT4(label, view, NSLayoutAttributeCenterX, 1.0, 0.0, NSLayoutAttributeWidth, 0.0, 100.0, NSLayoutAttributeTop, 1.0, 20.0, NSLayoutAttributeHeight, 0.0, 50.0);
        }
    }
    {
        tableView = [[UITableView alloc] init];
        tableView.dataSource = self;
        tableView.allowsSelectionDuringEditing = true;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.view addSubview:tableView];
        CONSTRAINT4(tableView, self.view, NSLayoutAttributeLeft, 1.0, 0.0, NSLayoutAttributeRight, 1.0, 0.0, NSLayoutAttributeTop, 1.0, 71.0, NSLayoutAttributeBottom, 1.0, 0.0);
    }
}

- (void)onTableTouch
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"Hello from California!"];
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"bernardobreder@gmail.com"];
	[picker setToRecipients:toRecipients];
	// Attach an image to the email
	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
	NSData *myData = [NSData dataWithContentsOfFile:path];
	[picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
	
	// Fill out the email body text
	NSString *emailBody = @"It is raining in sunny California!";
	[picker setMessageBody:emailBody isHTML:YES];
	[self presentViewController:picker animated:YES completion:NULL];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSNumber* data = [NSNumber numberWithInt:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Line %d", [data intValue]];
	return cell;
}

#pragma mark - Delegate Methods

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
//	self.feedbackMsg.hidden = NO;
	// Notifies users about errors associated with the interface
//	switch (result)
//	{
//		case MFMailComposeResultCancelled:
//			self.feedbackMsg.text = @"Result: Mail sending canceled";
//			break;
//		case MFMailComposeResultSaved:
//			self.feedbackMsg.text = @"Result: Mail saved";
//			break;
//		case MFMailComposeResultSent:
//			self.feedbackMsg.text = @"Result: Mail sent";
//			break;
//		case MFMailComposeResultFailed:
//			self.feedbackMsg.text = @"Result: Mail sending failed";
//			break;
//		default:
//			self.feedbackMsg.text = @"Result: Mail not sent";
//			break;
//	}
	[self dismissViewControllerAnimated:YES completion:NULL];
//    [self showEmailModalView]
}


@end
