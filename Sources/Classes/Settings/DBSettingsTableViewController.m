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
#import "DBSettingsTableViewController.h"
#import "NSBundle+QAToolkit.h"
#import "DBMenuSwitchTableViewCell.h"
#import "DBTitleValueTableViewCell.h"
#import "DBTextViewViewController.h"
#import "DBFontFamiliesTableViewController.h"
#import "UIColor+QAToolkit.h"

typedef NS_ENUM(NSUInteger, DBUserInterfaceTableViewControllerCell) {
    //DBSettingsTableViewControllerCellPerformanceCapture,
    DBSettingsTableViewControllerCellWidgetDisplay,
    DBSettingsTableViewControllerCellCrashCapture,
    DBSettingsTableViewControllerCellNetworkCapture,
    DBSettingsTableViewControllerCellConsoleCapture,
    //trigger
    DBSettingsTableViewControllerCellLongpressTrigger,
    DBSettingsTableViewControllerCellShakeTrigger,
    DBSettingsTableViewControllerCellTapTrigger,
    DBSettingsTableViewControllerCellReset
};

static NSString *const DBUserInterfaceTableViewControllerSwitchCellIdentifier = @"DBMenuSwitchTableViewCell";
static NSString *const DBUserInterfaceTableViewControllerButtonCellIdentifier = @"DBMenuButtonTableViewCell";

@interface DBSettingsTableViewController () <DBMenuSwitchTableViewCellDelegate>

@end

