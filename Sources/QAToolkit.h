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

#import <Foundation/Foundation.h>
#import "QAToolkitTrigger.h"
#import "DBCustomAction.h"
#import "DBCustomVariable.h"
#import "DBTapTrigger.h"
#import "DBLongPressTrigger.h"
#import "DBShakeTrigger.h"
#import "iSmartDebugKit.h"

/**
 `QAToolkit` provides the interface that can be used to setup and customize the debugging tools.
 */
@interface QAToolkit : NSObject

///------------
/// @name Setup
///------------

/**
 Sets up the `QAToolkit` with one default trigger: `DBShakeTrigger`.
*/
+ (void)setup;
+ (void)setupNOWidget;
/**
 Sets up the `QAToolkit` with provided triggers.
 
 @param triggers Array of triggers that should be used to open the `QAToolkit` menu. The objects it contains should adopt the protocol `QAToolkitTrigger`.
 */
+ (void)setupWithTriggers:(NSArray <id <QAToolkitTrigger>> *)triggers;


///--------------------------
/// @name Convenience methods
///--------------------------

/**
 Enables or disables console output capturing, which by default is enabled.
 
 @param enabled Determines whether console output capturing should be enabled or disabled.
 */
+ (void)setCapturingConsoleOutputEnabled:(BOOL)enabled;

/**
 Enables or disables network requests logging, which by default is enabled.
 
 @param enabled Determines whether network requests logging should be enabled or disabled.
 */
+ (void)setNetworkRequestsLoggingEnabled:(BOOL)enabled;

+ (void)shutdownNetworkRequestsLogging;
/**
 Removes all your application's entries from the keychain.
 */
+ (void)clearKeychain;

/**
 Removes all your application's entries from the `NSUserDefaults`.
 */
+ (void)clearUserDefaults;

/**
 Shows the menu.
 */
+ (void)showMenu;

/**
 Hides the menu.
 */
+(void) hideMenu;

/**
 Shows the performance widget.
 */
+ (void)showPerformanceWidget;

+ (void)forceNoWidget;
+ (void)forceShowWidget;

+ (void)addWidgetToKeyWindow;

/**
 Shows the `UIDebuggingInformationOverlay` (if available).
 */
+ (void)showDebuggingInformationOverlay;

+ (void)registerSecurityApplicationGroupIdentifier:(NSString*)identifier;
+ (NSArray<NSString*>*)registeredSecurityApplicationGroupIdentifiers;

///---------------------
/// @name Custom actions
///---------------------

/**
 Adds a single `DBCustomAction` instance to the array accessible in the menu.
 
 @param customAction The `DBCustomAction` instance that should be accessible in the menu.
 */
+ (void)addCustomAction:(DBCustomAction *)customAction;

/**
 Removes a single `DBCustomAction` instance from the array accessible in the menu.
 
 @param customActionName Name of the `DBCustomAction` instance that is already accessible in the menu.
 */
+ (void)removeCustomActionWithName:(NSString *)customActionName;

/**
 Adds multiple `DBCustomAction` instances to the array accessible in the menu.
 
 @param customActions An array of `DBCustomAction` instances that should be accessible in the menu.
 */
+ (void)addCustomActions:(NSArray <DBCustomAction *> *)customActions;

+ (NSDictionary*)getCustomActions;
///-----------------------
/// @name Custom variables
///-----------------------

/**
 Adds a single `DBCustomVariable` instance to the array accessible in the menu.
 
 @param customVariable The `DBCustomVariable` instance that should be accessible in the menu.
 */
+ (void)addCustomVariable:(DBCustomVariable *)customVariable;

/**
 Adds multiple `DBCustomVariable` instances to the array accessible in the menu.
 
 @param customVariables An array of `DBCustomVariable` instances that should be accessible in the menu.
 */
+ (void)addCustomVariables:(NSArray <DBCustomVariable *> *)customVariables;

/**
 Removes a single `DBCustomVariable` instance with the given name.
 
 @param variableName The name of the variable that should be removed.
 */
+ (void)removeCustomVariableWithName:(NSString *)variableName;

/**
 Removes multiple `DBCustomVariable` instances with the names contained in the given array.
 
 @param variableNames An array of the names of the variables that should be removed.
 */
+ (void)removeCustomVariablesWithNames:(NSArray <NSString *> *)variableNames;

/**
 Returns a `DBCustomVariable` instance with a given name. If there is no such an instance, the method returns `nil`.
 
 @param variableName The name of the accessed variable.
 */
+ (DBCustomVariable *)customVariableWithName:(NSString *)variableName;



///-----------------------
/// @name Configuration Presets
///-----------------------

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
        selected : @(4) // index of selected preset item.
    
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
             }
             
            // optional item 
            @{
                @"title" : @"custom",
                @"value" : @"https://appname.publisher.com/test_foo_bar/1.0/"
            }
        ],
        selected : @(1)    // 0..numItems-1
    }
 * ];
 */
+ (void) setConfigurationPresets:(NSArray<NSDictionary *>*) presets;

+ (void) sendConfigurationPresetsNotification;

+ (id)currentConfigurationPresetValueForEnvironment:(NSString*)environment;

///--------------------
/// @name Crash reports
///--------------------

/**
 Enables collecting crash reports.
 */
+ (void)setupCrashReporting;

/**
Disables collecting crash reports.
*/
//+ (void)stopCrashReporting;

/**
 Setup QAToolkit Settings.
 */
//1.2.0
- (void)setupSettings;

@end


///--------------------
/// @name Configuration presets constants.
///--------------------

/**
 * @constant QATConfigurationPresetDidChangedNotification
 * @brief Notification with that name is sended to application when configuration of environment was changed.
 * @discussion Application should handle this notification: reset data and start new initialization cycle (synchronization)
 *      with new configuration preset.
 *
 * @availability QAToolkit > 1.2
 * @code
 * userInfo = @{
 *  @"QATConfigurationPresetsKey" : @[
 *      @{
 *        @"QATConfigurationTypeKey"     : @"Working Environment",
 *        @"QATConfigurationPresetName"  : @"test",
 *        @"QATConfigutationPresetValue" : @"https://localhost/appname/conf/tst/1.2/"
 *      },
 *      // optional
 *      @{
 *        @"QATConfigurationTypeKey"     : @"Content Environment",
 *        @"QATConfigurationPresetName"  : @"release",
 *        @"QATConfigutationPresetValue" : @"https://appname.localhost/release/1.2/"
 *      }
 *  ]
 * };
 */
extern NSString * const QATConfigurationPresetDidChangedNotification;

extern NSString * const QATConfigutationPresetNameKey;
extern NSString * const QATConfigurationPresetValueKey;

extern NSString * const QATConfigurationPresetTypeKey;
extern NSString * const QATConfigTypeWorkEnvironmentTitle;
extern NSString * const QATConfigTypeContentEnvironmentTitle;

// predefined environments (used by default)
extern NSString* const QATConfigTypeWorkEnvironment;
extern NSString* const QATConfigTypeContentEnvironment;

// predefined configuration presets names (content, devel, release, test, custom)
extern NSString * const QATContentPreset;
extern NSString * const QATDevelopmentPreset;
extern NSString * const QATReleasePreset;
extern NSString * const QATTestPreset;
extern NSString * const QATCustomPreset;

