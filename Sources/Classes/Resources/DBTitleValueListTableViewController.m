
#import "DBTitleValueListTableViewController.h"
#import "NSBundle+QAToolkit.h"
#import "DBTitleValueTableViewCell.h"
#import "UILabel+QAToolkit.h"
#import "UIColor+QAToolkit.h"

static NSString *const DBTitleValueListTableViewControllerTitleValueCellIdentifier = @"DBTitleValueTableViewCell";

@interface DBTitleValueListTableViewController ()<UISearchResultsUpdating, DBTitleValueListViewModelController>

@property (nonatomic, strong) UILabel *backgroundLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *clearButton;

@end

@implementation DBTitleValueListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    self.title = [self.viewModel viewTitle];
    NSBundle *bundle = [NSBundle debugToolkitBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBTitleValueTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBTitleValueListTableViewControllerTitleValueCellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.tableFooterView = [UIView new];
    [self setupBackgroundLabel];
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBTitleValueListTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];

    if (@available(iOS 11.0, *)) {
        if ([((NSObject*)self.viewModel) respondsToSelector:@selector(searchString)]) {
            UISearchController* const sc = [[UISearchController alloc] initWithSearchResultsController:nil];
            if ([((NSObject*)self.viewModel) respondsToSelector:@selector(sortScopes)]
                && [((NSObject*)self.viewModel) respondsToSelector:@selector(sortScope)]
                && [((NSObject*)self.viewModel) respondsToSelector:@selector(setSortScope:)]) {
                sc.searchBar.scopeButtonTitles = self.viewModel.sortScopes;
                sc.searchBar.selectedScopeButtonIndex = self.viewModel.sortScope;
                sc.searchBar.showsScopeBar = YES;
            }
            sc.searchResultsUpdater = self;
            self.navigationItem.searchController = sc;
            self.navigationItem.hidesSearchBarWhenScrolling = NO;
        }
    }

    if ([((NSObject*)self.viewModel) respondsToSelector:@selector(customActions)]) {

        NSMutableArray* items = [NSMutableArray new];

        NSArray* const customActions = [self.viewModel customActions];

        [customActions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            NSString* const title = [obj objectForKey:@"title"];

            if (!title) {
                return;
            }

            UIBarButtonItem* const barItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(customAction:)];

            [items addObject:barItem];

            [barItem setTag:idx];

            if (idx != [customActions count] - 1) {
                [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL]];
            }
        }];

        self.toolbarItems = items;
    }


    if ([(NSObject*)self.viewModel respondsToSelector:@selector(setController:)]) {
        [self.viewModel setController:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.toolbarItems count]) {
        self.navigationController.toolbarHidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.toolbarItems count]) {
        self.navigationController.toolbarHidden = YES;
    }
}

- (void)setupBackgroundLabel {
    self.backgroundLabel = [UILabel tableViewBackgroundLabel];
    self.tableView.backgroundView = self.backgroundLabel;
}

#pragma mark - Clear button

- (IBAction)clearButtonAction:(id)sender {
    if ([(NSObject*)self.viewModel respondsToSelector:@selector(handleClearAction)]) {
        [self.viewModel handleClearAction];
        [self.tableView reloadData];
    }
}

- (void)customAction:(UIBarButtonItem*)item {
    NSArray* const customActions = [self.viewModel customActions];
    void (^action)(void) = [[customActions objectAtIndex:item.tag] objectForKey:@"action"];
    action();
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfItems = [self.viewModel numberOfItems];
    self.backgroundLabel.text = numberOfItems == 0 ? [self.viewModel emptyListDescriptionString] : @"";
    self.clearButton.enabled = numberOfItems > 0 && [(NSObject*)self.viewModel respondsToSelector:@selector(handleClearAction)];
    return numberOfItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBTitleValueTableViewCell *titleValueCell = [self.tableView dequeueReusableCellWithIdentifier:DBTitleValueListTableViewControllerTitleValueCellIdentifier];
    DBTitleValueTableViewCellDataSource *dataSource = [self.viewModel dataSourceForItemAtIndex:indexPath.row];
    [titleValueCell configureWithDataSource:dataSource];
    [titleValueCell setSeparatorInset:UIEdgeInsetsZero];
    return titleValueCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [(NSObject*)self.viewModel respondsToSelector:@selector(handleDeleteItemActionAtIndex:)];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.viewModel handleDeleteItemActionAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.viewModel.searchString = [searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.viewModel.sortScope = searchController.searchBar.selectedScopeButtonIndex;
}

#pragma mark - DBTitleValueListViewModelController

- (void)reloadTable {
    [self.tableView reloadData];
}

@end
