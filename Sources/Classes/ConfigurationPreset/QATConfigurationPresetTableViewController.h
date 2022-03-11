//
//  QATConfigurationPresetTableViewController.h
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 6/11/18.

//

#import "QAToolkit.h"
#import "QATConfigurationPresetModelProtocol.h"
#import "DBTextViewTableViewCell.h"


/**
 Table for choosing configuration presets or set custom config value
 */
@interface QATConfigurationPresetTableViewController : UITableViewController <DBTextViewTableViewCellDelegate>

/**
 An object that provides the data displayed in the view controller and handles the user interaction. It needs to conform to `QATConfigurationPresetModelProtocol` protocol.
 */
@property (nonatomic, strong) id <QATConfigurationPresetModelProtocol> viewModel;

@end
