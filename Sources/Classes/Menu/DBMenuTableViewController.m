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
//1.2.0
#import "DBMenuTableViewController.h"
#import "DBPerformanceTableViewController.h"
#import "NSBundle+QAToolkit.h"
#import "DBConsoleViewController.h"
#import "DBNetworkViewController.h"
#import "DBUserInterfaceTableViewController.h"
#import "DBLocationTableViewController.h"
#import "DBResourcesTableViewController.h"
#import "DBCustomActionsTableViewController.h"
#import "DBCustomVariablesTableViewController.h"
#import "DBCrashReportsTableViewController.h"
#import "DBSettingsTableViewController.h"
#import "DBTitleValueListTableViewController.h"
#import "QATConfigurationPresetTableViewController.h"
#import "UIColor+QAToolkit.h"


const NSInteger kConfigPresetsDetailsTag = 2985760;

typedef NS_ENUM(NSUInteger, DBMenuTableViewControllerRow) {
    DBMenuTableViewControllerRowPerformance,
    DBMenuTableViewControllerRowUserInterface,
    DBMenuTableViewControllerRowNetwork,
    DBMenuTableViewControllerRowResources,
    DBMenuTableViewControllerRowConsole,
    DBMenuTableViewControllerRowLocation,
    DBMenuTableViewControllerRowCrashReports,
    DBMenuTableViewControllerRowConfigurationPresets,
    DBMenuTableViewControllerRowCustomVariables,
    DBMenuTableViewControllerRowCustomActions,
    DBMenuTableViewControllerRowQAToolkitSettings,
    DBMenuTableViewControllerRowApplicationSettings
};

@interface DBMenuTableViewController () <DBUserInterfaceTableViewControllerDelegate,DBSettingsTableViewControllerDelegate>

@end

@implementation DBMenuTableViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBMenuTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configDidChange) name:QATConfigurationPresetDidChangedNotification object:nil];
}

- (void)configDidChange {

    if (![self isViewLoaded]) {
        return;
    }
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell.reuseIdentifier isEqualToString:@"config_preset"]) {
        UILabel* label = [cell.contentView viewWithTag:kConfigPresetsDetailsTag];
        if ([label isKindOfClass:[UILabel class]]) {
            label.text = self.configurationPresetToolkit.currentPreset;
        }
    }
}

#pragma mark - Close button

- (IBAction)closeButtonAction:(id)sender {
    [self.delegate menuTableViewControllerDidTapClose:self];
}

#pragma mark - Opening Performance menu

- (void)openPerformanceMenuWithSection:(DBPerformanceSection)section animated:(BOOL)animated {
    NSBundle *bundle = [NSBundle debugToolkitBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBPerformanceTableViewController" bundle:bundle];
    DBPerformanceTableViewController *performanceTableViewController = [storyboard instantiateInitialViewController];
    performanceTableViewController.performanceToolkit = self.performanceToolkit;
    performanceTableViewController.selectedSection = section;
    [self.navigationController setViewControllers:@[ self, performanceTableViewController ] animated:animated];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == DBMenuTableViewControllerRowApplicationSettings) {
        // Open application settings.
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:true];
    }
    
}



#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.buildInfoProvider buildInfoString];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.deviceInfoProvider deviceInfoString];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationViewController = [segue destinationViewController];
    
    if ([destinationViewController isKindOfClass:[DBPerformanceTableViewController class]]) {
        DBPerformanceTableViewController *performanceTableViewController = (DBPerformanceTableViewController *)destinationViewController;
        performanceTableViewController.performanceToolkit = self.performanceToolkit;
    } else if ([destinationViewController isKindOfClass:[DBConsoleViewController class]]) {
        DBConsoleViewController *consoleViewController = (DBConsoleViewController *)destinationViewController;
        consoleViewController.consoleOutputCaptor = self.consoleOutputCaptor;
        consoleViewController.buildInfoProvider = self.buildInfoProvider;
        consoleViewController.deviceInfoProvider = self.deviceInfoProvider;
    } else if ([destinationViewController isKindOfClass:[DBNetworkViewController class]]) {
        DBNetworkViewController *networkViewController = (DBNetworkViewController *)destinationViewController;
        networkViewController.networkToolkit = self.networkToolkit;
    } else if ([destinationViewController isKindOfClass:[DBUserInterfaceTableViewController class]]) {
        DBUserInterfaceTableViewController *userInterfaceTableViewController = (DBUserInterfaceTableViewController *)destinationViewController;
        userInterfaceTableViewController.userInterfaceToolkit = self.userInterfaceToolkit;
        userInterfaceTableViewController.delegate = self;
    } else if ([destinationViewController isKindOfClass:[DBLocationTableViewController class]]) {
        DBLocationTableViewController *locationTableViewController = (DBLocationTableViewController *)destinationViewController;
        locationTableViewController.locationToolkit = self.locationToolkit;
    } else if ([destinationViewController isKindOfClass:[DBResourcesTableViewController class]]) {
        DBResourcesTableViewController *resourcesTableViewController = (DBResourcesTableViewController *)destinationViewController;
        resourcesTableViewController.coreDataToolkit = self.coreDataToolkit;
    } else if ([destinationViewController isKindOfClass:[DBCustomVariablesTableViewController class]]) {
        DBCustomVariablesTableViewController *customVariablesTableViewController = (DBCustomVariablesTableViewController *)destinationViewController;
        customVariablesTableViewController.customVariables = self.customVariables;
    } else if ([destinationViewController isKindOfClass:[DBCustomActionsTableViewController class]]) {
        DBCustomActionsTableViewController *customActionsTableViewController = (DBCustomActionsTableViewController *)destinationViewController;
        customActionsTableViewController.customActions = self.customActions;
    }//1.2.0
    else if ([destinationViewController isKindOfClass:[DBSettingsTableViewController class]]) {
        DBSettingsTableViewController *userInterfaceTableViewController = (DBSettingsTableViewController *)destinationViewController;
        userInterfaceTableViewController.dbToolkitSettings = self.dbToolkitSettings;
        userInterfaceTableViewController.delegate = self;
    }//1.2.0
    else if ([destinationViewController isKindOfClass:[DBCrashReportsTableViewController class]]) {
        DBCrashReportsTableViewController *crashReportsTableViewController = (DBCrashReportsTableViewController *)destinationViewController;
        crashReportsTableViewController.crashReportsToolkit = self.crashReportsToolkit;
    } // SVERL additions
    else if ([destinationViewController isKindOfClass:[QATConfigurationPresetTableViewController class]]) {
        
        QATConfigurationPresetTableViewController *confPresets = (QATConfigurationPresetTableViewController*) destinationViewController;
        confPresets.viewModel = self.configurationPresetToolkit;
        
    }
}

#pragma mark - DBUserInterfaceTableViewControllerDelegate

- (void)userInterfaceTableViewControllerDidOpenDebuggingInformationOverlay:(DBUserInterfaceTableViewController *)userInterfaceTableViewController {
    [self.delegate menuTableViewControllerDidTapClose:self];
}

@end
