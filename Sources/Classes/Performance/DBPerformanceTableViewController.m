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

#import "DBPerformanceTableViewController.h"
#import "DBMenuSwitchTableViewCell.h"
#import "DBMenuSegmentedControlTableViewCell.h"
#import "DBMenuChartTableViewCell.h"
#import "NSBundle+QAToolkit.h"
#import "DBToolkitSettings.h"
#import "UIColor+QAToolkit.h"

static NSString *const DBPerformanceTableViewControllerSwitchCellIdentifier = @"DBMenuSwitchTableViewCell";
static NSString *const DBPerformanceTableViewControllerSegmentedControlCellIdentifier = @"DBMenuSegmentedControlTableViewCell";
static NSString *const DBPerformanceTableViewControllerValueCellIdentifier = @"DBMenuValueTableViewCell";
static NSString *const DBPerformanceTableViewControllerButtonCellIdentifier = @"DBMenuButtonTableViewCell";
static NSString *const DBPerformanceTableViewControllerChartCellIdentifier = @"DBMenuChartTableViewCell";
static const NSTimeInterval DBPerformanceTableViewControllerMarkedTimesInterval = 20.0;
static const CGFloat DBPerformanceTableViewControllerChartCellRatioConstant = 20.0;

typedef NS_ENUM(NSUInteger, DBPerformanceTableViewSection) {
    DBPerformanceTableViewSectionWidget,
    DBPerformanceTableViewSectionSegmentedControl,
    DBPerformanceTableViewSectionStatistics
};

@interface DBPerformanceTableViewController () <DBMenuSwitchTableViewCellDelegate, DBMenuSegmentedControlTableViewCellDelegate, DBPerformanceToolkitDelegate>

@end

@implementation DBPerformanceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    NSBundle *bundle = [NSBundle debugToolkitBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBMenuSwitchTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBPerformanceTableViewControllerSwitchCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBMenuSegmentedControlTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBPerformanceTableViewControllerSegmentedControlCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBMenuChartTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBPerformanceTableViewControllerChartCellIdentifier];
    self.performanceToolkit.delegate = self;
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBPerformanceTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
}

#pragma mark - Updating section

- (void)setSelectedSection:(DBPerformanceSection)selectedSection {
    _selectedSection = selectedSection;
    [self reloadStatisticsSectionAnimated:YES];
    [self refreshSegmentedControlCell];
}

#pragma mark - Reloading table view

- (void)reloadStatisticsSectionAnimated:(BOOL)animated {
    UITableViewRowAnimation animation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
    NSIndexSet *sectionsToReload = [NSIndexSet indexSetWithIndex:DBPerformanceTableViewSectionStatistics];
    [self.tableView reloadSections:sectionsToReload withRowAnimation:animation];
}

- (void)refreshSegmentedControlCell {
    NSIndexPath *segmentedControlIndexPath = [NSIndexPath indexPathForRow:0 inSection:DBPerformanceTableViewSectionSegmentedControl];
    DBMenuSegmentedControlTableViewCell *segmentedControlCell = [self.tableView cellForRowAtIndexPath:segmentedControlIndexPath];
    [segmentedControlCell.segmentedControl setSelectedSegmentIndex:self.selectedSection];
}

#pragma mark - Statistics section

- (NSInteger)numberOfRowsInStatisticsSection {
    switch (self.selectedSection) {
        case DBPerformanceSectionCPU:
            return 3;
        case DBPerformanceSectionFPS:
            return 3;
        case DBPerformanceSectionMemory:
            return 3;
    }
    
    return 0;
}

