//
//  iSmartDebugKit.h
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 5/31/18.
//

/*!
 * @file        iSmartDebugKit.h
 * @author      Siarhei Ladzeika
 * @version     3.0
 * @brief       Declaration of iSmartDebugKit class for QAToolkit.
 */

/*!
 @mainpage   iSmartDebugKit

 @tableofcontents

 @image html screenshot.png

 @section    Features Features

 Supported features (v3.0 for QAToolKit):

 @li Realtime tuning of some debug variables

 @li Running custom actions from UI

 @li Application console logs

 @section    SourceCode Source Code

 You can obtain source code from GIT:

 @section    Usage Usage

 Steps:
 */

#ifndef iSmartDebugKit_h
#define iSmartDebugKit_h


#import <Foundation/Foundation.h>


#ifndef NEW_DKP_DESIGN
# define NEW_DKP_DESIGN         1
#endif

#ifndef SYSTEM_LOGS_USE_ZLIB
# define SYSTEM_LOGS_USE_ZLIB         0
#endif

#import "iSmartDebugKitARCSupport.h"

@interface iSmartDebugKitBlock : NSObject
#if iSmartDebugKit_uses_arc
@property (nonatomic,copy) id actionBlock;
#else
@property (nonatomic,readonly,assign) void* actionBlock;
#endif
+ (instancetype)blockWithBlock:(id)block;
@end


#pragma clang diagnostic ignored "-Wstrict-prototypes"
/*!
 @brief Typedef for action which can be registered with debug kit.
 */
typedef void        (^iSmartDebugKitCustomAction)();

/*!
 @addtogroup DebugKitVariablesSettersAndGettersBlocks
 @{
 */

/*!
 @brief Typedef for boolean setter.
 */
typedef void        (^iSmartDebugKitTunableBooleanValueSetter)(BOOL value);

/*!
 @brief Typedef for boolean getter.
 */
typedef BOOL        (^iSmartDebugKitTunableBooleanValueGetter)();

/*!
 @brief Typedef for int setter.
 */
typedef void        (^iSmartDebugKitTunableIntegerValueSetter)(int value);

/*!
 @brief Typedef for int getter.
 */
typedef int         (^iSmartDebugKitTunableIntegerValueGetter)();

/*!
 @brief Typedef for float setter.
 */
typedef void        (^iSmartDebugKitTunableFloatValueSetter)(float value);

/*!
 @brief Typedef for float getter.
 */
typedef float       (^iSmartDebugKitTunableFloatValueGetter)();

/*!
 @brief Typedef for double setter.
 */
typedef void        (^iSmartDebugKitTunableDoubleValueSetter)(double value);

/*!
 @brief Typedef for double getter.
 */
typedef double      (^iSmartDebugKitTunableDoubleValueGetter)();

/*!
 @brief Typedef for string setter.
 */
typedef void        (^iSmartDebugKitTunableStringValueSetter)(NSString* value);

/*!
 @brief Typedef for string getter.
 */
typedef NSString*   (^iSmartDebugKitTunableStringValueGetter)();


enum
{
    iSmartDebugKitTunableBoolean = 1000,
    iSmartDebugKitTunableFloat,
    iSmartDebugKitTunableDouble,
    iSmartDebugKitTunableInteger,
    iSmartDebugKitTunableString,
};

extern NSString* iSmartDebugKitDidChangeApplicationLocaleNotification;


extern NSString* iSmartDebugKitTunableVariableTypeKey;

/*!
 @brief Keeps NSNumber minimum value.
 */
extern NSString* iSmartDebugKitTunableVariableMinValueKey;

/*!
 @brief Keeps NSNumber maximum value.
 */
extern NSString* iSmartDebugKitTunableVariableMaxValueKey;

/*!
 @brief Keeps NSArray of NSNumber objects.
 */
extern NSString* iSmartDebugKitTunableVariableRangeValueKey;

/*!
 @brief Keeps setter block of variable as iSmartDebugKitBlock.
 @code
 // To use it you should make casting, for example:
 ((iSmartDebugKitTunableBooleanValueSetter*)[dic objectForKey:iSmartDebugKitTunableVariableSetterKey])(YES);
 @endcode
 */
extern NSString* iSmartDebugKitTunableVariableSetterKey;

/*!
 @brief Keeps getter block of variable as iSmartDebugKitBlock.
 @code
 // To use it you should make casting, for example:
 const BOOL v = ((iSmartDebugKitTunableBooleanValueGetter*)[dic objectForKey:iSmartDebugKitTunableVariableSetterKey])();
 @endcode
 */extern NSString* iSmartDebugKitTunableVariableGetterKey;

