//
//  QATConfigurationPresetToolkit.m
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 6/12/18.

//

#import "QATConfigurationPresetToolkit.h"
@import UIKit;
#import "DBToolkitSettings.h"

typedef enum : NSUInteger {
    FIRST_ITEM,
    
    CONTENT_ITEM = FIRST_ITEM,
    DEVEL_ITEM,
    RELEASE_ITEM,
    TEST_ITEM,
    CUSTOM_ITEM,
    
    LAST_ITEM = CUSTOM_ITEM,
    ITEMS_COUNT
} QATConfigPresetsItem;


typedef enum : NSUInteger {
    QATConfigEnvironmentFirst,
    QATConfigWorkingEnvironment = QATConfigEnvironmentFirst,
    QATConfigContentEnvironment,
    
    QATConfigEnvironmentLast = QATConfigContentEnvironment,
    QATConfigEnvironmentCount
} QATConfigEnvironment;

NSString * const QATContentPreset     = @"content";
NSString * const QATDevelopmentPreset = @"devel";
NSString * const QATReleasePreset     = @"release";
NSString * const QATTestPreset        = @"test";
NSString * const QATCustomPreset      = @"custom";

NSString * const QATContentPresetTitle      = @"CONTENT";
NSString * const QATDevelopmentPresetTitle  = @"DEVEL";
NSString * const QATReleasePresetTitle      = @"RELEASE";
NSString * const QATTestPresetTitle         = @"TEST";
NSString * const QATCustomPresetTitle       = @"CUSTOM";


// Notification
NSString * const QATConfigurationPresetDidChangedNotification = @"QATConfigurationPresetDidChangedNotification";

NSString * const QATConfigurationPresetsKey = @"QATConfigurationPresetsKey";

NSString * const QATConfigurationPresetTypeKey = @"QATConfigurationTypeKey";
NSString * const QATConfigTypeWorkEnvironment = @"QATConfigTypeWorkEnvironment";
NSString * const QATConfigTypeWorkEnvironmentTitle = @"Working Environment";
NSString * const QATConfigTypeContentEnvironment = @"QATConfigTypeContentEnvironment";
NSString * const QATConfigTypeContentEnvironmentTitle = @"Content Environment";


NSString * const QATConfigurationPresetNameKey = @"QATConfigurationPresetName";
NSString * const QATConfigurationPresetValueKey = @"QATConfigutationPresetValue";


@interface QATConfigurationPresetToolkit () {
    NSInteger _selectedItemIndex;
}

@property (copy) NSString *customValue;

@property (copy) NSString *basePresetWithPlaceholder;

@property (strong, readonly) NSMutableArray<NSMutableDictionary *> *presetsInfo;

@end

@implementation QATConfigurationPresetToolkit

@synthesize customValue, basePresetWithPlaceholder;
@synthesize presetsInfo;

-(instancetype) init {
    self = [super init];
    if (self) {
        presetsInfo = [NSMutableArray new];
        //[self initializeDefaultConfigurationPresetInfo];
    }
    
    return self;
}

-(NSString*) applicationName {
    //Check POD
    assert([NSThread isMainThread]);
    NSBundle* bundle = [NSBundle mainBundle];
    return [bundle.infoDictionary[@"CFBundleName"] lowercaseString];
}


-(NSString*) applicationVersion {
    //Check POD
    assert([NSThread isMainThread]);
    return NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
}

