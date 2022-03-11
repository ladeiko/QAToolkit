//
//  QATConfigurationPresetModelProtocol.h
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 6/12/18.

//

#ifndef QATConfigurationPresetModelProtocol_h
#define QATConfigurationPresetModelProtocol_h

#import "DBTitleValueTableViewCellDataSource.h"
@import UIKit;

@protocol QATConfigurationPresetModelProtocol
@property (assign, readonly) NSInteger numberOfPresets;
@property (strong, readonly) NSArray<NSIndexPath *> *selectedItems;


-(NSInteger) numberOfItemsInPreset:(NSInteger) presetIndex;
-(NSString*) titleForPresetAtIndex:(NSInteger) presetIndex;
-(NSDictionary*) presetItemForIndexPath:(NSIndexPath*) indexPath;
-(DBTitleValueTableViewCellDataSource*) dataSourceForItemAtIndexPath:(NSIndexPath*) indexPath;

-(void) setNewCustomValue:(NSString*) value forIndexPath:(NSIndexPath*) indexPath;
-(void) didSelectIndexPath:(NSIndexPath*) indexPath;

-(void) applyChanges;

@end

#endif /* QATConfigurationPresetModelProtocol_h */