@implementation DBSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    self.dbToolkitSettings = [DBToolkitSettings sharedInstance];
    
    NSBundle *bundle = [NSBundle debugToolkitBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBMenuSwitchTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
   
    [self.tableView registerNib:[UINib nibWithNibName:@"DBMenuButtonTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBUserInterfaceTableViewControllerButtonCellIdentifier];
    
    self.tableView.rowHeight = 44;
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBSettingsTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
}

#pragma mark - Private methods

- (NSString *)titleForCellAtIndex:(NSInteger)index {
    DBUserInterfaceTableViewControllerCell cell = index;
    switch (cell) {
        //case DBSettingsTableViewControllerCellPerformanceCapture:
           // return @"Отключение виджета";
        case DBSettingsTableViewControllerCellWidgetDisplay:
            return @"Виджет";
        case DBSettingsTableViewControllerCellCrashCapture:
            return @"Захват крэшей";
        case DBSettingsTableViewControllerCellNetworkCapture:
            return @"Захват трафика";
        case DBSettingsTableViewControllerCellConsoleCapture:
            return @"Захват логов";
            //triggers
        case DBSettingsTableViewControllerCellLongpressTrigger:
            return @"Вызов через долгое нажатие";
        case DBSettingsTableViewControllerCellShakeTrigger:
            return @"Вызов по шейку";
        case DBSettingsTableViewControllerCellTapTrigger:
            return @"Вызов по тапам";
        case DBSettingsTableViewControllerCellReset:
            return @"RESET TO DEFAULT";
        default:
            return nil;
    }
}
    - (BOOL)switchSettingForCellAtIndex:(NSInteger)index {
        DBUserInterfaceTableViewControllerCell cell = index;
        switch (cell) {
            //case DBSettingsTableViewControllerCellPerformanceCapture:
                //return self.dbToolkitSettings.performanceCaptureEnabled;
            case DBSettingsTableViewControllerCellWidgetDisplay:
                return self.dbToolkitSettings.widgetEnabled;
            case DBSettingsTableViewControllerCellCrashCapture:
                return self.dbToolkitSettings.crashLoggingEnabled;
            case DBSettingsTableViewControllerCellNetworkCapture:
                return self.dbToolkitSettings.networkLoggingEnabled;
            case DBSettingsTableViewControllerCellConsoleCapture:
                return self.dbToolkitSettings.consoleLoggingEnabled;
                //triggers
            case DBSettingsTableViewControllerCellLongpressTrigger:
                return self.dbToolkitSettings.longpressTriggerEnabled;
            case DBSettingsTableViewControllerCellShakeTrigger:
                return self.dbToolkitSettings.shakeTriggerEnabled;
            case DBSettingsTableViewControllerCellTapTrigger:
                return self.dbToolkitSettings.tapTriggerEnabled;
            default:
                return NO;
        }
    }
    
    - (void)openTextViewViewControllerWithTitle:(NSString *)title text:(NSString *)text {
        NSBundle *bundle = [NSBundle debugToolkitBundle];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBTextViewViewController" bundle:bundle];
        DBTextViewViewController *textViewViewController = [storyboard instantiateInitialViewController];
        [textViewViewController configureWithTitle:title text:text isInConsoleMode:NO];
        [self.navigationController pushViewController:textViewViewController animated:YES];
    }
    
    - (void)openFontFamiliesTableViewController {
        NSBundle *bundle = [NSBundle debugToolkitBundle];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBFontFamiliesTableViewController" bundle:bundle];
        DBFontFamiliesTableViewController *fontFamiliesTableViewController = [storyboard instantiateInitialViewController];
        [self.navigationController pushViewController:fontFamiliesTableViewController animated:YES];
    }
    
#pragma mark - UITableViewDataSource
    
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return 8;
    }
    
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NSString *title = [self titleForCellAtIndex:indexPath.row];
        DBUserInterfaceTableViewControllerCell cell = indexPath.row;
        switch (cell) {
                /*
            case DBSettingsTableViewControllerCellPerformanceCapture: {
                DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
                switchCell.titleLabel.text = title;
                switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
                switchCell.delegate = self;
                return switchCell;
            }
                 */
            case DBSettingsTableViewControllerCellWidgetDisplay: {
                DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
                switchCell.titleLabel.text = title;
                switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
                switchCell.delegate = self;
                return switchCell;
            }
            case DBSettingsTableViewControllerCellCrashCapture: {
                DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
                switchCell.titleLabel.text = title;
                switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
                switchCell.delegate = self;
                return switchCell;
            }
            case DBSettingsTableViewControllerCellNetworkCapture: {
                DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
                switchCell.titleLabel.text = title;
                switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
                switchCell.delegate = self;
                return switchCell;
            }
            case DBSettingsTableViewControllerCellConsoleCapture: {
                DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
                switchCell.titleLabel.text = title;
                switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
                switchCell.delegate = self;
                return switchCell;
            }
                //Triggers
            case DBSettingsTableViewControllerCellLongpressTrigger: {
                DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
                switchCell.titleLabel.text = title;
                switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
                switchCell.delegate = self;
                return switchCell;
            }
            case DBSettingsTableViewControllerCellShakeTrigger: {
                DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
                switchCell.titleLabel.text = title;
                switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
                switchCell.delegate = self;
                return switchCell;
            }
            case DBSettingsTableViewControllerCellTapTrigger: {
                DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
                switchCell.titleLabel.text = title;
                switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
                switchCell.delegate = self;
                return switchCell;
            }
            case DBSettingsTableViewControllerCellReset: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DBUserInterfaceTableViewControllerButtonCellIdentifier];
                cell.textLabel.textColor = cell.tintColor;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
            
                cell.textLabel.text = title;
                return cell;
            }
            
            
            default:
                return nil;
        }
    }

#pragma mark - UITableViewDelegate
    
    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        DBUserInterfaceTableViewControllerCell cell = indexPath.row;
       // NSString *title = [self titleForCellAtIndex:indexPath.row];
        switch (cell) {
           // case DBSettingsTableViewControllerCellPerformanceCapture:
                //break;
            case DBSettingsTableViewControllerCellWidgetDisplay:
                break;
            case DBSettingsTableViewControllerCellCrashCapture:
                break;
            case DBSettingsTableViewControllerCellNetworkCapture:
                break;
            case DBSettingsTableViewControllerCellConsoleCapture:
                break;
                //Triggers
            case DBSettingsTableViewControllerCellLongpressTrigger:
                break;
            case DBSettingsTableViewControllerCellShakeTrigger:
                break;
            case DBSettingsTableViewControllerCellTapTrigger:
                break;
            case DBSettingsTableViewControllerCellReset:{
                
                [self.dbToolkitSettings defaultSetting];
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [tableView reloadData];
                
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Console & Crash Start"
                                                                               message:@"Для включения консоли/крэшлога необходим перезапуск приложения."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:nil];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                
                break;
            }
            default:
                return;
        }
    }
    
