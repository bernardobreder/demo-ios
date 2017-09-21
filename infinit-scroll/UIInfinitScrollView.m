#import "UIInfinitScrollView.h"

@interface UIInfinitScrollView ()

- (void)reloadPages;

@end

@implementation UIInfinitScrollView

@synthesize model;

@synthesize needToReload;

- (id)initWithCoder:(NSCoder *)inCoder
{
    self = [super initWithCoder:inCoder];
    views = [[NSMutableArray alloc] init];
    CGRect aFrame = self.bounds;
    for (int n = 0; n < 3; n++) {
        UILabel* view = [[UILabel alloc] init];
        view.frame = aFrame;
        [views addObject:view];
        [self addSubview:view];
        aFrame = CGRectOffset(aFrame, self.bounds.size.width, 0);
    }
    self.delegate = self;
    self.pagingEnabled = true;
    self.showsHorizontalScrollIndicator = true;
    self.showsVerticalScrollIndicator = false;
    self.needToReload = true;
    return self;
}

- (void)layoutSubviews
{
    if (self.needToReload) {
        self.needToReload = false;
        [self reloadData];
    }
    [super layoutSubviews];
}

- (void)reloadPages
{
    CGRect aFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    for (int n = 0; n < 3; n++) {
        int index = page - 1 + n;
        [[views objectAtIndex:n] removeFromSuperview];
        UIView* view = [model pageView:self atPage:index withRect:self.frame];
        view.frame = aFrame;
        [views setObject:view atIndexedSubscript:n];
        [self addSubview:view];
        aFrame = CGRectOffset(aFrame, self.bounds.size.width, 0);
    }
}

- (void)reloadData
{
    [self reloadPages];
    self.contentSize = CGSizeMake(3 * self.bounds.size.width, self.bounds.size.height);
    self.contentOffset = CGPointMake(self.bounds.size.width, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    if(self.contentOffset.x > self.frame.size.width) {
        page++;
	}
	if(self.contentOffset.x < self.frame.size.width) {
        page--;
    }
    [self reloadPages];
    UILabel* view1 = [views objectAtIndex:1];
    [self scrollRectToVisible:view1.frame animated:NO];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotate: %@", NSStringFromCGRect(self.frame));
    [[views objectAtIndex:0] setHidden:true];
    [[views objectAtIndex:2] setHidden:true];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"didRotate: %@", NSStringFromCGRect(self.frame));
    [[views objectAtIndex:0] setHidden:false];
    [[views objectAtIndex:2] setHidden:false];
    [self reloadData];
}

- (void)fireDataChanged
{
    self.needToReload = true;
}

@end
