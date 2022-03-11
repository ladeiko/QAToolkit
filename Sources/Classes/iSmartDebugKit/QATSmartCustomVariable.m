//
//  QATSmartCustomVariable.m
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 6/1/18.

//

#import "QATSmartCustomVariable.h"

@interface QATSmartCustomVariable ()

@property (strong) iSmartDebugKitBlock *getter;
@property (strong) iSmartDebugKitBlock *setter;

@property (assign) DBCustomVariableType cachedType;
@end

@implementation QATSmartCustomVariable
//Added range
@synthesize getter, setter, minValue, maxValue, cachedType,range;


- (instancetype)initWithName:(NSString *)name
                       value:(id)val
                     minimum:(id)minVal
                     maximum:(id)maxVal
                      getter:(iSmartDebugKitBlock *) getr
                      setter:(iSmartDebugKitBlock *) setr
                      range:(id)rng
{
    self = [super initWithFull:name value:val min:minVal max:maxVal range:rng];
    if (self) {
    
        cachedType = [QATSmartCustomVariable typeForValue:val];
        
        minValue = minVal;
        maxValue = maxVal;
        
        getter = getr;
        setter = setr;
        range = rng;
        
    }
    return self;
}

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
+ (instancetype)customVariableWithName:(NSString *)name
                                 value:(id)val
                               minimum:(id)minVal
                               maximum:(id)maxVal
                                getter:(iSmartDebugKitBlock *) getr
                                setter:(iSmartDebugKitBlock *) setr
                                 range:(id)range
{
    return [[QATSmartCustomVariable alloc] initWithName:name value:val minimum:minVal maximum:maxVal getter:getr setter:setr range:range];
}


+ (DBCustomVariableType)typeForValue:(id) val {
    if ([val isKindOfClass:[NSString class]]) {
        return DBCustomVariableTypeString;
    } else if ([val isKindOfClass:[NSNumber class]]) {
        NSNumber *numberValue = (NSNumber *)val;
        CFNumberType numberType = CFNumberGetType((CFNumberRef)numberValue);
        switch (numberType) {
            case kCFNumberCharType:
                return DBCustomVariableTypeBool;
            case kCFNumberSInt8Type:
            case kCFNumberSInt16Type:
            case kCFNumberSInt32Type:
            case kCFNumberSInt64Type:
            case kCFNumberShortType:
            case kCFNumberIntType:
            case kCFNumberLongType:
            case kCFNumberLongLongType:
            case kCFNumberCFIndexType:
            case kCFNumberNSIntegerType:
                return DBCustomVariableTypeInt;
            case kCFNumberFloat32Type:
            case kCFNumberFloat64Type:
            case kCFNumberFloatType:
            case kCFNumberDoubleType:
            case kCFNumberCGFloatType:
                return DBCustomVariableTypeDouble;
        }
    }
    return DBCustomVariableTypeUnrecognized;
}

-(DBCustomVariableType) type {
    return cachedType;
}


-(id _Nullable) value {
    
    if (self.getter) {
        switch (cachedType) {
            case DBCustomVariableTypeString: return ((iSmartDebugKitTunableStringValueGetter )[self.getter actionBlock])();
            case DBCustomVariableTypeBool  : return [NSNumber numberWithBool   : ((iSmartDebugKitTunableBooleanValueGetter)[self.getter actionBlock])() ];
            case DBCustomVariableTypeInt   : return [NSNumber numberWithInt    : ((iSmartDebugKitTunableIntegerValueGetter)[self.getter actionBlock])() ];
            case DBCustomVariableTypeDouble: return [NSNumber numberWithDouble : ((iSmartDebugKitTunableDoubleValueGetter )[self.getter actionBlock])() ];
            case DBCustomVariableTypeUnrecognized: return nil;
        }
    }
    

    return [super value];
}

-(void) setValue:(id)value {
    id oldValue = self.value;
    
    [super setValue:value];
    
    if (value == nil) { return; }
    NSAssert( cachedType == [QATSmartCustomVariable typeForValue:value], @"Types mismatch. Trying assing value with different type");
    
    if (self.setter) {
        
        switch (cachedType) {
            case DBCustomVariableTypeString: ((iSmartDebugKitTunableStringValueSetter )[self.setter actionBlock])((NSString*)value   ); break;
            case DBCustomVariableTypeBool  : ((iSmartDebugKitTunableBooleanValueSetter)[self.setter actionBlock])([value boolValue  ]); break;
            case DBCustomVariableTypeInt   : ((iSmartDebugKitTunableIntegerValueSetter)[self.setter actionBlock])([value intValue   ]); break;
            case DBCustomVariableTypeDouble: ((iSmartDebugKitTunableDoubleValueSetter )[self.setter actionBlock])([value doubleValue]); break;
                
            case DBCustomVariableTypeUnrecognized:
            default:
                // nothing to do
                break;
        }
    }
    
    
    //CHECK userInfo
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.name,iSmartDebugKitTunableVariableNameKey,
                              oldValue, NSKeyValueChangeOldKey,
                              value, NSKeyValueChangeNewKey,
                              nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:iSmartDebugKitTunableVariableValueDidChangeNotification
                                                        object:self
                                                      userInfo:userInfo];
    
    /*
     [[NSNotificationCenter defaultCenter] postNotificationName:iSmartDebugKitTunableVariableValueDidChangeNotification
     object:self
     userInfo:[NSDictionary dictionaryWithObject:_name
     forKey:iSmartDebugKitTunableVariableNameKey]
     ];
     */
}

@end