//localhost
//-(void) initializeDefaultConfigurationPresetInfo {
//    assert([NSThread isMainThread]);
//    NSString* appName = self.applicationName;
//    NSString* appVer  = self.applicationVersion;
//    
//    NSArray* defaultConfig = @[
//                               
//                               // working environment presets item 0
//                               @{
//                                   @"preset"      : QATConfigTypeWorkEnvironment, // preset type
//                                   @"presetItems" : @[ // 5 predefined items: content, devel, release, test and custom.
//                                           @{
//                                               @"title" : [QATContentPresetTitle lowercaseString],
//                                               @"value" : [NSString stringWithFormat:@"https://localhost/%@/conf/cnt/%@/", appName, appVer]
//                                               },
//                                           
//                                           @{
//                                               @"title" : [QATDevelopmentPresetTitle lowercaseString],
//                                               @"value" : [NSString stringWithFormat:@"https://localhost/%@/conf/dev/%@/", appName, appVer]
//                                               },
//                                           
//                                           @{
//                                               @"title" : [QATReleasePresetTitle lowercaseString],
//                                               @"value" : [NSString stringWithFormat:@"https://localhost/%@/conf/release/%@/", appName, appVer]
//                                               },
//                                           
//                                           @{
//                                               @"title" : [QATTestPresetTitle lowercaseString],
//                                               @"value" : [NSString stringWithFormat:@"https://localhost/%@/conf/tst/%@/", appName, appVer]
//                                               },
//                                           
//                                           // optional item (initialized with test-preset values by default)
//                                           @{
//                                               @"title" : [QATCustomPresetTitle lowercaseString],
//                                               @"value" : [NSString stringWithFormat:@"https://localhost/%@/conf/tst/%@/", appName, appVer]
//                                               }
//                                           ],
//                                   @"selected" : @(TEST_ITEM) // index of selected preset item.
//                                   
//                                   }
//                               
//                                // (optional) content presets.
//                                , @{
//                                   @"preset"      : QATConfigTypeContentEnvironment,
//                                   @"presetItems" : @[
//                                           @{
//                                               @"title" : @"preview",
//                                               @"value" : [NSString stringWithFormat:@"https://%@.localhost/preview/%@/", appName, appVer]
//                                               },
//
//                                           @{
//                                               @"title" : @"devel",
//                                               @"value" : [NSString stringWithFormat:@"https://%@.localhost/devel/%@/", appName, appVer]
//                                               },
//
//                                           @{
//                                               @"title" : @"release",
//                                               @"value" : [NSString stringWithFormat:@"https://%@.localhost/release/%@/", appName, appVer]
//                                               },
//
//                                           @{
//                                               @"title" : @"test",
//                                               @"value" : [NSString stringWithFormat:@"https://%@.localhost/test/%@/", appName, appVer]
//                                               },
//
//                                           // optional item
//                                           @{
//                                               @"title" : @"custom",
//                                               @"value" : [NSString stringWithFormat:@"https://%@.localhost/test_foo_bar/%@/", appName, appVer]
//                                               }
//                                           ],
//                                        @"selected" : @(3)    // 0..numItems-1
//                                   }
////
//                               ];
//    
//    [self setConfigurationPresets:defaultConfig];
//    
//}

- (NSArray<NSDictionary*>*)presets {
    assert([NSThread isMainThread]);
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:presetsInfo]];
}

-(NSString*) currentPreset {
    assert([NSThread isMainThread]);
    NSMutableString* preset = [[NSMutableString alloc] initWithCapacity:presetsInfo.count];
    
    NSArray<NSIndexPath*> *selIndexes = self.selectedItems;
    
    NSUInteger count = selIndexes.count;
    
    for (NSUInteger idx = 0; idx < count; idx++) {
        
        if (idx < count - 1) {
            
            NSIndexPath* idxPath = selIndexes[idx];
            NSString* title = presetsInfo[idxPath.section][@"presetItems"][idxPath.row][@"title"];
            if (title) {
                [preset appendFormat:@"%@, ",title];
            }
            
        } else {
            // for the last component without comma
            NSIndexPath* idxPath = selIndexes[idx];
            NSString* title = presetsInfo[idxPath.section][@"presetItems"][idxPath.row][@"title"];
            if (title) {
                [preset appendString:title];
            }
        }
        
    }
    
    return [[NSString stringWithString:preset] uppercaseString];
}


