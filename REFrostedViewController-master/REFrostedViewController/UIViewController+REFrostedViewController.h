#import <UIKit/UIKit.h>

@class REFrostedViewController;

@interface UIViewController (REFrostedViewController)

@property (strong, readonly, nonatomic) REFrostedViewController *frostedViewController;

- (void)re_displayController:(UIViewController *)controller frame:(CGRect)frame;
- (void)re_hideController:(UIViewController *)controller;

@end
