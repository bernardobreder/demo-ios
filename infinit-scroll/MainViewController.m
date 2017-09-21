#import "MainViewController.h"

@interface MainViewController ()

@end

@interface UITaskListView ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UIView *)pageView:(id)infinitScrollView atPage:(int)pageIndex withRect:(CGRect)rect
{
    UITaskListView* view = [[UITaskListView alloc] init];
    view.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, rect.size.width, rect.size.height - 50)];
    view.tableView.dataSource = view;
    view.tableView.delegate = view;
    [view addSubview:view.tableView];
    {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        //dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setDateFormat:@"dd MMMM yyyy"];
        NSDate* date = [[NSDate date] dateByAddingTimeInterval:60*60*24*pageIndex];
        NSString* text = [dateFormatter stringFromDate:date];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 50)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = text;
        label.font = [UIFont boldSystemFontOfSize:20.0];
        UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:label];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:toolBarTitle];
        view.toolView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 50)];
        [view.toolView setBackgroundColor:[UIColor blackColor]];
        [view.toolView setItems:items animated:NO];
        [view addSubview:view.toolView];
    }
    return view;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [scrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [scrollView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

@implementation UITaskListView

@synthesize tableView;

@synthesize toolView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    int index = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"Line %d", index + 1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Titulo" message:@"Message" delegate:Nil cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ok", nil];
    [alertView show];
}

@end