- (void) setConfigurationPresets:(NSArray<NSDictionary *>*) presets {
    assert([NSThread isMainThread]);
    [self.presetsInfo removeAllObjects];
    
    for (NSDictionary* cfgEnv in presets) {
        NSMutableDictionary *mutableCfgEnv = [[NSMutableDictionary alloc] initWithCapacity:cfgEnv.count];
        
        mutableCfgEnv[@"preset"] = cfgEnv[@"preset"];
        mutableCfgEnv[@"selected"] = cfgEnv[@"selected"];
        
        NSArray<NSDictionary*>* srcPrItems = cfgEnv[@"presetItems"];
        NSMutableArray<NSMutableDictionary*>* prItems = [[NSMutableArray alloc] initWithCapacity:srcPrItems.count];
        
        for (NSDictionary* srcPrItem in srcPrItems) {
            [prItems addObject:[NSMutableDictionary dictionaryWithDictionary:srcPrItem]];
        }
        
        mutableCfgEnv[@"presetItems"] = prItems;
        
        [self.presetsInfo addObject:mutableCfgEnv];
    }
}

-(nullable NSDictionary*) getPresetItemWithTitle:(NSString*) title fromPresetItems:(NSArray<NSDictionary*> *) presetItems {
    assert([NSThread isMainThread]);
    if (!presetItems) {return nil;}
    
    NSInteger idx = [presetItems indexOfObjectPassingTest:^BOOL(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [title isEqualToString:obj[@"title"]] ) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    return idx != NSNotFound ? presetItems[idx] : nil;
}


- (BOOL) testItemWithTitle:(NSString*) title forPresetItems:(NSArray<NSDictionary*> *) presetItems {
    assert([NSThread isMainThread]);
    NSDictionary* item = [self getPresetItemWithTitle:title fromPresetItems:presetItems];
    if (!item) {
        return FALSE;
    }
    
    NSString* value = item[@"value"];
    if (!value) {
        return FALSE;
    }
    
    return [value length] > 0;
}

#pragma mark QATConfigurationPresetModelProtocol



/**
 @brief Get number of presets available to process.
 @return number of presets or zero if no items.
 */
-(NSInteger) numberOfPresets {
    assert([NSThread isMainThread]);
    NSInteger num = 0;
    
    if (presetsInfo) {
        num = presetsInfo.count;
    }
    
    return num;
}



/// returns index paths selected for every configurable environment (Working or Content)
-(nullable NSArray<NSIndexPath*>*) selectedItems {
    assert([NSThread isMainThread]);
    if (!presetsInfo) {
        return nil;
    }
    
    if (presetsInfo.count == 0) {
        return @[];
    }
    
    NSMutableArray<NSIndexPath*> *resultArray = [[NSMutableArray alloc] initWithCapacity:presetsInfo.count];
    NSInteger countOfConfEnvironments =  presetsInfo.count;
    for (NSInteger envIndex = 0; envIndex < countOfConfEnvironments; envIndex++) {
        NSInteger evnSelectedItemIndex = [presetsInfo[envIndex][@"selected"] integerValue];
        NSIndexPath* selection = [NSIndexPath indexPathForRow:evnSelectedItemIndex inSection:envIndex];
        [resultArray addObject:selection];
    }
    
    return [NSArray arrayWithArray:resultArray];
}




-(NSInteger) numberOfItemsInPreset:(NSInteger) presetIndex {
    assert([NSThread isMainThread]);
    NSAssert( presetIndex >= 0 && presetIndex < self.presetsInfo.count, @"QAToolkit: preset index is out of bounds.");
    
    NSInteger num = 0;
    
    NSMutableArray<NSMutableDictionary *> *prItems = self.presetsInfo[presetIndex][@"presetItems"];
    if (prItems) {
        num = prItems.count;
    }
    
    return num;
}


-(NSString*) humanReadablePresetName:(NSString*) presetTypeName {
    assert([NSThread isMainThread]);
    
    if ([presetTypeName isEqualToString:QATConfigTypeWorkEnvironment]) {
        return QATConfigTypeWorkEnvironmentTitle;
        
    } else if ([presetTypeName isEqualToString:QATConfigTypeContentEnvironment]) {
        return QATConfigTypeContentEnvironmentTitle;
    }
    
    return presetTypeName;
}

-(NSString*) titleForPresetAtIndex:(NSInteger) presetIndex {
    assert([NSThread isMainThread]);
    NSAssert( presetIndex >= 0 && presetIndex < self.presetsInfo.count, @"QAToolkit: preset index is out of bounds.");
    
    NSString* preset = self.presetsInfo[presetIndex][@"preset"];
    
    
    
    return [self humanReadablePresetName:preset];
}

-(NSDictionary*) presetItemForIndexPath:(NSIndexPath*) indexPath {
    assert([NSThread isMainThread]);
    NSAssert1( indexPath.section >= 0 && indexPath.section  < self.presetsInfo.count, @"QAToolkit: preset index (%ld) is out of bounds.", (long)indexPath.section);
    NSMutableArray<NSMutableDictionary *> *prItems = self.presetsInfo[indexPath.section][@"presetItems"];
    NSAssert1( indexPath.row >= 0 && indexPath.row < prItems.count, @"QAToolkit: preset item index (%ld) is out of bounds.", (long)indexPath.row);
    
    return [NSDictionary dictionaryWithDictionary:prItems[indexPath.row]];
}

-(DBTitleValueTableViewCellDataSource*) dataSourceForItemAtIndexPath:(NSIndexPath*) indexPath {
    assert([NSThread isMainThread]);
    NSDictionary* item = [self presetItemForIndexPath:indexPath];
    return [DBTitleValueTableViewCellDataSource dataSourceWithTitle:item[@"title"] value:item[@"value"]];
}


-(void) setNewCustomValue:(NSString*) value forIndexPath:(NSIndexPath*) indexPath {
    assert([NSThread isMainThread]);
    NSMutableArray* presetItems = presetsInfo[indexPath.section][@"presetItems"];
    if (!presetItems) { return; }
    
    NSUInteger customPresetItemIndex = [presetItems indexOfObjectPassingTest:^BOOL(NSMutableDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"title"] isEqualToString:@"custom"]) {
            *stop = YES;
            return TRUE;
        }
        return FALSE;
    }];
    
    if (customPresetItemIndex != NSNotFound) {
        // update custom value
        self.presetsInfo[indexPath.section][@"presetItems"][customPresetItemIndex][@"value"] = value;
    } else {
        
        //add new custom value
        NSMutableDictionary* customPresetItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"custom",@"title",value,@"value", nil];
        [self.presetsInfo[indexPath.section][@"presetItems"] addObject:customPresetItem];
    }
    
}


