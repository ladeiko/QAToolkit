// The MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DBResourcesTableViewController.h"
#import "DBKeychainToolkit.h"
#import "DBUserDefaultsToolkit.h"
#import "DBTitleValueListTableViewController.h"
#import "NSBundle+QAToolkit.h"
#import "DBPersistentStoreCoordinatorsTableViewController.h"
#import "DBEntitiesTableViewController.h"
#import "DBReceiptToolkit.h"
#import "UIColor+QAToolkit.h"

typedef NS_ENUM(NSUInteger, DBResourcesTableViewControllerSubmenu) {
    DBResourcesTableViewControllerSubmenuFiles,
    DBResourcesTableViewControllerSubmenuUserDefaults,
    DBResourcesTableViewControllerSubmenuKeychain,
    DBResourcesTableViewControllerSubmenuCoreData,
    DBResourcesTableViewControllerSubmenuCookies,
    DBResourcesTableViewControllerSubmenuReceipt // NEW
};

static NSString *const DBResourcesTableViewControllerUserDefaultsSegueIdentifier = @"UserDefaultsSegue";
static NSString *const DBResourcesTableViewControllerKeychainSegueIdentifier = @"KeychainSegue";
static NSString *const DBResourcesTableViewControllerReceiptSegueIdentifier = @"ReceiptSegue";

@interface DBResourcesTableViewController () <DBPersistentStoreCoordinatorsTableViewControllerDelegate>

@end

@implementation DBResourcesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBResourcesTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DBResourcesTableViewControllerUserDefaultsSegueIdentifier]) {
        DBTitleValueListTableViewController *titleValueListTableViewController = (DBTitleValueListTableViewController *)segue.destinationViewController;
        titleValueListTableViewController.viewModel = [DBUserDefaultsToolkit new];
    } else if ([segue.identifier isEqualToString:DBResourcesTableViewControllerKeychainSegueIdentifier]) {
        DBTitleValueListTableViewController *titleValueListTableViewController = (DBTitleValueListTableViewController *)segue.destinationViewController;
        titleValueListTableViewController.viewModel = [DBKeychainToolkit new];
    }
    else if ([segue.identifier isEqualToString:DBResourcesTableViewControllerReceiptSegueIdentifier]) {
        DBTitleValueListTableViewController *titleValueListTableViewController = (DBTitleValueListTableViewController *)segue.destinationViewController;
        titleValueListTableViewController.viewModel = [DBReceiptToolkit new];
    }
}

- (void)openPersistentStoreCoordinatorsTableViewController {
    NSBundle *bundle = [NSBundle debugToolkitBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBPersistentStoreCoordinatorsTableViewController" bundle:bundle];
    DBPersistentStoreCoordinatorsTableViewController *storeCoordinatorsViewController = [storyboard instantiateInitialViewController];
    storeCoordinatorsViewController.coreDataToolkit = self.coreDataToolkit;
    storeCoordinatorsViewController.delegate = self;
    [self.navigationController pushViewController:storeCoordinatorsViewController animated:YES];
}

- (void)proceedWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    NSBundle *bundle = [NSBundle debugToolkitBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBEntitiesTableViewController" bundle:bundle];
    DBEntitiesTableViewController *entitiesTableViewController = [storyboard instantiateInitialViewController];
    entitiesTableViewController.persistentStoreCoordinator = persistentStoreCoordinator;
    [self.navigationController pushViewController:entitiesTableViewController animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == DBResourcesTableViewControllerSubmenuCoreData) {
        if (self.coreDataToolkit.persistentStoreCoordinators.count == 1) {
            [self proceedWithPersistentStoreCoordinator:self.coreDataToolkit.persistentStoreCoordinators.firstObject];
        } else {
            [self openPersistentStoreCoordinatorsTableViewController];
        }
    }
}

#pragma mark - DBPersistentStoreCoordinatorsTableViewControllerDelegate

- (void)persistentStoreCoordinatorsTableViewController:(DBPersistentStoreCoordinatorsTableViewController *)persistentStoreCoordinatorsTableViewController didSelectPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    [self proceedWithPersistentStoreCoordinator:persistentStoreCoordinator];
}

@end
