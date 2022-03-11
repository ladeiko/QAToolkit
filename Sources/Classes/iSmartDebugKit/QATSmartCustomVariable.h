//
//  QATSmartCustomVariable.h
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 6/1/18.

//

#import "QAToolkit.h"
#import "iSmartDebugKit.h"

/**
 QATSmartCustomVariable extends DBCustomVariable to support iSmartDebugKit functionality:
    - added bounds checking (min,max values)
    - using getters/setters from application part to set/get value
    - sends notification when value is changed.
 */
@interface QATSmartCustomVariable : DBCustomVariable

@property (strong) NSNumber* _Null_unspecified minValue;
@property (strong) NSNumber* _Null_unspecified maxValue;
@property (strong) NSArray* _Null_unspecified rangeArr;

#pragma mark statiс methods

+ (DBCustomVariableType)typeForValue:(id _Null_unspecified) val;

#pragma mark - Initialization


/**
 Fabric method which create instance of new custom variable

 @param name string value of identificator for custom variable
 @param val initial value of variable (NSString or NSNumber)
 @param minVal minimum bound
 @param maxVal maximum bound
 @param getr getter to access value from application part
 @param setr setter to set new value in the application part.
 @return new instance
 */
+ (_Null_unspecified instancetype)customVariableWithName:(NSString * _Null_unspecified)name
                                 value:(id _Null_unspecified)val
                               minimum:(id _Null_unspecified)minVal
                               maximum:(id _Null_unspecified)maxVal
                                getter:(iSmartDebugKitBlock * _Null_unspecified) getr
                                setter:(iSmartDebugKitBlock * _Null_unspecified) setr
                                range:(id _Null_unspecified) range;



/**
 Constructor for internal use

 @param name string value of identificator for custom variable
 @param val initial value of variable (NSString or NSNumber)
 @param minVal minimum bound
 @param maxVal maximum bound
 @param getr getter to access value from application part
 @param setr setter to set new value in the application part.
 @return instance of new custom variable
 */
- (_Null_unspecified instancetype)initWithName:(NSString * _Null_unspecified)name
                       value:(id _Null_unspecified)val
                     minimum:(id _Nullable)minVal
                     maximum:(id _Nullable)maxVal
                      getter:(iSmartDebugKitBlock * _Nullable) getr
                      setter:(iSmartDebugKitBlock * _Nullable) setr
                      range:(id _Null_unspecified) range;




@end
