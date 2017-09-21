//
//  BandeiraViewController.h
//  iSchoolChapter1
//
//  Created by Bernardo Breder on 31/08/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BandeiraViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *button1;

@property (nonatomic, strong) IBOutlet UIButton *button2;

@property (nonatomic, strong) IBOutlet UISlider *slider;

@property (nonatomic, strong) IBOutlet UILabel *sliderLabel;

- (IBAction)onButton1Touch:(id)sender;

- (IBAction)onButton2Touch:(id)sender;

- (IBAction)onSliderChanged:(id)sender;

@end
