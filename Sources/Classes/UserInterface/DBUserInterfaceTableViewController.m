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

#import "DBUserInterfaceTableViewController.h"
#import "NSBundle+QAToolkit.h"
#import "DBMenuSwitchTableViewCell.h"
#import "DBTextViewViewController.h"
#import "DBFontFamiliesTableViewController.h"
#import "UIColor+QAToolkit.h"

typedef NS_ENUM(NSUInteger, DBUserInterfaceTableViewControllerCell) {
    DBUserInterfaceTableViewControllerCellColorBorders,
    DBUserInterfaceTableViewControllerCellSlowAnimations,
    DBUserInterfaceTableViewControllerCellShowTouches,
    DBUserInterfaceTableViewControllerCellAutolayoutTrace,
    DBUserInterfaceTableViewControllerCellCurrentViewDescription,
    DBUserInterfaceTableViewControllerCellViewControllerHierarchy,
    DBUserInterfaceTableViewControllerCellFontFamilies,
    DBUserInterfaceTableViewControllerCellDebuggingInformationOverlay

};

static NSString *const DBUserInterfaceTableViewControllerBasicCellIdentifier = @"DBUserInterfaceBasicCell";
static NSString *const DBUserInterfaceTableViewControllerSwitchCellIdentifier = @"DBMenuSwitchTableViewCell";
static NSString *const DBUserInterfaceTableViewControllerButtonCellIdentifier = @"DBMenuButtonTableViewCell";

@interface DBUserInterfaceTableViewController () <DBMenuSwitchTableViewCellDelegate>

@end

@implementation DBUserInterfaceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    NSBundle *bundle = [NSBundle debugToolkitBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBMenuSwitchTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
    self.tableView.rowHeight = 44;
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBUserInterfaceTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];

}

#pragma mark - Private methods

- (NSString *)titleForCellAtIndex:(NSInteger)index {
    DBUserInterfaceTableViewControllerCell cell = index;
    switch (cell) {
        case DBUserInterfaceTableViewControllerCellColorBorders:
            return @"Colorized view borders";
        case DBUserInterfaceTableViewControllerCellSlowAnimations:
            return @"Slow animations";
        case DBUserInterfaceTableViewControllerCellShowTouches:
            return @"Showing touches";
        case DBUserInterfaceTableViewControllerCellAutolayoutTrace:
            return @"Autolayout trace";
        case DBUserInterfaceTableViewControllerCellCurrentViewDescription:
            return @"Current view description";
        case DBUserInterfaceTableViewControllerCellViewControllerHierarchy:
            return @"View controller hierarchy";
        case DBUserInterfaceTableViewControllerCellFontFamilies:
            return @"Font families";
        case DBUserInterfaceTableViewControllerCellDebuggingInformationOverlay:
            return @"Show UIDebuggingInformationOverlay";
        default:
            return nil;
    }
}

- (BOOL)switchSettingForCellAtIndex:(NSInteger)index {
    DBUserInterfaceTableViewControllerCell cell = index;
    switch (cell) {
        case DBUserInterfaceTableViewControllerCellColorBorders:
            return self.userInterfaceToolkit.colorizedViewBordersEnabled;
        case DBUserInterfaceTableViewControllerCellSlowAnimations:
            return self.userInterfaceToolkit.slowAnimationsEnabled;
        case DBUserInterfaceTableViewControllerCellShowTouches:
            return self.userInterfaceToolkit.showingTouchesEnabled;
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
    return self.userInterfaceToolkit.isDebuggingInformationOverlayAvailable ? 8 : 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self titleForCellAtIndex:indexPath.row];
    DBUserInterfaceTableViewControllerCell cell = indexPath.row;
    switch (cell) {
        case DBUserInterfaceTableViewControllerCellColorBorders:
        case DBUserInterfaceTableViewControllerCellSlowAnimations:
        case DBUserInterfaceTableViewControllerCellShowTouches: {
            DBMenuSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerSwitchCellIdentifier];
            switchCell.titleLabel.text = title;
            switchCell.valueSwitch.on = [self switchSettingForCellAtIndex:indexPath.row];
            switchCell.delegate = self;
            return switchCell;
        }
        case DBUserInterfaceTableViewControllerCellAutolayoutTrace:
        case DBUserInterfaceTableViewControllerCellCurrentViewDescription:
        case DBUserInterfaceTableViewControllerCellViewControllerHierarchy:
        case DBUserInterfaceTableViewControllerCellFontFamilies: {
            UITableViewCell *basicCell = [tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerBasicCellIdentifier];
            basicCell.textLabel.text = title;
            return basicCell;
        }
        case DBUserInterfaceTableViewControllerCellDebuggingInformationOverlay: {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:DBUserInterfaceTableViewControllerButtonCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DBUserInterfaceTableViewControllerButtonCellIdentifier];
                cell.textLabel.textColor = cell.tintColor;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
            }
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
    NSString *title = [self titleForCellAtIndex:indexPath.row];
    switch (cell) {
        case DBUserInterfaceTableViewControllerCellAutolayoutTrace:
            [self openTextViewViewControllerWithTitle:title text:[self.userInterfaceToolkit autolayoutTrace]];
            break;
        case DBUserInterfaceTableViewControllerCellCurrentViewDescription: {
            UIView *currentView = self.navigationController.presentingViewController.view;
            [self openTextViewViewControllerWithTitle:title text:[self.userInterfaceToolkit viewDescription:currentView]];
            break;
        }
        case DBUserInterfaceTableViewControllerCellViewControllerHierarchy:
            [self openTextViewViewControllerWithTitle:title text:[self.userInterfaceToolkit viewControllerHierarchy]];
            break;
        case DBUserInterfaceTableViewControllerCellFontFamilies:
            [self openFontFamiliesTableViewController];
            break;
        case DBUserInterfaceTableViewControllerCellDebuggingInformationOverlay:
            [self.delegate userInterfaceTableViewControllerDidOpenDebuggingInformationOverlay:self];
            [self.userInterfaceToolkit showDebuggingInformationOverlay];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        default:
            return;
    }
}

#pragma mark - DBMenuSwitchTableViewCellDelegate 

- (void)menuSwitchTableViewCell:(DBMenuSwitchTableViewCell *)menuSwitchTableViewCell didSetOn:(BOOL)isOn {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:menuSwitchTableViewCell];
    DBUserInterfaceTableViewControllerCell cell = indexPath.row;
    switch (cell) {
        case DBUserInterfaceTableViewControllerCellColorBorders:
            self.userInterfaceToolkit.colorizedViewBordersEnabled = isOn;
            break;
        case DBUserInterfaceTableViewControllerCellSlowAnimations:
            self.userInterfaceToolkit.slowAnimationsEnabled = isOn;
            break;
        case DBUserInterfaceTableViewControllerCellShowTouches:
            self.userInterfaceToolkit.showingTouchesEnabled = isOn;
        default:
            return;
    }
}

@end