/*!
 @brief Keeps name of variable as NSString.
 */
extern NSString* iSmartDebugKitTunableVariableNameKey;
extern NSString* const iSmartDebugKitTunableVariableAllowedKey;

/*!
 @}
 */

/*!
 @brief It is posted when some new tunable variable was added or removed.
 */
extern NSString* iSmartDebugKitTunableVariablesListDidChangeNotification;

/*!
 @brief It is posted when some new action was added or removed.
 */
extern NSString* iSmartDebugKitCustomActionsListDidChangeNotification;

/*!
 @brief It is posted when value of some tunable variable was changed.
 @note User info will contain name of changed varible under the iSmartDebugKitTunableVariableNameKey key.
 */
extern NSString* iSmartDebugKitTunableVariableValueDidChangeNotification;


@interface iSmartDebugKit : NSObject

//UI/INIT/Access
+ (iSmartDebugKit*)defaultKit;


- (void)hidePanel;


- (void)showPanel;

// NOT IMPLEMENTED
- (void)setShakeEnabled:(BOOL)enable;


//VARS
- (void)addTunableBooleanNamed:(NSString*)_named
                        setter:(iSmartDebugKitTunableBooleanValueSetter)_setter
                        getter:(iSmartDebugKitTunableBooleanValueGetter)_getter;

- (void)addPersistentTunableBooleanNamed:(NSString*)name defaultValue:(BOOL)defaultValue;
- (BOOL)tunableBooleanForName:(NSString*)name;
- (BOOL)tunableBooleanForName:(NSString*)name defaultValue:(BOOL)defaultValue;

- (void)addTunableIntegerNamed:(NSString*)_named
                        setter:(iSmartDebugKitTunableIntegerValueSetter)_setter
                        getter:(iSmartDebugKitTunableIntegerValueGetter)_getter
                      minValue:(int)_minValue
                      maxValue:(int)_maxValue;

- (void)addTunableIntegerNamed:(NSString*)_named
                        setter:(iSmartDebugKitTunableIntegerValueSetter)_setter
                        getter:(iSmartDebugKitTunableIntegerValueGetter)_getter;

// NOT IMPLEMENTED

- (void)addTunableIntegerNamed:(NSString*)_named
                        setter:(iSmartDebugKitTunableIntegerValueSetter)_setter
                        getter:(iSmartDebugKitTunableIntegerValueGetter)_getter
                         range:(NSArray*)_range;


- (void)addTunableFloatNamed:(NSString*)_named
                      setter:(iSmartDebugKitTunableFloatValueSetter)_setter
                      getter:(iSmartDebugKitTunableFloatValueGetter)_getter
                    minValue:(float)_minValue
                    maxValue:(float)_maxValue;


- (void)addTunableDoubleNamed:(NSString*)_named
                       setter:(iSmartDebugKitTunableDoubleValueSetter)_setter
                       getter:(iSmartDebugKitTunableDoubleValueGetter)_getter
                     minValue:(double)_minValue
                     maxValue:(double)_maxValue;


- (void)addTunableStringNamed:(NSString*)_named
                       setter:(iSmartDebugKitTunableStringValueSetter)_setter
                       getter:(iSmartDebugKitTunableStringValueGetter)_getter;

- (void)addTunableStringSwitchNamed:(NSString*)_named
                             setter:(iSmartDebugKitTunableStringValueSetter)_setter
                             getter:(iSmartDebugKitTunableStringValueGetter)_getter
                            allowed:(NSArray*)values;


- (void)removeTunableVariableNamed:(NSString*)_name;


- (void)refreshTunableVariableNamed:(NSString*)name;

//CUSTOM ACTIONS
- (void)addCustomAction:(iSmartDebugKitCustomAction)_action named:(NSString*)_named;


- (void)removeCustomActionNamed:(NSString*)_named;


//QAT
//presets
+ (void) setConfigurationPresets:(NSArray<NSDictionary *>*) presets;

- (void)saveString:(NSString*)value forKey:(NSString*)key;
- (NSString*)loadStringForKey:(NSString*)key defaultsTo:(NSString*)defaultValue;

- (void)saveBool:(BOOL)value forKey:(NSString*)key;
- (BOOL)loadBoolForKey:(NSString*)key defaultsTo:(BOOL)defaultValue;

- (void)saveInt:(NSInteger)value forKey:(NSString*)key;
- (NSInteger)loadIntForKey:(NSString*)key defaultsTo:(NSInteger)defaultValue;

- (void)trackMoPubBannerAdapter:(Class)adapterClass;

@end
#endif /* iSmartDebugKit_h */
