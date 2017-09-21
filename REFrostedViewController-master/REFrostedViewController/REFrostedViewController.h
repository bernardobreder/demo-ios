#import <UIKit/UIKit.h>
#import "UIViewController+REFrostedViewController.h"

typedef NS_ENUM(NSInteger, REFrostedViewControllerDirection) {
    REFrostedViewControllerDirectionLeft,
    REFrostedViewControllerDirectionRight,
    REFrostedViewControllerDirectionTop,
    REFrostedViewControllerDirectionBottom
};

typedef NS_ENUM(NSInteger, REFrostedViewControllerLiveBackgroundStyle) {
    REFrostedViewControllerLiveBackgroundStyleLight,
    REFrostedViewControllerLiveBackgroundStyleDark
};

@protocol REFrostedViewControllerDelegate;

@interface REFrostedViewController : UIViewController

@property (strong, readonly, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, readwrite, nonatomic) BOOL panGestureEnabled;
@property (assign, readwrite, nonatomic) REFrostedViewControllerDirection direction;

/**
 * The backgroundFadeAmount is how much the backgound view fades when the menu
 * view is presented.
 *
 * 1.0 is completely black. 0.0 means the background does not dim at all.
 * The default value is 0.3.
 */
@property (assign, readwrite, nonatomic) CGFloat backgroundFadeAmount;
@property (strong, readwrite, nonatomic) UIColor *blurTintColor; // Used only when live blur is off
@property (assign, readwrite, nonatomic) CGFloat blurRadius; // Used only when live blur is off
@property (assign, readwrite, nonatomic) CGFloat blurSaturationDeltaFactor; // Used only when live blur is off
@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;
@property (assign, readwrite, nonatomic) BOOL limitMenuViewSize;
@property (assign, readwrite, nonatomic) CGSize menuViewSize;
@property (assign, readwrite, nonatomic) BOOL liveBlur; // iOS 7 only
@property (assign, readwrite, nonatomic) REFrostedViewControllerLiveBackgroundStyle liveBlurBackgroundStyle; // iOS 7 only

@property (weak, readwrite, nonatomic) id<REFrostedViewControllerDelegate> delegate;
@property (strong, readwrite, nonatomic) UIViewController *contentViewController;
@property (strong, readwrite, nonatomic) UIViewController *menuViewController;

- (id)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController;
- (void)presentMenuViewController;
- (void)hideMenuViewController;
- (void)resizeMenuViewControllerToSize:(CGSize)size;
- (void)hideMenuViewControllerWithCompletionHandler:(void(^)(void))completionHandler;
- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer;

@end

@protocol REFrostedViewControllerDelegate <NSObject>

@optional
- (void)frostedViewController:(REFrostedViewController *)frostedViewController willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)frostedViewController:(REFrostedViewController *)frostedViewController didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)frostedViewController:(REFrostedViewController *)frostedViewController willShowMenuViewController:(UIViewController *)menuViewController;
- (void)frostedViewController:(REFrostedViewController *)frostedViewController didShowMenuViewController:(UIViewController *)menuViewController;
- (void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController;
- (void)frostedViewController:(REFrostedViewController *)frostedViewController didHideMenuViewController:(UIViewController *)menuViewController;

@end