//
//  ListContactViewController.h
//  iMail
//
//  Created by Bernardo Breder on 10/04/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListContactViewController : UIViewController <UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) ServiceLocator *serviceLocator;

@end
