#import <UIKit/UIKit.h>
#import "UIInfinitScrollView.h"

@interface UITaskListView : UIScrollView <UITableViewDataSource, UITableViewDelegate> {
    
    UITableView* tableView;
    
    UIToolbar* toolView;
        
}

@property(nonatomic, strong) UITableView* tableView;

@property(nonatomic, strong) UIToolbar* toolView;

@end

@interface MainViewController : UIViewController <UIInfinitScrollViewDelegate> {

    IBOutlet UIInfinitScrollView* scrollView;
    
}

@end
