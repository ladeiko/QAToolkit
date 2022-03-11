//
//  QATConfigurationPresetTableViewController.m
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 6/11/18.

//

#import "QATConfigurationPresetTableViewController.h"
#import "DBTextViewTableViewCell.h"
#import "NSBundle+QAToolkit.h"
#import "UIColor+QAToolkit.h"

@interface QATConfigurationPresetTableViewController ()

@property (nonatomic, assign) BOOL isChanged;
@property (nonatomic, assign) BOOL isChangedText;
@property (nonatomic, retain) NSArray* selected;


@end

@implementation QATConfigurationPresetTableViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSBundle *bundle = [NSBundle debugToolkitBundle];

    [self.tableView registerNib:[UINib nibWithNibName:@"DBTextViewTableViewCell" bundle:bundle]
         forCellReuseIdentifier:@"QATConfigPresetCustomReuseID"];
         _selected = [self.viewModel.selectedItems copy];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[QATConfigurationPresetTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self save];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isEmpty {
    return self.viewModel.numberOfPresets == 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self isEmpty] ? 1 : self.viewModel.numberOfPresets;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isEmpty]) {
        return section == 0 ? 1 : 0;
    }
    return [self.viewModel numberOfItemsInPreset:section];
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self isEmpty]) {
        return nil;
    }
    return [self.viewModel titleForPresetAtIndex:section];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self isEmpty] ? 0 : 32.0;
}

-(void) configureCell:(UITableViewCell*)cell withDataSource:(DBTitleValueTableViewCellDataSource*) dataSource andCustomCell:(BOOL) isNotCustom {
    
    if ([self isEmpty]) {
        return;
    }
    
    if (isNotCustom) {
        cell.textLabel.text = [dataSource.title uppercaseString];
        cell.detailTextLabel.text = dataSource.value;
    } else {
        // custom cell
        
        DBTextViewTableViewCell* textCell = (DBTextViewTableViewCell*) cell;
        textCell.titleLabel.text = [dataSource.title uppercaseString];
        textCell.textView.text = dataSource.value;
        textCell.delegate = self;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isEmpty]) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"empty"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"empty"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"No presets defined by developer";
        return cell;
    }
    
    DBTitleValueTableViewCellDataSource* dataSrc = [self.viewModel dataSourceForItemAtIndexPath:indexPath];
    BOOL isNotCustomCell = [dataSrc.title isEqualToString:@"custom"] == FALSE;

    NSString* reuseIdentifier =  isNotCustomCell? @"QATConfigPresetReuseID" : @"QATConfigPresetCustomReuseID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell withDataSource:dataSrc andCustomCell:isNotCustomCell];
    
    BOOL isSelectedItem = [self.viewModel.selectedItems containsObject:indexPath];
    
    cell.accessoryType = isSelectedItem ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
 
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isEmpty]) {
        return;
    }
    
    NSArray<NSIndexPath*>* thisSectionSelected = [self.viewModel.selectedItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject section] == [indexPath section];
    }]];
    
    if ([thisSectionSelected containsObject:indexPath]) {
        return;
    }
    
    [self.viewModel didSelectIndexPath:indexPath];
    [self.tableView reloadRowsAtIndexPaths:thisSectionSelected withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    _isChanged = true;
}

#pragma mark -
#pragma mark - Observers

- (void)applicationWillTerminate {
    [self save];
}

#pragma mark -
#pragma mark - Helpers

- (void)save {
    
    if(_isChanged){
        if(![_selected isEqualToArray:self.viewModel.selectedItems]){
            [self.viewModel applyChanges];//NOTIFICATION
        }
        _isChanged = NO;
    }
    
    if([_selected isEqualToArray:self.viewModel.selectedItems] && _isChangedText){
        [self.viewModel applyChanges];//NOTIFICATION
        _isChangedText = NO;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark DBTextViewTableViewCellDelegate handling

/**
 Informs the delegate that the text value was changed in the cell.
 
 @param textViewCell The cell with a text view that changed its value.
 */
- (void)textViewTableViewCellDidChangeText:(DBTextViewTableViewCell *)textViewCell {
    NSIndexPath* pathForChangedCustomCell = [self.tableView indexPathForCell:textViewCell];
    [self.viewModel setNewCustomValue:textViewCell.textView.text forIndexPath:pathForChangedCustomCell];
    _isChangedText = true;
}

/**
 Asks the delegate if the text can be changed to the given value in the text view.
 
 @param textViewCell The cell with a text view that requires new value validation.
 @param text The new text value that requires validation.
 */
- (BOOL)textViewTableViewCell:(DBTextViewTableViewCell *)textViewCell shouldChangeTextTo:(NSString *)text {
    return YES;
}

#pragma mark -

@end