- (UITableViewCell *)siitchCellForRowAtIndex:(NSInteger)index {
    switch (index) {
        case 0:{
            DBMenuSwitchTableViewCell *switchTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerSwitchCellIdentifier];
            switchTableViewCell.titleLabel.text = @"Show widget";
            DBToolkitSettings *dbToolkitSettings = [DBToolkitSettings sharedInstance];
            
            self.performanceToolkit.isWidgetShown = dbToolkitSettings.widgetEnabled;
            switchTableViewCell.valueSwitch.on = self.performanceToolkit.isWidgetShown;
            switchTableViewCell.delegate = self;
            switchTableViewCell.valueSwitch.tag = 0;
            return switchTableViewCell;
            
        }
        case 1:{
            DBMenuSwitchTableViewCell *switchTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerSwitchCellIdentifier];
            switchTableViewCell.titleLabel.text = @"MemoryWarning каждые 2 сек.";
            switchTableViewCell.valueSwitch.on = self.performanceToolkit.isCycleMemoryWarning;
            switchTableViewCell.delegate = self;
            switchTableViewCell.valueSwitch.tag = 1;
            return switchTableViewCell;
            
        }
        case 2:{
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerButtonCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DBPerformanceTableViewControllerButtonCellIdentifier];
                cell.textLabel.textColor = cell.tintColor;
            }
            cell.textLabel.text = @"Memory warning";
            return cell;
            
        }
        case 3:{
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerButtonCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DBPerformanceTableViewControllerButtonCellIdentifier];
                cell.textLabel.textColor = cell.tintColor;
            }
            cell.textLabel.text = @"Крэш";
            return cell;
            
        }
    }
    return nil;
}

- (UITableViewCell *)statisticsCellForRowAtIndex:(NSInteger)index {
    
    switch (self.selectedSection) {
        case DBPerformanceSectionCPU:
            return [self cpuStatisticsCellForRowAtIndex:index];
        case DBPerformanceSectionMemory:
            return [self memoryStatisticsCellForRowAtIndex:index];
        case DBPerformanceSectionFPS:
            return [self fpsStatisticsCellForRowAtIndex:index];
    }
    
    return nil;
}

- (UITableViewCell *)cpuStatisticsCellForRowAtIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            UITableViewCell *cell = [self valueTableViewCell];
            cell.textLabel.text = @"CPU usage";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1lf%%", self.performanceToolkit.currentCPU];
            return cell;
        }
        case 1: {
            UITableViewCell *cell = [self valueTableViewCell];
            cell.textLabel.text = @"Max CPU usage";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1lf%%", self.performanceToolkit.maxCPU];
            return cell;
        }
        case 2: {
            DBMenuChartTableViewCell *chartCell = [self.tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerChartCellIdentifier];
            chartCell.chartView.maxValue = self.performanceToolkit.maxCPU;
            chartCell.chartView.markedValue = self.performanceToolkit.maxCPU;
            chartCell.chartView.markedValueFormat = @"%.1lf%%";
            chartCell.chartView.measurements = self.performanceToolkit.cpuMeasurements;
            chartCell.chartView.measurementsLimit = self.performanceToolkit.measurementsLimit;
            chartCell.chartView.measurementInterval = self.performanceToolkit.timeBetweenMeasurements;
            chartCell.chartView.markedTimesInterval = DBPerformanceTableViewControllerMarkedTimesInterval;
            return chartCell;
        }
    }
    
    return nil;
}

- (UITableViewCell *)memoryStatisticsCellForRowAtIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            UITableViewCell *cell = [self valueTableViewCell];
            cell.textLabel.text = @"Max memory usage";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1lf MB", self.performanceToolkit.maxMemory];
            return cell;
        }
        case 1: {
            UITableViewCell *cell = [self valueTableViewCell];
            cell.textLabel.text = @"Memory usage";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1lf MB", self.performanceToolkit.currentMemory];
            return cell;
        }
        case 2: {
            DBMenuChartTableViewCell *chartCell = [self.tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerChartCellIdentifier];
            chartCell.chartView.maxValue = self.performanceToolkit.maxMemory;
            chartCell.chartView.markedValue = self.performanceToolkit.maxMemory;
            chartCell.chartView.markedValueFormat = @"%.1lf";
            chartCell.chartView.measurements = self.performanceToolkit.memoryMeasurements;
            chartCell.chartView.measurementsLimit = self.performanceToolkit.measurementsLimit;
            chartCell.chartView.measurementInterval = self.performanceToolkit.timeBetweenMeasurements;
            chartCell.chartView.markedTimesInterval = DBPerformanceTableViewControllerMarkedTimesInterval;
            return chartCell;
        }
        
        
        
    }
    
    return nil;
}

