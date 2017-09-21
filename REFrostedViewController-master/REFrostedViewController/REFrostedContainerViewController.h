#import <UIKit/UIKit.h>

@class REFrostedViewController;

@interface REFrostedContainerViewController : UIViewController

@property (strong, readwrite, nonatomic) UIImage *screenshotImage;
@property (weak, readwrite, nonatomic) REFrostedViewController *frostedViewController;
@property (assign, readwrite, nonatomic) BOOL animateApperance;
@property (strong, readonly, nonatomic) UIView *containerView;

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer;
- (void)hide;
- (void)resizeToSize:(CGSize)size;
- (void)hideWithCompletionHandler:(void(^)(void))completionHandler;
- (void)refreshBackgroundImage;

@end
