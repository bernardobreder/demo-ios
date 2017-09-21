//
//  AppDelegate.h
//  MailSender
//
//  Created by Bernardo Breder on 14/12/14.
//  Copyright (c) 2014 Breder Organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MFMailComposeViewController *mailComposer;

@end