#pragma mark - DBMenuSwitchTableViewCellDelegate
    
    - (void)menuSwitchTableViewCell:(DBMenuSwitchTableViewCell *)menuSwitchTableViewCell didSetOn:(BOOL)isOn {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:menuSwitchTableViewCell];
        DBUserInterfaceTableViewControllerCell cell = indexPath.row;
        switch (cell) {
            //case DBSettingsTableViewControllerCellPerformanceCapture:
                
                //[self.dbToolkitSettings updatePerformanceCaptureEnabled:isOn];
                
                //break;
            case DBSettingsTableViewControllerCellWidgetDisplay:
                
                [self.dbToolkitSettings updateWidgetEnabled:isOn];
                
                break;
            case DBSettingsTableViewControllerCellCrashCapture:{
                [self.dbToolkitSettings updateCrashLoggingEnabled:isOn];
               // self.dbToolkitSettings.crashLoggingEnabled = isOn;
             
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"CrashLog Start"
                                                                               message:@"Для включения сборщика крэшей необходим перезапуск приложения."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:nil];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                
                break;
            }
            case DBSettingsTableViewControllerCellNetworkCapture:
                [self.dbToolkitSettings updateNetworkLoggingEnabled:isOn];
                break;
                //self.dbToolkitSettings.networkLoggingEnabled = isOn;
            case DBSettingsTableViewControllerCellConsoleCapture:{
                [self.dbToolkitSettings updateConsoleLoggingEnabled:isOn];
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Console Start"
                                                                               message:@"Для включения необходим перезапуск приложения."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:nil];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                break;
            }
            //Triggers
            case DBSettingsTableViewControllerCellLongpressTrigger:{
                if(self.dbToolkitSettings.shakeTriggerEnabled || self.dbToolkitSettings.tapTriggerEnabled){
                    
                    [self.dbToolkitSettings updateLongpressTriggerEnabled:isOn];
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Вызов по удержанию"
                                                                               message:@"Для включения/выключения выгрузите приложение. Перезапустите." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:nil];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else{
                    menuSwitchTableViewCell.valueSwitch.on = true;
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"WARNING"
                                                                                   message:@"Попытка отключить ВСЕ способы вызова QAT." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:nil];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                break;
            }
            case DBSettingsTableViewControllerCellShakeTrigger:{
                if(self.dbToolkitSettings.longpressTriggerEnabled || self.dbToolkitSettings.tapTriggerEnabled){
                    
                    [self.dbToolkitSettings updateShakeTriggerEnabled:isOn];
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Вызов по шейку"
                                                                                   message:@"Для включения/выключения выгрузите приложение. Перезапустите." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:nil];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else{
                    menuSwitchTableViewCell.valueSwitch.on = true;
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"WARNING"
                                                                                   message:@"Попытка отключить ВСЕ способы вызова QAT." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:nil];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                break;
            }
            case DBSettingsTableViewControllerCellTapTrigger:{
                if(self.dbToolkitSettings.shakeTriggerEnabled || self.dbToolkitSettings.longpressTriggerEnabled){
                    
                    [self.dbToolkitSettings updateTapTriggerEnabled:isOn];
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Вызов по тапам"
                                                                                   message:@"ВКЛЮЧЕНИЕ НЕ РЕКОМЕНДУЕТСЯ. Для включения/выключения выгрузите приложение. Перезапустите." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:nil];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else{
                    menuSwitchTableViewCell.valueSwitch.on = true;
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"WARNING"
                                                                                   message:@"Попытка отключить ВСЕ способы вызова QAT." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:nil];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                break;
            }
            default:
                return;
        }
    }
    
    @end

