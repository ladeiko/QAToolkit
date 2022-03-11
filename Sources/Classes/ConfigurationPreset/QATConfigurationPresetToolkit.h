//
//  QATConfigurationPresetToolkit.h
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 6/12/18.

//

#import <Foundation/Foundation.h>

#import "QATConfigurationPresetModelProtocol.h"


/**
  * @class QATConfigurationPresetToolkit
  * @brief used for operating with configuration presets which comes from application side.
 */
@interface QATConfigurationPresetToolkit : NSObject <QATConfigurationPresetModelProtocol>

@property (strong, readonly) NSString *currentPreset;
@property (copy, readonly) NSArray<NSDictionary*>* presets;

/**
 * @method setConfigurationPresets:
 * @abstract Set values for corresponding configuration presets of working environment and content.
 * These presets values will be send via QATConfigurationPresetDidChangedNotification back to application.
 * @param presets array of two dictionaries. The first one contains presets for working environment
 * and the second contains presets for content environment if needed (in this case only one item in array).
 *
 * @availability QAToolkit > 1.2
 * @code @[
 
    // working environment presets item 0
    @{
        @"preset"      : @"WorkingEnvironment", // preset type
        @"presetItems" : @[ // 5 predefined items: content, devel, release, test and custom.
            @{
                @"title" : @"content",
                @"value" : @"https://publisher.com/appname/conf/cnt/1.0/"
            },
            
            @{
                @"title" : @"devel",
                @"value" : @"https://publisher.com/appname/conf/dev/1.0/"
            },
            
            @{
                @"title" : @"release",
                @"value" : @"https://publisher.com/appname/conf/release/1.0/"
            },
            
            @{
                @"title" : @"test",
                @"value" : @"https://publisher.com/appname/conf/tst/1.0/"
            },
            
            // optional item (initialized with test-preset values by default)
            @{
                @"title" : @"custom",
                @"value" : @"https://publisher.com/appname/conf/tst_foo_bar/1.0/"
            }
        ],
        @"selected" : @(4) // index of selected preset item.
    
    },
 
    // (optional) content presets.
    @{
        @"preset"      : @"ContentEnvironment",
        @"presetItems" : @[
            @{
                @"title" : @"preview",
                @"value" : @"https://appname.publisher.com/preview/1.0/"
            },
 
            @{
                @"title" : @"devel",
                @"value" : @"https://appname.publisher.com/devel/1.0/"
            },
 
             @{
                 @"title" : @"release",
                 @"value" : @"https://appname.publisher.com/release/1.0/"
             },
            
            // optional item 
            @{
                @"title" : @"custom",
                @"value" : @"https://appname.publisher.com/test_foo_bar/1.0/"
            }
        ],
        @"selected" : @(1)    // 0..numItems-1
    }
 * ];
 */
- (void) setConfigurationPresets:(NSArray<NSDictionary *>*) presets;

//Force Active Preset notification
- (void) sendUpdateNotification;

@end