-(void) didSelectIndexPath:(NSIndexPath *)indexPath {
    assert([NSThread isMainThread]);
    presetsInfo[indexPath.section][@"selected"] = [NSNumber numberWithInteger:indexPath.row];
}

-(void) applyChanges {
    assert([NSThread isMainThread]);
    [self sendUpdateNotification];
}

-(void) sendUpdateNotification {
    assert([NSThread isMainThread]);
    NSMutableArray<NSDictionary *> *selectedPresets = [[NSMutableArray alloc] initWithCapacity:self.presetsInfo.count];
    NSArray<NSIndexPath *> *selected = self.selectedItems;
    NSMutableArray *selectedPres = [[NSMutableArray alloc] init];
    
    for (NSIndexPath* indexPath in selected) {
        
        
        NSString* selected = [NSString stringWithFormat:@"%lu", (unsigned long)[[NSNumber numberWithInteger:indexPath.row] integerValue]];
        
        [selectedPres addObject:selected];
        
        
        NSDictionary* presetItem = [self presetItemForIndexPath:indexPath];
        NSString* configEnvType = [self titleForPresetAtIndex:indexPath.section];
        
        
        [selectedPresets addObject:@{
                                     QATConfigurationPresetTypeKey  : configEnvType,
                                     QATConfigurationPresetNameKey  : presetItem[@"title"],
                                     QATConfigurationPresetValueKey : presetItem[@"value"]
                                     }];
    }
    DBToolkitSettings *settings = [DBToolkitSettings sharedInstance];
    
    [settings updateSelectedPresets:[[selectedPres valueForKey:@"description"] componentsJoinedByString:@","]];
    
    NSArray<NSDictionary *> * configPresets = [NSArray arrayWithArray:selectedPresets];
    NSDictionary *usrInfo = @{QATConfigurationPresetsKey : configPresets};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QATConfigurationPresetDidChangedNotification object:self userInfo:usrInfo];
}

#pragma mark -

@end