- (UITableViewCell *)fpsStatisticsCellForRowAtIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            UITableViewCell *cell = [self valueTableViewCell];
            cell.textLabel.text = @"FPS";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0lf", self.performanceToolkit.currentFPS];
            return cell;
        }
        case 1: {
            UITableViewCell *cell = [self valueTableViewCell];
            cell.textLabel.text = @"Min FPS";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0lf", self.performanceToolkit.minFPS];
            return cell;
        }
        case 2: {
            DBMenuChartTableViewCell *chartCell = [self.tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerChartCellIdentifier];
            chartCell.chartView.maxValue = self.performanceToolkit.maxFPS;
            chartCell.chartView.markedValue = self.performanceToolkit.minFPS;
            chartCell.chartView.markedValueFormat = @"%.0lf";
            chartCell.chartView.measurements = self.performanceToolkit.fpsMeasurements;
            chartCell.chartView.measurementsLimit = self.performanceToolkit.measurementsLimit;
            chartCell.chartView.measurementInterval = self.performanceToolkit.timeBetweenMeasurements;
            chartCell.chartView.markedTimesInterval = DBPerformanceTableViewControllerMarkedTimesInterval;
            return chartCell;
        }
    }
    
    return nil;
}

- (UITableViewCell *)valueTableViewCell {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerValueCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DBPerformanceTableViewControllerValueCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == DBPerformanceTableViewSectionWidget && indexPath.row == 2) {
        // Simulate memory warning cell.
        [self.performanceToolkit simulateMemoryWarning];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.section == DBPerformanceTableViewSectionWidget && indexPath.row == 3) {
        // Simulate memory warning cell.
        //1.2.0
        NSLog(@"!_!_!_!_QAToolkit_:_Crash action!_!_!_!_! ");
        int* p = 0;
        *p = 0;
        @throw NSInternalInconsistencyException;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == DBPerformanceTableViewSectionStatistics && indexPath.row == 2) {
        // Chart cell.
        return tableView.bounds.size.width + DBPerformanceTableViewControllerChartCellRatioConstant;
    }
    return 44.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case DBPerformanceTableViewSectionWidget:{
            return 4;
        }
        case DBPerformanceTableViewSectionSegmentedControl:{
            return 1;
        }
        case DBPerformanceTableViewSectionStatistics:{
            
            return [self numberOfRowsInStatisticsSection];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case DBPerformanceTableViewSectionWidget: {
        
            return [self siitchCellForRowAtIndex:indexPath.row];
            
        }
        case DBPerformanceTableViewSectionSegmentedControl: {
            DBMenuSegmentedControlTableViewCell *segmentedControlTableViewCell = [tableView dequeueReusableCellWithIdentifier:DBPerformanceTableViewControllerSegmentedControlCellIdentifier];
            NSArray *segmentTitles = @[ @"CPU", @"Memory", @"FPS" ];
            [segmentedControlTableViewCell configureWithTitles:segmentTitles selectedIndex:self.selectedSection];
            segmentedControlTableViewCell.delegate = self;
            return segmentedControlTableViewCell;
        }
        case DBPerformanceTableViewSectionStatistics: {
            return [self statisticsCellForRowAtIndex:indexPath.row];
        }
    }
    assert(false);
    return nil;
}

#pragma mark - DBMenuSwitchTableViewCellDelegate

- (void)menuSwitchTableViewCell:(DBMenuSwitchTableViewCell *)menuSwitchTableViewCell didSetOn:(BOOL)isOn {
    
    switch (menuSwitchTableViewCell.valueSwitch.tag) {
        case 0:{
            self.performanceToolkit.isWidgetShown = isOn;
            DBToolkitSettings *dbToolkitSettings = [DBToolkitSettings sharedInstance];
            [dbToolkitSettings updateWidgetEnabled:isOn];
            
        }
        case 1:{
            self.performanceToolkit.isCycleMemoryWarning = isOn;
            
        }
    }
    
    
}

#pragma mark - DBMenuSegmentedControlTableViewCellDelegate

- (void)menuSegmentedControlTableViewCell:(DBMenuSegmentedControlTableViewCell *)menuSegmentedControlTableViewCell didSelectSegmentAtIndex:(NSUInteger)index {
    self.selectedSection = index;
}

#pragma mark - DBPerformanceToolkitDelegate 

- (void)performanceToolkitDidUpdateStats:(DBPerformanceToolkit *)performanceToolkit {
    [self reloadStatisticsSectionAnimated:NO];
}

@end
