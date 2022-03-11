
#import "DBNetworkSettingsTableViewController.h"
#import "DBMenuSwitchTableViewCell.h"
#import "NSBundle+QAToolkit.h"
#import "DBToolkitSettings.h"
#import "UIColor+QAToolkit.h"

static NSString *const DBNetworkSettingsTableViewControllerSwitchCellIdentifier = @"DBMenuSwitchTableViewCell";

@interface DBNetworkSettingsTableViewController () <DBMenuSwitchTableViewCellDelegate>

@end

@implementation DBNetworkSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    NSBundle *bundle = [NSBundle debugToolkitBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBMenuSwitchTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBNetworkSettingsTableViewControllerSwitchCellIdentifier];
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBNetworkSettingsTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMenuSwitchTableViewCell *switchTableViewCell = [tableView dequeueReusableCellWithIdentifier:DBNetworkSettingsTableViewControllerSwitchCellIdentifier];
    switchTableViewCell.titleLabel.text = @"Logging enabled";
    switchTableViewCell.valueSwitch.on = self.networkToolkit.loggingEnabled;
    switchTableViewCell.delegate = self;
    return switchTableViewCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Logging requests may affect the memory usage.";
}

#pragma mark - DBMenuSwitchTableViewCellDelegate

- (void)menuSwitchTableViewCell:(DBMenuSwitchTableViewCell *)menuSwitchTableViewCell didSetOn:(BOOL)isOn {
    [[DBToolkitSettings sharedInstance] updateNetworkLoggingEnabled:isOn];
    self.networkToolkit.loggingEnabled = isOn;
}

@end
